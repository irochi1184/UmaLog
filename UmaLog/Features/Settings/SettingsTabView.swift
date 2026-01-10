import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct SettingsTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BetRecord.createdAt, order: .forward) private var records: [BetRecord]

    @AppStorage("prefersQuickEntry") private var prefersQuickEntry = true
    @AppStorage("showRacecourseField") private var showRacecourseField = false
    @AppStorage("showHorseNumberField") private var showHorseNumberField = false
    @AppStorage("showJockeyField") private var showJockeyField = false
    @AppStorage("showHorseNameField") private var showHorseNameField = false
    @AppStorage("showRaceTimeField") private var showRaceTimeField = false
    @AppStorage("showCourseSurfaceField") private var showCourseSurfaceField = false
    @AppStorage("showCourseDirectionField") private var showCourseDirectionField = false
    @AppStorage("showCourseLengthField") private var showCourseLengthField = false
    @AppStorage("showWeatherField") private var showWeatherField = false
    @AppStorage("showTrackConditionField") private var showTrackConditionField = false
    @AppStorage("showMemoField") private var showMemoField = false
    @AppStorage("themeColorSelection") private var themeColorSelection = ThemeColorPalette.defaultSelectionId
    @AppStorage("customThemeColorHex") private var customThemeColorHex = ThemeColorPalette.defaultCustomHex

    @State private var exportDocument: CSVDocument?
    @State private var isExportingBackup = false
    @State private var isImportingBackup = false
    @State private var isShowingSampleDataDialog = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var isShowingCustomColorPicker = false
    @State private var customColor = ThemeColorPalette.color(from: ThemeColorPalette.defaultCustomHex)

    private var cardBackground: Color {
        Color(.secondarySystemBackground)
    }

    private var mainColor: Color {
        ThemeColorPalette.color(for: themeColorSelection, customHex: customThemeColorHex)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                LinearGradient(
                    colors: [mainColor.opacity(0.9), mainColor.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        appearanceSection
                        modeSection
                        memoSection
                        toggleSection
                        backupSection
                        infoSection
                    }
                    .padding()
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
        }
        .fileExporter(
            isPresented: $isExportingBackup,
            document: exportDocument,
            contentType: .commaSeparatedText,
            defaultFilename: backupFileName
        ) { result in
            switch result {
            case .success:
                showAlert(title: "バックアップを保存しました", message: "CSVファイルとして保存しました。大切に保管してください。")
            case .failure:
                showAlert(title: "保存に失敗しました", message: "バックアップの書き出し中に問題が発生しました。もう一度お試しください。")
            }
        }
        .fileImporter(
            isPresented: $isImportingBackup,
            allowedContentTypes: [.commaSeparatedText]
        ) { result in
            handleImport(result: result)
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $isShowingCustomColorPicker) {
            NavigationStack {
                VStack(spacing: 24) {
                    ColorPicker("カスタムカラー", selection: $customColor, supportsOpacity: false)
                        .font(.headline)
                        .padding(.vertical, 8)
                }
                .padding()
                .navigationTitle("カスタムカラー")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("完了") {
                            isShowingCustomColorPicker = false
                        }
                    }
                }
            }
        }
        .onAppear {
            customColor = ThemeColorPalette.color(from: customThemeColorHex)
        }
        .onChange(of: customColor) { _, newValue in
            if let hex = newValue.toHex() {
                customThemeColorHex = hex
            }
        }
        .confirmationDialog("サンプルデータを入れますか？", isPresented: $isShowingSampleDataDialog, titleVisibility: .visible) {
            Button("入れる", role: .destructive) {
                insertSampleData()
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("いまの記録はすべて置き換わります。")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("入力スタイルの設定")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text("サクッと記録か、がっつり記録か。表示する項目をここで切り替えられます。")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
        }
    }

    private var modeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("記録モード")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(spacing: 12) {
                Text("「サクッと」は必須項目だけ、「がっつり」は詳細をすべて出します。モードを変えると下のチェックも切り替わります。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    modeButton(title: "サクッと記録", isSelected: prefersQuickEntry) {
                        prefersQuickEntry = true
                        applyQuickPreset()
                    }
                    modeButton(title: "がっつり記録", isSelected: !prefersQuickEntry) {
                        prefersQuickEntry = false
                        applyDetailedPreset()
                    }
                }
            }
            .padding()
            .background(cardBackground, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("画面デザイン")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 12) {
                Text("メインカラーを選ぶと、アプリ全体の雰囲気が変わります。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: colorGridColumns, spacing: 12) {
                    ForEach(ThemeColorPalette.presets) { preset in
                        Button {
                            themeColorSelection = preset.id
                        } label: {
                            colorSwatch(
                                color: ThemeColorPalette.color(from: preset.hex),
                                title: preset.name,
                                isSelected: themeColorSelection == preset.id,
                                showsIcon: false
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        themeColorSelection = ThemeColorPalette.customId
                        isShowingCustomColorPicker = true
                    } label: {
                        colorSwatch(
                            color: ThemeColorPalette.color(from: customThemeColorHex),
                            title: "カスタムカラー",
                            isSelected: themeColorSelection == ThemeColorPalette.customId,
                            showsIcon: true
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .background(cardBackground, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var toggleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("表示する入力項目")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(spacing: 12) {
                toggleRow(title: "競馬場名", isOn: $showRacecourseField)
                toggleRow(title: "馬番", isOn: $showHorseNumberField)
                toggleRow(title: "騎手", isOn: $showJockeyField)
                toggleRow(title: "馬名", isOn: $showHorseNameField)
                toggleRow(title: "発走予定（5分刻み）", isOn: $showRaceTimeField)
                toggleRow(title: "コース（芝・ダートなど）", isOn: $showCourseSurfaceField)
                toggleRow(title: "コースの向き（右・左など）", isOn: $showCourseDirectionField)
                toggleRow(title: "コースの長さ", isOn: $showCourseLengthField)
                toggleRow(title: "天気", isOn: $showWeatherField)
                toggleRow(title: "馬場状態", isOn: $showTrackConditionField)
                toggleRow(title: "ひと言メモ", isOn: $showMemoField)
            }
            .padding()
            .background(cardBackground, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var memoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("メモ帳")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(spacing: 12) {
                Text("買い目のメモや当日の気づきを、一覧で管理できます。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                NavigationLink {
                    MemoListView()
                } label: {
                    Label("メモ帳を開く", systemImage: "note.text")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(cardBackground, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var backupSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("バックアップ")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 12) {
                Text("記録をCSVで保存・復元できます。復元するといまの記録は置き換わります。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                VStack(spacing: 10) {
                    Button(action: startExport) {
                        Label("バックアップを作成", systemImage: "tray.and.arrow.up")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button(action: { isImportingBackup = true }) {
                        Label("バックアップを復元", systemImage: "arrow.clockwise")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button(action: { isShowingSampleDataDialog = true }) {
                        Label("サンプルデータを入れる（開発者用）", systemImage: "wand.and.stars")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .background(cardBackground, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("メモ")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 8) {
                Text("モードはいつでも切り替え可能です。入力途中でも設定から変えられます。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(cardBackground, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private func modeButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? mainColor.opacity(0.9) : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var colorGridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    }

    private func colorSwatch(color: Color, title: String, isSelected: Bool, showsIcon: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(color)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? Color.white : Color.white.opacity(0.15), lineWidth: isSelected ? 3 : 1)
                )

            if showsIcon {
                Image(systemName: "paintbrush.pointed")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))
            } else if isSelected {
                Image(systemName: "checkmark")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(height: 72)
        .accessibilityLabel(title)
    }

    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(.subheadline)
        }
        .toggleStyle(.switch)
    }

    private func applyQuickPreset() {
        showRacecourseField = false
        showHorseNumberField = false
        showJockeyField = false
        showHorseNameField = false
        showRaceTimeField = false
        showCourseSurfaceField = false
        showCourseDirectionField = false
        showCourseLengthField = false
        showWeatherField = false
        showTrackConditionField = false
        showMemoField = false
    }

    private func applyDetailedPreset() {
        showRacecourseField = true
        showHorseNumberField = true
        showJockeyField = true
        showHorseNameField = true
        showRaceTimeField = true
        showCourseSurfaceField = true
        showCourseDirectionField = true
        showCourseLengthField = true
        showWeatherField = true
        showTrackConditionField = true
        showMemoField = true
    }

    private func startExport() {
        let csv = makeCSVString(from: records)
        guard let data = csv.data(using: .utf8) else {
            showAlert(title: "バックアップを作成できませんでした", message: "データの変換に失敗しました。")
            return
        }
        exportDocument = CSVDocument(data: data)
        isExportingBackup = true
    }

    private func handleImport(result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            do {
                let didAccess = url.startAccessingSecurityScopedResource()
                defer {
                    if didAccess {
                        url.stopAccessingSecurityScopedResource()
                    }
                }

                let data = try Data(contentsOf: url)
                guard let text = String(data: data, encoding: .utf8) else {
                    showAlert(title: "読み込みに失敗しました", message: "ファイルを読み込めませんでした。UTF-8形式のCSVを指定してください。")
                    return
                }
                let rows = parseCSV(text)
                guard rows.count > 1 else {
                    showAlert(title: "読み込みに失敗しました", message: "記録が見つかりませんでした。")
                    return
                }
                let recordsToImport = rows.dropFirst().compactMap { record(from: $0) }
                guard !recordsToImport.isEmpty else {
                    showAlert(title: "読み込みに失敗しました", message: "有効な記録がありませんでした。")
                    return
                }
                try replaceAllRecords(with: recordsToImport)
                showAlert(title: "復元しました", message: "\(recordsToImport.count)件の記録を読み込みました。")
            } catch {
                showAlert(title: "復元に失敗しました", message: "ファイルの読み込み中に問題が発生しました。もう一度お試しください。")
            }
        case .failure(let error):
            if (error as NSError).code == NSUserCancelledError {
                return
            }
            showAlert(title: "復元に失敗しました", message: "ファイルの選択に失敗しました。もう一度お試しください。")
        }
    }

    private func replaceAllRecords(with newRecords: [BetRecord]) throws {
        let existingRecords = try modelContext.fetch(FetchDescriptor<BetRecord>())
        existingRecords.forEach { modelContext.delete($0) }
        newRecords.forEach { modelContext.insert($0) }
    }

    private func insertSampleData() {
        let sampleRecords = generateSampleRecords(count: 300)
        let csvText = makeCSVString(from: sampleRecords)
        let rows = parseCSV(csvText)
        let recordsToImport = rows.dropFirst().compactMap { record(from: $0) }
        guard !recordsToImport.isEmpty else {
            showAlert(title: "サンプルを作成できませんでした", message: "記録の生成に失敗しました。もう一度お試しください。")
            return
        }

        do {
            try replaceAllRecords(with: recordsToImport)
            showAlert(title: "サンプルを入れました", message: "\(recordsToImport.count)件の記録を追加しました。")
        } catch {
            showAlert(title: "サンプルを作成できませんでした", message: "記録の置き換え中に問題が発生しました。")
        }
    }

    private func generateSampleRecords(count: Int) -> [BetRecord] {
        let racecourses = ["東京", "中山", "阪神", "京都", "札幌", "函館", "福島", "新潟", "中京", "小倉"]
        let jockeys = ["佐藤騎手", "鈴木騎手", "高橋騎手", "田中騎手", "伊藤騎手", "山本騎手"]
        let horses = ["サクラライト", "ミッドナイトスター", "ブルーフラッシュ", "ゴールドストーム", "スカイウィナー", "ブライトリーフ"]
        let courseSurfaces = ["芝", "ダート"]
        let courseDirections = ["右", "左", "直線"]
        let courseLengths = ["1000", "1200", "1400", "1600", "1800", "2000", "2400", "3000"]
        let weathers = ["晴れ", "くもり", "雨", "小雨", "晴れ時々くもり"]
        let trackConditions = ["良", "稍重", "重", "不良"]
        let memoSamples = ["序盤から押して勝負。", "気になる馬を試し買い。", "堅めの狙い。", "波乱狙いで挑戦。", "データ重視で選択。"]
        let minutes = stride(from: 0, through: 55, by: 5).map { $0 }
        let now = Date()

        return (0..<count).map { _ in
            let ticketType = TicketType.allCases.randomElement() ?? .win
            let popularity = PopularityBand.allCases.randomElement() ?? .mid
            let raceGrade = RaceGrade.allCases.randomElement() ?? .flat
            let investment = Double(Int.random(in: 1...40) * 100)
            let payout = Bool.random() ? Double(Int.random(in: 0...80) * 100) : 0
            let raceNumber = String(Int.random(in: 1...12))
            let horseNumber = String(Int.random(in: 1...18))
            let hour = Int.random(in: 10...17)
            let minute = minutes.randomElement() ?? 0
            let raceTimeDetail = String(format: "%02d:%02d", hour, minute)
            let randomOffset = TimeInterval(Double.random(in: 0...(60 * 60 * 24 * 180)))
            let createdAt = now.addingTimeInterval(-randomOffset)

            return BetRecord(
                createdAt: createdAt,
                ticketType: ticketType,
                popularityBand: popularity,
                raceGrade: raceGrade,
                investment: investment,
                payout: payout,
                racecourse: racecourses.randomElement(),
                raceNumber: raceNumber,
                horseNumber: horseNumber,
                jockeyName: jockeys.randomElement(),
                horseName: horses.randomElement(),
                raceTimeDetail: raceTimeDetail,
                courseSurface: courseSurfaces.randomElement(),
                courseDirection: courseDirections.randomElement(),
                courseLength: courseLengths.randomElement(),
                weather: weathers.randomElement(),
                trackCondition: trackConditions.randomElement(),
                memo: Bool.random() ? memoSamples.randomElement() : nil
            )
        }
    }

    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }

    private func makeCSVString(from records: [BetRecord]) -> String {
        var lines: [String] = [
            "createdAt,ticketType,popularityBand,raceGrade,investment,payout,racecourse,raceNumber,horseNumber,jockeyName,horseName,raceTimeDetail,courseSurface,courseDirection,courseLength,weather,trackCondition,memo"
        ]
        for record in records {
            let values: [String] = [
                Self.backupDateFormatter.string(from: record.createdAt),
                csvValue(record.ticketType.rawValue),
                csvValue(record.popularityBand.rawValue),
                csvValue(record.raceGrade.rawValue),
                "\(record.investment)",
                "\(record.payout)",
                csvValue(record.racecourse),
                csvValue(record.raceNumber),
                csvValue(record.horseNumber),
                csvValue(record.jockeyName),
                csvValue(record.horseName),
                csvValue(record.raceTimeDetail),
                csvValue(record.courseSurface),
                csvValue(record.courseDirection),
                csvValue(record.courseLength),
                csvValue(record.weather),
                csvValue(record.trackCondition),
                csvValue(record.memo)
            ]
            lines.append(values.joined(separator: ","))
        }
        return lines.joined(separator: "\n")
    }

    private func parseCSV(_ text: String) -> [[String]] {
        let characters = Array(text)
        var index = 0
        var rows: [[String]] = []
        var currentRow: [String] = []
        var currentValue = ""
        var isInsideQuotes = false

        func appendCurrentValue() {
            currentRow.append(currentValue)
            currentValue = ""
        }

        while index < characters.count {
            let character = characters[index]

            if character == "\"" {
                let nextIndex = index + 1
                if isInsideQuotes && nextIndex < characters.count && characters[nextIndex] == "\"" {
                    currentValue.append("\"")
                    index += 1
                } else {
                    isInsideQuotes.toggle()
                }
            } else if character == "," && !isInsideQuotes {
                appendCurrentValue()
            } else if character == "\n" && !isInsideQuotes {
                appendCurrentValue()
                rows.append(currentRow)
                currentRow = []
            } else if character != "\r" {
                currentValue.append(character)
            }

            index += 1
        }

        if !currentValue.isEmpty || !currentRow.isEmpty {
            appendCurrentValue()
            rows.append(currentRow)
        }

        return rows
    }

    private func record(from row: [String]) -> BetRecord? {
        guard
            let createdAtText = value(at: 0, from: row),
            let createdAt = Self.backupDateFormatter.date(from: createdAtText)
        else { return nil }

        let ticket = TicketType(rawValue: value(at: 1, from: row) ?? "") ?? .win
        let popularity = PopularityBand(rawValue: value(at: 2, from: row) ?? "") ?? .mid
        let raceGrade = RaceGrade(rawValue: value(at: 3, from: row) ?? "") ?? .flat
        guard let investmentText = value(at: 4, from: row), let investment = Double(investmentText) else {
            return nil
        }
        let payout = Double(value(at: 5, from: row) ?? "") ?? 0

        let racecourse = value(at: 6, from: row)
        let raceNumber = value(at: 7, from: row)
        let horseNumber = value(at: 8, from: row)
        let jockeyName = value(at: 9, from: row)
        let horseName = value(at: 10, from: row)
        let raceTimeDetail = value(at: 11, from: row)
        let courseSurface = value(at: 12, from: row)
        let courseDirection = value(at: 13, from: row)
        let courseLength = value(at: 14, from: row)
        let weather = value(at: 15, from: row)
        let trackCondition = value(at: 16, from: row)
        let memo = value(at: 17, from: row)

        return BetRecord(
            createdAt: createdAt,
            ticketType: ticket,
            popularityBand: popularity,
            raceGrade: raceGrade,
            investment: investment,
            payout: payout,
            racecourse: racecourse,
            raceNumber: raceNumber,
            horseNumber: horseNumber,
            jockeyName: jockeyName,
            horseName: horseName,
            raceTimeDetail: raceTimeDetail,
            courseSurface: courseSurface,
            courseDirection: courseDirection,
            courseLength: courseLength,
            weather: weather,
            trackCondition: trackCondition,
            memo: memo
        )
    }

    private func value(at index: Int, from row: [String]) -> String? {
        guard index < row.count else { return nil }
        let value = row[index].trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }

    private func csvValue(_ text: String?) -> String {
        guard let text, !text.isEmpty else { return "" }
        let escaped = text.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }

    private var backupFileName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmm"
        return "UmaLog_Backup_\(formatter.string(from: .now))"
    }

    private static let backupDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}

#Preview {
    SettingsTabView()
}

struct CSVDocument: FileDocument {
    static var readableContentTypes: [UTType] = [.commaSeparatedText]

    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

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

    @State private var exportDocument: CSVDocument?
    @State private var isExportingBackup = false
    @State private var isImportingBackup = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false

    private var cardBackground: Color {
        Color(.secondarySystemBackground)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                LinearGradient(
                    colors: [Color("MainGreen", bundle: .main).opacity(0.9), Color("MainGreen", bundle: .main).opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        modeSection
                        toggleSection
                        backupSection
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
                }
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
                .background(isSelected ? Color("MainGreen", bundle: .main).opacity(0.9) : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
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

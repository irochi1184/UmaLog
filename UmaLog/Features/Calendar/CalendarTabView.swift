import SwiftUI
import SwiftData

struct CalendarTabView: View {
    let records: [BetRecord]

    @Environment(\.modelContext) private var modelContext
    @State private var displayedMonth: Date = Calendar.autoupdatingCurrent.date(
        from: Calendar.autoupdatingCurrent.dateComponents([.year, .month], from: Date())
    ) ?? Date()
    @State private var selectedDate: Date?
    @State private var editState = EditRecordState()
    @FocusState private var focusedAmountField: AmountField?
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

    private let dateLocale = Locale(identifier: "ja_JP")

    private var calendar: Calendar {
        var calendar = Calendar.autoupdatingCurrent
        calendar.locale = dateLocale
        return calendar
    }

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
                        calendarHeader
                        calendarSection
                    }
                    .padding()
                }
            }
            .navigationTitle("カレンダー")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(
            isPresented: Binding(
                get: { selectedDate != nil },
                set: { if !$0 { selectedDate = nil } }
            )
        ) {
            if let selectedDate = selectedDate {
                DailyRecordsSheet(
                    date: selectedDate,
                    records: recordsForDate(selectedDate),
                    calendar: calendar,
                    cardBackground: cardBackground,
                    currency: { AmountFormatting.currency($0) },
                    editState: $editState,
                    focusedAmountField: $focusedAmountField,
                    showRacecourse: showRacecourseField,
                    showHorseNumber: showHorseNumberField,
                    showJockey: showJockeyField,
                    showHorseName: showHorseNameField,
                    showRaceTime: showRaceTimeField,
                    showCourseSurface: showCourseSurfaceField,
                    showCourseDirection: showCourseDirectionField,
                    showCourseLength: showCourseLengthField,
                    showWeather: showWeatherField,
                    showTrackCondition: showTrackConditionField,
                    showMemo: showMemoField,
                    fiveMinuteOptions: fiveMinuteOptions,
                    jockeySuggestions: jockeySuggestions,
                    horseSuggestions: horseSuggestions,
                    onSave: saveEditing,
                    onDelete: deleteRecord(_:),
                    startEditing: startEditing(_:),
                    startNewRecord: startNewRecord(for:),
                    dismiss: { self.selectedDate = nil }
                )
            }
        }
    }

    private var calendarHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("日ごとの浮き沈みを色でひと目に")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text("記録した日付をカレンダーで振り返り。プラスの日は緑、マイナスの日は赤で表示します。")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
        }
    }

    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("カレンダーで収支を確認")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Button {
                        changeMonth(by: -1)
                    } label: {
                        Image(systemName: "chevron.left")
                            .padding(8)
                            .background(Color(.systemGray5), in: Circle())
                    }

                    Spacer()

                    Text(currentMonthTitle)
                        .font(.title3.weight(.semibold))

                    Spacer()

                    Button {
                        changeMonth(by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                            .padding(8)
                            .background(Color(.systemGray5), in: Circle())
                    }
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                    ForEach(weekdaySymbols, id: \.self) { weekday in
                        Text(weekday)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }

                    ForEach(calendarDays.indices, id: \.self) { index in
                        if let date = calendarDays[index] {
                            calendarCell(for: date)
                        } else {
                            Color.clear.frame(height: 56)
                        }
                    }
                }
            }
            .padding()
            .background(cardBackground, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var currentMonthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = dateLocale
        formatter.calendar = calendar
        formatter.setLocalizedDateFormatFromTemplate("yMMM")
        return formatter.string(from: displayedMonth)
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        let startIndex = (calendar.firstWeekday - 1 + symbols.count) % symbols.count
        let ordered = Array(symbols[startIndex...] + symbols[..<startIndex])
        return ordered
    }

    private var calendarDays: [Date?] {
        let dates = datesInMonth(for: displayedMonth)
        let offset = weekdayOffset(for: displayedMonth)
        return Array(repeating: nil, count: offset) + dates
    }

    private func calendarCell(for date: Date) -> some View {
        let totals = dailyTotals[calendar.startOfDay(for: date)]
        let net = totals.map { $0.payout - $0.investment }
        let isToday = calendar.isDateInToday(date)
        let background: Color

        if let net {
            background = net > 0 ? mainColor.opacity(0.15) : (net < 0 ? Color.red.opacity(0.15) : Color.gray.opacity(0.12))
        } else {
            background = Color(.systemGray6)
        }

        return Button {
            showRecords(for: date)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.headline)

                if let totals {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(AmountFormatting.currency(totals.investment))
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.red.opacity(0.8))
                            .lineLimit(1)
                            .minimumScaleFactor(0.45)

                        Text(AmountFormatting.currency(totals.payout))
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(mainColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.45)
                    }
                } else {
                    Text("—")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .padding(8)
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .background(background, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.accentColor, lineWidth: isToday ? 2 : 0)
        )
    }

    private var dailyTotals: [Date: (investment: Double, payout: Double)] {
        Dictionary(grouping: records) { record in
            calendar.startOfDay(for: record.createdAt)
        }
        .mapValues { dailyRecords in
            let investment = dailyRecords.reduce(0) { $0 + $1.investment }
            let payout = dailyRecords.reduce(0) { $0 + $1.payout }
            return (investment, payout)
        }
    }

    private func changeMonth(by value: Int) {
        let baseMonth = startOfMonth(for: displayedMonth)

        if let next = calendar.date(byAdding: .month, value: value, to: baseMonth) {
            let normalized = startOfMonth(for: next)
            displayedMonth = normalized
        }
    }

    private func datesInMonth(for date: Date) -> [Date] {
        guard let interval = calendar.dateInterval(of: .month, for: date) else { return [] }
        var dates: [Date] = []
        var current = interval.start

        while current < interval.end {
            dates.append(current)
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return dates
    }

    private func weekdayOffset(for date: Date) -> Int {
        guard let start = calendar.dateInterval(of: .month, for: date)?.start else { return 0 }
        let weekday = calendar.component(.weekday, from: start)
        let firstWeekday = calendar.firstWeekday
        return (weekday - firstWeekday + 7) % 7
    }

    private func startOfMonth(for date: Date) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }

    private func showRecords(for date: Date) {
        selectedDate = calendar.startOfDay(for: date)
    }

    private func recordsForDate(_ date: Date) -> [BetRecord] {
        records
            .filter { calendar.isDate($0.createdAt, inSameDayAs: date) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private var fiveMinuteOptions: [String] {
        var options: [String] = [""]
        for hour in 0..<24 {
            for minute in stride(from: 0, to: 60, by: 5) {
                options.append(String(format: "%02d:%02d", hour, minute))
            }
        }
        return options
    }

    private var jockeySuggestions: [String] {
        Array(Set(records.compactMap { $0.jockeyName?.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }))
            .sorted()
    }

    private var horseSuggestions: [String] {
        Array(Set(records.compactMap { $0.horseName?.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }))
            .sorted()
    }

    private func startEditing(_ record: BetRecord) {
        editState.load(from: record)
    }

    private func startNewRecord(for date: Date) {
        editState.prepareForNew(date: calendar.startOfDay(for: date))
    }

    private func deleteRecord(_ record: BetRecord) {
        withAnimation {
            modelContext.delete(record)
            if editState.record == record {
                editState.isPresented = false
                editState.record = nil
            }
        }
    }

    private func saveEditing() {
        guard
            let investment = AmountFormatting.parseAmount(editState.investmentText)
        else { return }
        let payout = AmountFormatting.parseAmount(editState.payoutText) ?? 0

        normalizeEditHorseSelection(maxSelection: editState.ticketType.requiredHorseSelections)

        withAnimation {
            if let record = editState.record {
                record.createdAt = calendar.startOfDay(for: editState.date)
                record.ticketType = editState.ticketType
                record.popularityBand = editState.popularityBand
                record.raceGrade = editState.raceGrade
                record.investment = investment
                record.payout = payout
                record.racecourse = preservedValue(from: editState.racecourse.rawValue, isEnabled: showRacecourseField, original: record.racecourse)
                record.raceNumber = String(editState.raceNumber)
                let horseNumberText = editState.horseNumbers.isEmpty ? nil : editState.horseNumbers.map(String.init).joined(separator: "-")
                record.horseNumber = preservedValue(from: horseNumberText ?? "", isEnabled: showHorseNumberField, original: record.horseNumber)
                record.jockeyName = preservedValue(from: editState.jockeyName, isEnabled: showJockeyField, original: record.jockeyName)
                record.horseName = preservedValue(from: editState.horseName, isEnabled: showHorseNameField, original: record.horseName)
                record.raceTimeDetail = preservedValue(from: editState.raceTimeDetail, isEnabled: showRaceTimeField, original: record.raceTimeDetail)
                record.courseSurface = preservedValue(from: editState.courseSurface, isEnabled: showCourseSurfaceField, original: record.courseSurface)
                record.courseDirection = preservedValue(from: editState.courseDirection, isEnabled: showCourseDirectionField, original: record.courseDirection)
                record.courseLength = preservedValue(from: editState.courseLength, isEnabled: showCourseLengthField, original: record.courseLength)
                record.weather = preservedValue(from: editState.weather, isEnabled: showWeatherField, original: record.weather)
                record.trackCondition = preservedValue(from: editState.trackCondition, isEnabled: showTrackConditionField, original: record.trackCondition)
                record.memo = preservedValue(from: editState.memo, isEnabled: showMemoField, original: record.memo)
            } else {
                let horseNumberText = editState.horseNumbers.isEmpty ? nil : editState.horseNumbers.map(String.init).joined(separator: "-")
                let newRecord = BetRecord(
                    createdAt: calendar.startOfDay(for: editState.date),
                    ticketType: editState.ticketType,
                    popularityBand: editState.popularityBand,
                    raceGrade: editState.raceGrade,
                    investment: investment,
                    payout: payout,
                    racecourse: preservedValue(from: editState.racecourse.rawValue, isEnabled: showRacecourseField, original: nil),
                    raceNumber: String(editState.raceNumber),
                    horseNumber: preservedValue(from: horseNumberText ?? "", isEnabled: showHorseNumberField, original: nil),
                    jockeyName: preservedValue(from: editState.jockeyName, isEnabled: showJockeyField, original: nil),
                    horseName: preservedValue(from: editState.horseName, isEnabled: showHorseNameField, original: nil),
                    raceTimeDetail: preservedValue(from: editState.raceTimeDetail, isEnabled: showRaceTimeField, original: nil),
                    courseSurface: preservedValue(from: editState.courseSurface, isEnabled: showCourseSurfaceField, original: nil),
                    courseDirection: preservedValue(from: editState.courseDirection, isEnabled: showCourseDirectionField, original: nil),
                    courseLength: preservedValue(from: editState.courseLength, isEnabled: showCourseLengthField, original: nil),
                    weather: preservedValue(from: editState.weather, isEnabled: showWeatherField, original: nil),
                    trackCondition: preservedValue(from: editState.trackCondition, isEnabled: showTrackConditionField, original: nil),
                    memo: preservedValue(from: editState.memo, isEnabled: showMemoField, original: nil)
                )
                modelContext.insert(newRecord)
            }
            focusedAmountField = nil
            editState.isPresented = false
            editState.isNewEntry = false
        }
    }

    private func normalizeEditHorseSelection(maxSelection: Int) {
        if editState.horseNumbers.count > maxSelection {
            editState.horseNumbers = Array(editState.horseNumbers.prefix(maxSelection))
        }
    }

    private func preservedValue(from text: String, isEnabled: Bool, original: String?) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if isEnabled {
            return trimmed.isEmpty ? nil : trimmed
        } else {
            return original
        }
    }

    private func preservedValue<Value: RawRepresentable>(from value: Value?, isEnabled: Bool, original: String?) -> String? where Value.RawValue == String {
        guard isEnabled else { return original }
        return value?.rawValue
    }
}

private struct DailyRecordsSheet: View {
    let date: Date
    let records: [BetRecord]
    let calendar: Calendar
    let cardBackground: Color
    let currency: (Double) -> String
    @Binding var editState: EditRecordState
    let focusedAmountField: FocusState<AmountField?>.Binding
    let showRacecourse: Bool
    let showHorseNumber: Bool
    let showJockey: Bool
    let showHorseName: Bool
    let showRaceTime: Bool
    let showCourseSurface: Bool
    let showCourseDirection: Bool
    let showCourseLength: Bool
    let showWeather: Bool
    let showTrackCondition: Bool
    let showMemo: Bool
    let fiveMinuteOptions: [String]
    let jockeySuggestions: [String]
    let horseSuggestions: [String]
    let onSave: () -> Void
    let onDelete: (BetRecord) -> Void
    let startEditing: (BetRecord) -> Void
    let startNewRecord: (Date) -> Void
    let dismiss: () -> Void

    private var dateLocale: Locale {
        calendar.locale ?? Locale(identifier: "ja_JP")
    }

    private var titleFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = dateLocale
        formatter.calendar = calendar
        formatter.setLocalizedDateFormatFromTemplate("yMMMMdEEE")
        return formatter
    }

    private var summaryNet: Double {
        totalPayout - totalInvestment
    }

    private var totalInvestment: Double {
        records.reduce(0) { $0 + $1.investment }
    }

    private var totalPayout: Double {
        records.reduce(0) { $0 + $1.payout }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    summaryCard
                    recordList
                }
                .padding()
            }
            .navigationTitle(titleFormatter.string(from: date))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        startNewRecord(date)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $editState.isPresented) {
                EditRecordSheet(
                    editState: $editState,
                    datePickerLocale: dateLocale,
                    focusedAmountField: focusedAmountField,
                    showRacecourse: showRacecourse,
                    showHorseNumber: showHorseNumber,
                    showJockey: showJockey,
                    showHorseName: showHorseName,
                    showRaceTime: showRaceTime,
                    showCourseSurface: showCourseSurface,
                    showCourseDirection: showCourseDirection,
                    showCourseLength: showCourseLength,
                    showWeather: showWeather,
                    showTrackCondition: showTrackCondition,
                    showMemo: showMemo,
                    fiveMinuteOptions: fiveMinuteOptions,
                    jockeySuggestions: jockeySuggestions,
                    horseSuggestions: horseSuggestions,
                    onSave: onSave,
                    onDelete: onDelete
                )
            }
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("この日に残した記録")
                .font(.headline)
            Text("\(records.count)件 / 投資 \(currency(totalInvestment)) ・ 払戻 \(currency(totalPayout))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack(spacing: 12) {
                Label {
                    Text("投資")
                    Text(currency(totalInvestment))
                        .font(.headline.weight(.semibold))
                } icon: {
                    Image(systemName: "arrow.down.right.circle.fill")
                        .foregroundStyle(.red)
                }
                Label {
                    Text("払戻")
                    Text(currency(totalPayout))
                        .font(.headline.weight(.semibold))
                } icon: {
                    Image(systemName: "arrow.up.right.circle.fill")
                        .foregroundStyle(mainColor)
                }
            }
            HStack(spacing: 12) {
                Spacer()
                Text(summaryNetText)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(summaryNetColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(summaryNetColor.opacity(0.12), in: Capsule())
            }
        }
        .padding()
        .background(cardBackground, in: RoundedRectangle(cornerRadius: 16))
    }

    private var recordList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("タップで編集")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if records.isEmpty {
                Text("この日に保存された記録はありません。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(cardBackground, in: RoundedRectangle(cornerRadius: 14))
            } else {
                VStack(spacing: 12) {
                    ForEach(records) { record in
                        Button {
                            startEditing(record)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(recordTitle(for: record))
                                        .font(.headline)
                                    Spacer()
                                    Text(record.raceGrade.rawValue)
                                        .font(.caption.weight(.semibold))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(.systemGray6), in: Capsule())
                                }
                                ForEach(Array(detailLines(for: record).enumerated()), id: \.offset) { _, line in
                                    Text(line)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                HStack {
                                    Label(currency(record.investment), systemImage: "arrow.down.right")
                                        .foregroundStyle(.primary)
                                    Label(currency(record.payout), systemImage: "arrow.up.right")
                                        .foregroundStyle(mainColor)
                                    Spacer()
                                    Text("回収率 \(record.returnRate, specifier: "%.0f")%")
                                        .font(.caption.weight(.semibold))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(.ultraThinMaterial, in: Capsule())
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(cardBackground, in: RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var summaryNetText: String {
        if summaryNet == 0 { return "収支 ±0" }
        return summaryNet > 0 ? "収支 +\(currency(summaryNet))" : "収支 -\(currency(abs(summaryNet)))"
    }

    private var summaryNetColor: Color {
        if summaryNet == 0 { return .secondary }
        return summaryNet > 0 ? mainColor : .red
    }

    private func recordTitle(for record: BetRecord) -> String {
        let raceNumberText = record.raceNumberText.isEmpty ? "?" : record.raceNumberText
        let racecourseText = record.racecourse?.trimmingCharacters(in: .whitespacesAndNewlines)
        let horseNumberText = record.horseNumber?.trimmingCharacters(in: .whitespacesAndNewlines)
        return [
            racecourseText?.isEmpty == false ? racecourseText! : "競馬場未設定",
            "\(raceNumberText)R",
            "\(record.ticketType.rawValue) \(horseNumberText?.isEmpty == false ? horseNumberText! : "馬番未設定")"
        ]
        .joined(separator: " / ")
    }
}

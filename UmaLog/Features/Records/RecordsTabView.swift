import SwiftData
import SwiftUI

struct RecordsTabView: View {
    @Environment(\.modelContext) private var modelContext

    let records: [BetRecord]

    @State private var formState = RecordFormState()
    @State private var editState = EditRecordState()
    @State private var recordPendingDeletion: BetRecord?
    @State private var showToast = false
    @FocusState private var focusedAmountField: AmountField?
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

    private let datePickerLocale = Locale(identifier: "ja_JP")

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
                        RecordHeaderSection()
                        SummarySection(
                            returnRateText: returnRateText,
                            returnRateColor: returnRateColor,
                            recordCount: records.count,
                            totalInvestment: AmountFormatting.currency(totalInvestment),
                            totalPayout: AmountFormatting.currency(totalPayout),
                            analysisText: lossInsightText
                        )
                        AnalysisSection(pattern: worstPattern, cardBackground: cardBackground)
                        RecordFormSection(
                            formState: $formState,
                            isValidInput: isValidInput,
                            datePickerLocale: datePickerLocale,
                            cardBackground: cardBackground,
                            focusedAmountField: $focusedAmountField,
                            prefersQuickEntry: prefersQuickEntry,
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
                            onAdd: addRecord
                        )
                        HistorySection(
                            records: records,
                            historyDateFormatter: historyDateFormatter,
                            cardBackground: cardBackground,
                            currency: { AmountFormatting.currency($0) },
                            startEditing: startEditing(_:),
                            onRequestDelete: confirmDelete(_:)
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("うまログ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("閉じる") {
                        dismissKeyboard()
                        focusedAmountField = nil
                    }
                }
            }
            .sheet(isPresented: $editState.isPresented) {
                EditRecordSheet(
                    editState: $editState,
                    datePickerLocale: datePickerLocale,
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
                    onDelete: deleteRecord(_:)
                )
            }
            .overlay(alignment: .bottom) {
                if showToast {
                    toastView
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                }
            }
        }
        .onChange(of: formState.ticketType) { _, newValue in
            normalizeHorseSelection(maxSelection: newValue.requiredHorseSelections)
        }
        .onChange(of: editState.ticketType) { _, newValue in
            normalizeEditHorseSelection(maxSelection: newValue.requiredHorseSelections)
        }
        .confirmationDialog("この記録を削除しますか？", isPresented: deleteDialogBinding, titleVisibility: .visible) {
            if let record = recordPendingDeletion {
                Button("削除", role: .destructive) {
                    deleteRecord(record)
                }
            }
            Button("キャンセル", role: .cancel) {
                recordPendingDeletion = nil
            }
        } message: {
            Text("削除すると元に戻せません。")
        }
    }

    private var cardBackground: Color {
        Color(.secondarySystemBackground)
    }

    private var calendar: Calendar {
        var calendar = Calendar.autoupdatingCurrent
        calendar.locale = .autoupdatingCurrent
        return calendar
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

    private var isValidInput: Bool {
        (AmountFormatting.parseAmount(formState.investmentText) ?? 0) > 0 && formState.raceNumber > 0
    }

    private var returnRateText: String {
        guard totalInvestment > 0 else { return "— %" }
        return String(format: "%.0f%%", (totalPayout / totalInvestment) * 100)
    }

    private var returnRateColor: Color {
        guard totalInvestment > 0 else { return .white }
        return totalPayout >= totalInvestment ? mainColor : .red
    }

    private var totalInvestment: Double {
        records.reduce(0) { $0 + $1.investment }
    }

    private var totalPayout: Double {
        records.reduce(0) { $0 + $1.payout }
    }

    private var lossInsightText: String {
        lossInsight ?? "まだ負けの傾向は見えていません。"
    }

    private var lossInsight: String? {
        let lossRecords = records.filter { $0.investment > 0 && $0.payout < $0.investment }
        guard !lossRecords.isEmpty else { return nil }

        let raceStats = featureStats(in: lossRecords, seeds: raceFeatureSeeds(for:))
        let betStats = featureStats(in: lossRecords, seeds: betFeatureSeeds(for:))

        let raceDescriptor = buildRaceDescriptor(from: raceStats)
        let betDescriptor = buildBetDescriptor(from: betStats)

        guard !raceDescriptor.isEmpty, !betDescriptor.isEmpty else { return nil }
        return "\(raceDescriptor)で、\(betDescriptor)が負けがちです。"
    }

    private var historyDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.calendar = calendar
        formatter.setLocalizedDateFormatFromTemplate("yMd")
        return formatter
    }

    private enum FeatureCategory: Hashable {
        case raceSegment
        case surface
        case direction
        case length
        case weather
        case trackCondition
        case raceTime
        case ticketType
        case popularityBand
        case raceGrade
        case horseSelection
        case jockeyName
        case horseName
    }

    private struct FeatureSeed: Hashable {
        let label: String
        let category: FeatureCategory
    }

    private struct FeatureStat {
        let label: String
        let category: FeatureCategory
        var investment: Double
        var payout: Double
        var count: Int

        var loss: Double {
            investment - payout
        }

        var returnRate: Double {
            guard investment > 0 else { return 0 }
            return (payout / investment) * 100
        }
    }

    private func featureStats(in records: [BetRecord], seeds: (BetRecord) -> [FeatureSeed]) -> [FeatureStat] {
        var dictionary: [FeatureSeed: FeatureStat] = [:]

        for record in records {
            let investment = record.investment
            let payout = record.payout

            for seed in seeds(record) {
                if var stat = dictionary[seed] {
                    stat.investment += investment
                    stat.payout += payout
                    stat.count += 1
                    dictionary[seed] = stat
                } else {
                    dictionary[seed] = FeatureStat(
                        label: seed.label,
                        category: seed.category,
                        investment: investment,
                        payout: payout,
                        count: 1
                    )
                }
            }
        }

        return Array(dictionary.values)
    }

    private func raceFeatureSeeds(for record: BetRecord) -> [FeatureSeed] {
        var seeds: [FeatureSeed] = []

        if let segment = raceSegmentLabel(from: record.raceNumberText) {
            seeds.append(FeatureSeed(label: segment, category: .raceSegment))
        }

        if let surface = record.courseSurface?.trimmingCharacters(in: .whitespacesAndNewlines),
           !surface.isEmpty {
            seeds.append(FeatureSeed(label: surface, category: .surface))
        }

        if let direction = record.courseDirection?.trimmingCharacters(in: .whitespacesAndNewlines),
           !direction.isEmpty {
            seeds.append(FeatureSeed(label: direction, category: .direction))
        }

        if let length = courseLengthLabel(from: record.courseLength) {
            seeds.append(FeatureSeed(label: length, category: .length))
        }

        if let weather = record.weather?.trimmingCharacters(in: .whitespacesAndNewlines),
           !weather.isEmpty {
            seeds.append(FeatureSeed(label: weather, category: .weather))
        }

        if let condition = record.trackCondition?.trimmingCharacters(in: .whitespacesAndNewlines),
           !condition.isEmpty {
            seeds.append(FeatureSeed(label: condition, category: .trackCondition))
        }

        if let raceTime = record.raceTimeDetail?.trimmingCharacters(in: .whitespacesAndNewlines),
           !raceTime.isEmpty {
            seeds.append(FeatureSeed(label: "\(raceTime)発走", category: .raceTime))
        }

        return seeds
    }

    private func betFeatureSeeds(for record: BetRecord) -> [FeatureSeed] {
        var seeds: [FeatureSeed] = [
            FeatureSeed(label: record.ticketType.rawValue, category: .ticketType),
            FeatureSeed(label: "\(record.popularityBand.rawValue)狙い", category: .popularityBand),
            FeatureSeed(label: record.raceGrade.rawValue, category: .raceGrade)
        ]

        if let horseSelection = horseSelectionLabel(from: record.horseNumber) {
            seeds.append(FeatureSeed(label: horseSelection, category: .horseSelection))
        }

        if let jockey = record.jockeyName?.trimmingCharacters(in: .whitespacesAndNewlines),
           !jockey.isEmpty {
            seeds.append(FeatureSeed(label: "\(jockey)騎手", category: .jockeyName))
        }

        if let horse = record.horseName?.trimmingCharacters(in: .whitespacesAndNewlines),
           !horse.isEmpty {
            seeds.append(FeatureSeed(label: "\(horse)指名", category: .horseName))
        }

        return seeds
    }

    private func raceSegmentLabel(from text: String) -> String? {
        guard let number = Int(text.trimmingCharacters(in: .whitespacesAndNewlines)) else { return nil }
        switch number {
        case 1...4:
            return "序盤レース"
        case 5...8:
            return "中盤レース"
        case 9...12:
            return "後半レース"
        default:
            return nil
        }
    }

    private func courseLengthLabel(from text: String?) -> String? {
        guard let text else { return nil }
        let digits = text.filter { $0.isNumber }
        guard let length = Int(digits) else { return nil }
        switch length {
        case ...1400:
            return "短距離"
        case 1401...2000:
            return "中距離"
        default:
            return "長距離"
        }
    }

    private func horseSelectionLabel(from text: String?) -> String? {
        guard let text = text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return nil }
        let count = text.split(separator: "-").count
        guard count > 0 else { return nil }
        return "\(count)頭選び"
    }

    private func bestStat(in stats: [FeatureStat], categories: [FeatureCategory]) -> FeatureStat? {
        stats
            .filter { categories.contains($0.category) && $0.loss > 0 }
            .sorted { lhs, rhs in
                if lhs.loss == rhs.loss {
                    return lhs.count > rhs.count
                }
                return lhs.loss > rhs.loss
            }
            .first
    }

    private func buildRaceDescriptor(from stats: [FeatureStat]) -> String {
        let timing = bestStat(in: stats, categories: [.raceSegment])?.label
        let conditionStats = stats.filter {
            [.surface, .direction, .length, .weather, .trackCondition, .raceTime].contains($0.category)
        }
        let topConditions = conditionStats
            .filter { $0.loss > 0 }
            .sorted { lhs, rhs in
                if lhs.loss == rhs.loss {
                    return lhs.count > rhs.count
                }
                return lhs.loss > rhs.loss
            }
            .prefix(2)
            .map { $0.label }

        var descriptor = timing ?? ""
        if !descriptor.isEmpty {
            if !topConditions.isEmpty {
                let conditionText = topConditions.joined(separator: "・")
                descriptor += "（\(conditionText)）"
            }
        } else if !topConditions.isEmpty {
            let conditionText = topConditions.joined(separator: "・")
            descriptor = "\(conditionText)のレース"
        }

        return descriptor
    }

    private func buildBetDescriptor(from stats: [FeatureStat]) -> String {
        guard let ticket = bestStat(in: stats, categories: [.ticketType]) else { return "" }

        let secondary = bestStat(
            in: stats,
            categories: [.popularityBand, .raceGrade, .horseSelection, .jockeyName, .horseName]
        )

        if let secondary {
            switch secondary.category {
            case .raceGrade:
                return "\(ticket.label)で\(secondary.label)"
            default:
                return "\(ticket.label)の\(secondary.label)"
            }
        }

        return "\(ticket.label)"
    }

    private var worstPattern: LossPattern? {
        guard !records.isEmpty else { return nil }

        let grouped = Dictionary(grouping: records) {
            LossPatternKey(
                popularityBand: $0.popularityBand
            )
        }

        let patterns: [LossPattern] = grouped.compactMap { key, values in
            let invest = values.reduce(0) { $0 + $1.investment }
            let payout = values.reduce(0) { $0 + $1.payout }
            let loss = invest - payout
            guard loss > 0 else { return nil }

            let returnRate = invest > 0 ? (payout / invest) * 100 : 0
            let message = "\(key.popularityBand.rawValue) で最も負けています"

            return LossPattern(
                message: message,
                loss: loss,
                count: values.count,
                returnRate: returnRate
            )
        }

        return patterns.sorted { $0.loss > $1.loss }.first
    }

    private func optionalValue(_ text: String, isEnabled: Bool) -> String? {
        guard isEnabled else { return nil }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func optionalValue<Value: RawRepresentable>(_ value: Value?, isEnabled: Bool) -> String? where Value.RawValue == String {
        guard isEnabled, let value else { return nil }
        return value.rawValue
    }

    private func normalizeHorseSelection(maxSelection: Int) {
        if formState.horseNumbers.count > maxSelection {
            formState.horseNumbers = Array(formState.horseNumbers.prefix(maxSelection))
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

    private var toastView: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.white)
            Text("記録を追加しました")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.black.opacity(0.75), in: Capsule())
    }

    private func addRecord() {
        guard
            let investment = AmountFormatting.parseAmount(formState.investmentText)
        else { return }
        let payout = AmountFormatting.parseAmount(formState.payoutText) ?? 0

        normalizeHorseSelection(maxSelection: formState.ticketType.requiredHorseSelections)

        let horseNumberText: String? = {
            guard !formState.horseNumbers.isEmpty else { return nil }
            return formState.horseNumbers.map(String.init).joined(separator: "-")
        }()

        let record = BetRecord(
            createdAt: calendar.startOfDay(for: formState.selectedDate),
            ticketType: formState.ticketType,
            popularityBand: formState.popularityBand,
            raceGrade: formState.raceGrade,
            investment: investment,
            payout: payout,
            racecourse: optionalValue(formState.racecourse, isEnabled: showRacecourseField),
            raceNumber: String(formState.raceNumber),
            horseNumber: horseNumberText,
            jockeyName: optionalValue(formState.jockeyName, isEnabled: showJockeyField),
            horseName: optionalValue(formState.horseName, isEnabled: showHorseNameField),
            raceTimeDetail: optionalValue(formState.raceTimeDetail, isEnabled: showRaceTimeField),
            courseSurface: optionalValue(formState.courseSurface, isEnabled: showCourseSurfaceField),
            courseDirection: optionalValue(formState.courseDirection, isEnabled: showCourseDirectionField),
            courseLength: optionalValue(formState.courseLength, isEnabled: showCourseLengthField),
            weather: optionalValue(formState.weather, isEnabled: showWeatherField),
            trackCondition: optionalValue(formState.trackCondition, isEnabled: showTrackConditionField),
            memo: optionalValue(formState.memo, isEnabled: showMemoField)
        )

        withAnimation {
            modelContext.insert(record)
            formState.resetAmounts()
            focusedAmountField = nil
            showToast = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showToast = false
            }
        }
    }

    private func startEditing(_ record: BetRecord) {
        editState.load(from: record)
    }

    private func confirmDelete(_ record: BetRecord) {
        recordPendingDeletion = record
    }

    private func saveEditing() {
        guard
            let record = editState.record,
            let investment = AmountFormatting.parseAmount(editState.investmentText)
        else { return }
        let payout = AmountFormatting.parseAmount(editState.payoutText) ?? 0

        normalizeEditHorseSelection(maxSelection: editState.ticketType.requiredHorseSelections)

        withAnimation {
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
            focusedAmountField = nil
            editState.isPresented = false
        }
    }

    private func deleteRecord(_ record: BetRecord) {
        withAnimation {
            modelContext.delete(record)
            if editState.record == record {
                editState.isPresented = false
                editState.record = nil
            }
            recordPendingDeletion = nil
        }
    }

    private var deleteDialogBinding: Binding<Bool> {
        Binding(
            get: { recordPendingDeletion != nil },
            set: { isPresented in
                if !isPresented {
                    recordPendingDeletion = nil
                }
            }
        )
    }
}

#Preview {
    RecordsTabView(records: [])
        .modelContainer(previewContainer)
}

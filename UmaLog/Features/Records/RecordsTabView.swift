import SwiftData
import SwiftUI

struct RecordsTabView: View {
    @Environment(\.modelContext) private var modelContext

    let records: [BetRecord]

    @State private var formState = RecordFormState()
    @State private var editState = EditRecordState()
    @State private var showToast = false
    @FocusState private var focusedAmountField: AmountField?
    @AppStorage("prefersQuickEntry") private var prefersQuickEntry = true
    @AppStorage("showRacecourseField") private var showRacecourseField = false
    @AppStorage("showRaceNumberField") private var showRaceNumberField = false
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

    private let datePickerLocale = Locale(identifier: "ja_JP")

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
                        RecordHeaderSection()
                        SummarySection(
                            returnRateText: returnRateText,
                            returnRateColor: returnRateColor,
                            recordCount: records.count,
                            totalInvestment: AmountFormatting.currency(totalInvestment),
                            totalPayout: AmountFormatting.currency(totalPayout)
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
                            showRaceNumber: showRaceNumberField,
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
                            showTimeSlot: !showRaceTimeField,
                            fiveMinuteOptions: fiveMinuteOptions,
                            courseLengthOptions: RaceDistance.allCases,
                            courseDistanceFormatter: { $0.display },
                            jockeySuggestions: jockeySuggestions,
                            horseSuggestions: horseSuggestions,
                            onAdd: addRecord
                        )
                        HistorySection(
                            records: records,
                            historyDateFormatter: historyDateFormatter,
                            cardBackground: cardBackground,
                            currency: { AmountFormatting.currency($0) },
                            startEditing: startEditing(_:)
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
                    showRaceNumber: showRaceNumberField,
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
                    showTimeSlot: !showRaceTimeField,
                    fiveMinuteOptions: fiveMinuteOptions,
                    courseLengthOptions: RaceDistance.allCases,
                    courseDistanceFormatter: { $0.display },
                    jockeySuggestions: jockeySuggestions,
                    horseSuggestions: horseSuggestions,
                    onSave: saveEditing
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
        (AmountFormatting.parseAmount(formState.investmentText) ?? 0) > 0
    }

    private var returnRateText: String {
        guard totalInvestment > 0 else { return "— %" }
        return String(format: "%.0f%%", (totalPayout / totalInvestment) * 100)
    }

    private var returnRateColor: Color {
        guard totalInvestment > 0 else { return .white }
        return totalPayout >= totalInvestment ? .green : .red
    }

    private var totalInvestment: Double {
        records.reduce(0) { $0 + $1.investment }
    }

    private var totalPayout: Double {
        records.reduce(0) { $0 + $1.payout }
    }

    private var historyDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.calendar = calendar
        formatter.setLocalizedDateFormatFromTemplate("yMd")
        return formatter
    }

    private var worstPattern: LossPattern? {
        guard !records.isEmpty else { return nil }

        let grouped = Dictionary(grouping: records) {
            LossPatternKey(
                timeSlot: $0.timeSlot,
                popularityBand: $0.popularityBand
            )
        }

        let patterns: [LossPattern] = grouped.compactMap { key, values in
            let invest = values.reduce(0) { $0 + $1.investment }
            let payout = values.reduce(0) { $0 + $1.payout }
            let loss = invest - payout
            guard loss > 0 else { return nil }

            let returnRate = invest > 0 ? (payout / invest) * 100 : 0
            let message = "\(key.timeSlot.rawValue) × \(key.popularityBand.rawValue) が最も負けています"

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

    private func optionalValue<Value: RawRepresentable>(_ value: Value, isEnabled: Bool) -> String? where Value.RawValue == String {
        guard isEnabled else { return nil }
        return value.rawValue
    }

    private func preservedValue(from text: String, isEnabled: Bool, original: String?) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if isEnabled {
            return trimmed.isEmpty ? nil : trimmed
        } else {
            return original
        }
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
            let investment = AmountFormatting.parseAmount(formState.investmentText),
            let payout = AmountFormatting.parseAmount(formState.payoutText)
        else { return }

        let record = BetRecord(
            createdAt: calendar.startOfDay(for: formState.selectedDate),
            ticketType: formState.ticketType,
            popularityBand: formState.popularityBand,
            raceGrade: formState.raceGrade,
            timeSlot: formState.timeSlot,
            investment: investment,
            payout: payout,
            racecourse: optionalValue(formState.racecourse, isEnabled: showRacecourseField),
            raceNumber: optionalValue(String(formState.raceNumber), isEnabled: showRaceNumberField),
            horseNumber: optionalValue(String(formState.horseNumber), isEnabled: showHorseNumberField),
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

    private func saveEditing() {
        guard
            let record = editState.record,
            let investment = AmountFormatting.parseAmount(editState.investmentText),
            let payout = AmountFormatting.parseAmount(editState.payoutText)
        else { return }

        withAnimation {
            record.createdAt = calendar.startOfDay(for: editState.date)
            record.ticketType = editState.ticketType
            record.popularityBand = editState.popularityBand
            record.raceGrade = editState.raceGrade
            record.timeSlot = editState.timeSlot
            record.investment = investment
            record.payout = payout
            record.racecourse = preservedValue(from: editState.racecourse.rawValue, isEnabled: showRacecourseField, original: record.racecourse)
            record.raceNumber = preservedValue(from: String(editState.raceNumber), isEnabled: showRaceNumberField, original: record.raceNumber)
            record.horseNumber = preservedValue(from: String(editState.horseNumber), isEnabled: showHorseNumberField, original: record.horseNumber)
            record.jockeyName = preservedValue(from: editState.jockeyName, isEnabled: showJockeyField, original: record.jockeyName)
            record.horseName = preservedValue(from: editState.horseName, isEnabled: showHorseNameField, original: record.horseName)
            record.raceTimeDetail = preservedValue(from: editState.raceTimeDetail, isEnabled: showRaceTimeField, original: record.raceTimeDetail)
            record.courseSurface = preservedValue(from: editState.courseSurface.rawValue, isEnabled: showCourseSurfaceField, original: record.courseSurface)
            record.courseDirection = preservedValue(from: editState.courseDirection.rawValue, isEnabled: showCourseDirectionField, original: record.courseDirection)
            record.courseLength = preservedValue(from: editState.courseLength.rawValue, isEnabled: showCourseLengthField, original: record.courseLength)
            record.weather = preservedValue(from: editState.weather.rawValue, isEnabled: showWeatherField, original: record.weather)
            record.trackCondition = preservedValue(from: editState.trackCondition.rawValue, isEnabled: showTrackConditionField, original: record.trackCondition)
            record.memo = preservedValue(from: editState.memo, isEnabled: showMemoField, original: record.memo)
            focusedAmountField = nil
            editState.isPresented = false
        }
    }
}

#Preview {
    RecordsTabView(records: [])
        .modelContainer(previewContainer)
}

import SwiftUI

struct RecordHeaderSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("負け方に気づく、静かな競馬ログ")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text("感情の波で買っていないか、数字で振り返り。最小限の記録と一言分析で、続け方を整えます。")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
        }
    }
}

struct SummarySection: View {
    let returnRateText: String
    let returnRateColor: Color
    let recordCount: Int
    let totalInvestment: String
    let totalPayout: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今月のざっくりサマリー")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("回収率")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(returnRateText)
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundStyle(returnRateColor)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("記録したレース")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(recordCount)件")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                }

                HStack {
                    summaryStat(title: "投資合計", value: totalInvestment)
                    summaryStat(title: "払戻合計", value: totalPayout)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private func summaryStat(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AnalysisSection: View {
    let pattern: LossPattern?
    let cardBackground: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日の気づき")
                .font(.headline)
                .foregroundStyle(.white)

            if let pattern {
                VStack(alignment: .leading, spacing: 8) {
                    Text(pattern.message)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("同じ買い方で \(pattern.count) 件記録。回収率 \(pattern.returnRateString)。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(cardBackground, in: RoundedRectangle(cornerRadius: 16))
            } else {
                placeholderCard(text: "まだ記録がありません。まずは1レース、30秒で記録してみましょう。")
            }
        }
    }
}

struct RecordFormSection: View {
    @Binding var formState: RecordFormState
    let isValidInput: Bool
    let datePickerLocale: Locale
    let cardBackground: Color
    @FocusState.Binding var focusedAmountField: AmountField?
    let prefersQuickEntry: Bool
    let showRacecourse: Bool
    let showRaceNumber: Bool
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
    let showTimeSlot: Bool
    let fiveMinuteOptions: [String]
    let courseLengthOptions: [RaceDistance]
    let courseDistanceFormatter: (RaceDistance) -> String
    let jockeySuggestions: [String]
    let horseSuggestions: [String]
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("さくっと記録")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(spacing: 12) {
                dateField
                formPickers
                formAmounts
                if hasDetailedFields {
                    Divider()
                    detailFields
                }
                Button(action: onAdd) {
                    Label(prefersQuickEntry ? "サクッと記録を追加" : "詳細つきで記録を追加", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color("MainGreen", bundle: .main).opacity(0.9))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!isValidInput)
                .opacity(isValidInput ? 1 : 0.6)
            }
            .padding()
            .background(cardBackground, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var dateField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("日付（自動で今日をセット）")
                .font(.caption)
                .foregroundStyle(.secondary)
            DatePicker("日付", selection: $formState.selectedDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .environment(\.locale, datePickerLocale)
                .disabled(true)
                .opacity(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var formPickers: some View {
        VStack(alignment: .leading, spacing: 12) {
            pickerRow(title: "馬券種", selection: $formState.ticketType, options: TicketType.allCases)
            pickerRow(title: "人気帯", selection: $formState.popularityBand, options: PopularityBand.allCases)
            pickerRow(title: "レース格", selection: $formState.raceGrade, options: RaceGrade.allCases)
            if showTimeSlot {
                pickerRow(title: "時間帯", selection: $formState.timeSlot, options: TimeSlot.allCases)
            }
        }
    }

    private var formAmounts: some View {
        HStack(spacing: 12) {
            amountField(title: "投資額", placeholder: "例: 1200", text: $formState.investmentText, focus: .investment, focusedAmountField: $focusedAmountField)
            amountField(title: "払戻額", placeholder: "例: 800", text: $formState.payoutText, focus: .payout, focusedAmountField: $focusedAmountField)
        }
    }

    private var detailFields: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("必要に応じて自由に残せる項目")
                .font(.subheadline.weight(.semibold))
            if showRacecourse {
                MarkCardCourseSelector(title: "競馬場名", selection: $formState.racecourse)
            }
            if showRaceNumber {
                MarkCardRaceNumberSelector(title: "レース番号", selection: $formState.raceNumber)
            }
            MarkCardTicketTypeSelector(title: "式別", selection: $formState.ticketType)
            if showHorseNumber {
                numberPicker(title: "馬番", selection: $formState.horseNumber, range: 1...18, unit: "番")
            }
            if showJockey {
                suggestionField(title: "騎手", placeholder: "例: C.ルメール", text: $formState.jockeyName, suggestions: jockeySuggestions)
            }
            if showHorseName {
                suggestionField(title: "馬名", placeholder: "例: ○○エース", text: $formState.horseName, suggestions: horseSuggestions)
            }
            if showRaceTime {
                selectionPicker(title: "発走予定（5分刻み）", selection: $formState.raceTimeDetail, options: fiveMinuteOptions) {
                    Text($0.isEmpty ? "未選択" : $0).tag($0)
                }
            }
            if showCourseSurface {
                selectionPicker(title: "コース（芝・ダートなど）", selection: $formState.courseSurface, options: CourseSurface.allCases) {
                    Text($0.rawValue).tag($0)
                }
            }
            if showCourseDirection {
                selectionPicker(title: "コースの向き", selection: $formState.courseDirection, options: CourseDirection.allCases) {
                    Text($0.rawValue).tag($0)
                }
            }
            if showCourseLength {
                selectionPicker(title: "コースの長さ", selection: $formState.courseLength, options: courseLengthOptions) {
                    Text(courseDistanceFormatter($0)).tag($0)
                }
            }
            if showWeather {
                selectionPicker(title: "天気", selection: $formState.weather, options: Weather.allCases) {
                    Text($0.rawValue).tag($0)
                }
            }
            if showTrackCondition {
                selectionPicker(title: "馬場状態", selection: $formState.trackCondition, options: TrackCondition.allCases) {
                    Text($0.rawValue).tag($0)
                }
            }
            if showMemo {
                detailTextField(title: "ひと言メモ", placeholder: "例: スタートで出負け", text: $formState.memo)
            }
        }
    }

    private var hasDetailedFields: Bool { true }
}

struct HistorySection: View {
    let records: [BetRecord]
    let historyDateFormatter: DateFormatter
    let cardBackground: Color
    let currency: (Double) -> String
    let startEditing: (BetRecord) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("記録一覧")
                .font(.headline)
                .foregroundStyle(.white)

            if records.isEmpty {
                placeholderCard(text: "まだ履歴がありません。負けパターンを溜めて、癖を見つけましょう。")
            } else {
                VStack(spacing: 12) {
                    ForEach(records) { record in
                        Button {
                            startEditing(record)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("\(record.timeSlot.rawValue) × \(record.popularityBand.rawValue)")
                                        .font(.headline)
                                    Spacer()
                                    Text(historyDateFormatter.string(from: record.createdAt))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Text("\(record.ticketType.rawValue)・\(record.raceGrade.rawValue)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                ForEach(Array(detailLines(for: record).prefix(2).enumerated()), id: \.offset) { _, line in
                                    Text(line)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                HStack {
                                    Label(currency(record.investment), systemImage: "arrow.down.right")
                                        .foregroundStyle(.primary)
                                    Label(currency(record.payout), systemImage: "arrow.up.right")
                                        .foregroundStyle(.green)
                                    Spacer()
                                    Text("回収率 \(record.returnRate, specifier: "%.0f")%")
                                        .font(.caption.weight(.semibold))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(.ultraThinMaterial, in: Capsule())
                                }
                            }
                            .padding()
                            .background(cardBackground, in: RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.bottom, 24)
    }
}

struct EditRecordSheet: View {
    @Binding var editState: EditRecordState
    let datePickerLocale: Locale
    @FocusState.Binding var focusedAmountField: AmountField?
    let showRacecourse: Bool
    let showRaceNumber: Bool
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
    let showTimeSlot: Bool
    let fiveMinuteOptions: [String]
    let courseLengthOptions: [RaceDistance]
    let courseDistanceFormatter: (RaceDistance) -> String
    let jockeySuggestions: [String]
    let horseSuggestions: [String]
    let onSave: () -> Void

    private var existingRacecourse: String {
        editState.record?.racecourse ?? ""
    }

    private var existingRaceNumber: String {
        editState.record?.raceNumber ?? ""
    }

    private var existingHorseNumber: String {
        editState.record?.horseNumber ?? ""
    }

    private var existingRaceTime: String {
        editState.record?.raceTimeDetail ?? ""
    }

    private var existingCourseLength: String {
        editState.record?.courseLength ?? ""
    }

    private var existingMemo: String {
        editState.record?.memo ?? ""
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("日付（自動で今日をセット）")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        DatePicker("日付", selection: $editState.date, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .environment(\.locale, datePickerLocale)
                            .disabled(true)
                            .opacity(0.7)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        pickerRow(title: "人気帯", selection: $editState.popularityBand, options: PopularityBand.allCases)
                        pickerRow(title: "レース格", selection: $editState.raceGrade, options: RaceGrade.allCases)
                        if showTimeSlot {
                            pickerRow(title: "時間帯", selection: $editState.timeSlot, options: TimeSlot.allCases)
                        }
                    }

                    HStack(spacing: 12) {
                        amountField(title: "投資額", placeholder: "例: 1200", text: $editState.investmentText, focus: .editInvestment, focusedAmountField: $focusedAmountField)
                        amountField(title: "払戻額", placeholder: "例: 800", text: $editState.payoutText, focus: .editPayout, focusedAmountField: $focusedAmountField)
                    }

                    if hasDetailedFields {
                        Divider()
                        VStack(alignment: .leading, spacing: 10) {
                            Text("詳細入力（任意）")
                                .font(.subheadline.weight(.semibold))
                            if showRacecourse || !existingRacecourse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                MarkCardCourseSelector(title: "競馬場名", selection: $editState.racecourse)
                            }
                            if showRaceNumber || !existingRaceNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                MarkCardRaceNumberSelector(title: "レース番号", selection: $editState.raceNumber)
                            }
                            MarkCardTicketTypeSelector(title: "式別", selection: $editState.ticketType)
                            if showHorseNumber || !existingHorseNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                numberPicker(title: "馬番", selection: $editState.horseNumber, range: 1...18, unit: "番")
                            }
                            if showJockey || !editState.jockeyName.isEmpty {
                                suggestionField(title: "騎手", placeholder: "例: C.ルメール", text: $editState.jockeyName, suggestions: jockeySuggestions)
                            }
                            if showHorseName || !editState.horseName.isEmpty {
                                suggestionField(title: "馬名", placeholder: "例: ○○エース", text: $editState.horseName, suggestions: horseSuggestions)
                            }
                            if showRaceTime || !existingRaceTime.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                selectionPicker(title: "発走予定（5分刻み）", selection: $editState.raceTimeDetail, options: fiveMinuteOptions) {
                                    Text($0.isEmpty ? "未選択" : $0).tag($0)
                                }
                            }
                            if showCourseSurface {
                                selectionPicker(title: "コース（芝・ダートなど）", selection: $editState.courseSurface, options: CourseSurface.allCases) {
                                    Text($0.rawValue).tag($0)
                                }
                            }
                            if showCourseDirection {
                                selectionPicker(title: "コースの向き", selection: $editState.courseDirection, options: CourseDirection.allCases) {
                                    Text($0.rawValue).tag($0)
                                }
                            }
                            if showCourseLength || !existingCourseLength.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                selectionPicker(title: "コースの長さ", selection: $editState.courseLength, options: courseLengthOptions) {
                                    Text(courseDistanceFormatter($0)).tag($0)
                                }
                            }
                            if showWeather {
                                selectionPicker(title: "天気", selection: $editState.weather, options: Weather.allCases) {
                                    Text($0.rawValue).tag($0)
                                }
                            }
                            if showTrackCondition {
                                selectionPicker(title: "馬場状態", selection: $editState.trackCondition, options: TrackCondition.allCases) {
                                    Text($0.rawValue).tag($0)
                                }
                            }
                            if showMemo || !existingMemo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                detailTextField(title: "ひと言メモ", placeholder: "例: スタートで出負け", text: $editState.memo)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("記録を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        editState.isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        onSave()
                    }
                    .disabled(!editState.isValid)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("閉じる") {
                        focusedAmountField = nil
                    }
                }
            }
        }
    }

    private func pickerRow<Option: Identifiable & RawRepresentable & Hashable>(
        title: String,
        selection: Binding<Option>,
        options: [Option]
    ) -> some View where Option.RawValue == String {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Picker(title, selection: selection) {
                ForEach(options) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var hasDetailedFields: Bool { true }

}

private func pickerRow<Option: Identifiable & RawRepresentable & Hashable>(
    title: String,
    selection: Binding<Option>,
    options: [Option]
) -> some View where Option.RawValue == String {
    VStack(alignment: .leading, spacing: 6) {
        Text(title)
            .font(.caption)
            .foregroundStyle(.secondary)
        Picker(title, selection: selection) {
            ForEach(options) { option in
                Text(option.rawValue).tag(option)
            }
        }
        .pickerStyle(.segmented)
    }
}

private func detailTextField(title: String, placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(title)
            .font(.caption)
            .foregroundStyle(.secondary)
        TextField(placeholder, text: text)
            .textFieldStyle(.roundedBorder)
            .keyboardType(keyboardType)
    }
}

private func numberPicker(title: String, selection: Binding<Int>, range: ClosedRange<Int>, unit: String) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(title)
            .font(.caption)
            .foregroundStyle(.secondary)
        Picker(title, selection: selection) {
            ForEach(Array(range), id: \.self) { value in
                Text("\(value)\(unit)").tag(value)
            }
        }
        .pickerStyle(.menu)
    }
}

private func selectionPicker<Option: Hashable & Identifiable>(
    title: String,
    selection: Binding<Option>,
    options: [Option],
    @ViewBuilder label: @escaping (Option) -> some View
) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(title)
            .font(.caption)
            .foregroundStyle(.secondary)
        Picker(title, selection: selection) {
            ForEach(options) { option in
                label(option)
            }
        }
        .pickerStyle(.menu)
    }
}

private func selectionPicker(
    title: String,
    selection: Binding<String>,
    options: [String],
    @ViewBuilder label: @escaping (String) -> some View
) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(title)
            .font(.caption)
            .foregroundStyle(.secondary)
        Picker(title, selection: selection) {
            ForEach(options, id: \.self) { option in
                label(option)
            }
        }
        .pickerStyle(.menu)
    }
}

private func suggestionField(title: String, placeholder: String, text: Binding<String>, suggestions: [String]) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(title)
            .font(.caption)
            .foregroundStyle(.secondary)
        HStack(spacing: 8) {
            TextField(placeholder, text: text)
                .textFieldStyle(.roundedBorder)
            if !suggestions.isEmpty {
                Menu {
                    ForEach(suggestions, id: \.self) { item in
                        Button(item) {
                            text.wrappedValue = item
                        }
                    }
                } label: {
                    Image(systemName: "text.badge.plus")
                        .padding(8)
                        .background(Color(.systemGray5), in: Circle())
                }
            }
        }
    }
}

private struct MarkCardRaceNumberSelector: View {
    let title: String
    @Binding var selection: Int

    private let numbers: [Int] = Array(1...12)

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(numbers, id: \.self) { number in
                        Button {
                            selection = number
                        } label: {
                            Text("\(number)")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 4)
                                .frame(width: 22, height: 46)
                                .background(selection == number ? Color("MainGreen", bundle: .main).opacity(0.9) : Color(.secondarySystemBackground))
                                .foregroundStyle(selection == number ? Color.white : Color.primary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selection == number ? Color("MainGreen", bundle: .main) : Color(.separator), lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }
}

private struct MarkCardCourseSelector: View {
    let title: String
    @Binding var selection: Racecourse

    private let orderedCourses: [Racecourse] = [
        .nakayama, .tokyo, .kyoto, .hanshin, .fukushima,
        .niigata, .chukyo, .kokura, .sapporo, .hakodate
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(orderedCourses) { course in
                        Button {
                            selection = course
                        } label: {
                            VStack(spacing: 6) {
                                Text(verticalLabel(for: course.rawValue))
                                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .frame(maxHeight: .infinity)
                            }
                            .padding(.vertical, 5)
                            .padding(.horizontal, 4)
                            .frame(width: 24, height: 46)
                            .background(selection == course ? Color("MainGreen", bundle: .main).opacity(0.9) : Color(.secondarySystemBackground))
                            .foregroundStyle(selection == course ? Color.white : Color.primary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selection == course ? Color("MainGreen", bundle: .main) : Color(.separator), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }

    private func verticalLabel(for text: String) -> String {
        text.map { String($0) }.joined(separator: "\n")
    }
}

private struct MarkCardTicketTypeSelector: View {
    let title: String
    @Binding var selection: TicketType

    private let orderedTypes: [TicketType] = [
        .win, .place, .bracketQuinella, .quinella, .exacta, .wide, .trio, .trifecta
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(orderedTypes) { type in
                        Button {
                            selection = type
                        } label: {
                            VStack(spacing: 6) {
                                Text(verticalLabel(for: type.rawValue))
                                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .frame(maxHeight: .infinity)
                            }
                            .padding(.vertical, 5)
                            .padding(.horizontal, 4)
                            .frame(width: 24, height: 46)
                            .background(selection == type ? Color("MainGreen", bundle: .main).opacity(0.9) : Color(.secondarySystemBackground))
                            .foregroundStyle(selection == type ? Color.white : Color.primary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selection == type ? Color("MainGreen", bundle: .main) : Color(.separator), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }

    private func verticalLabel(for text: String) -> String {
        text.map { String($0) }.joined(separator: "\n")
    }
}

private func amountField(
    title: String,
    placeholder: String,
    text: Binding<String>,
    focus: AmountField,
    focusedAmountField: FocusState<AmountField?>.Binding
) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(title)
            .font(.caption)
            .foregroundStyle(.secondary)
        TextField(placeholder, text: text)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.numberPad)
            .focused(focusedAmountField, equals: focus)
    }
    .frame(maxWidth: .infinity)
}

private func placeholderCard(text: String) -> some View {
    Text(text)
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
}

private func detailLines(for record: BetRecord) -> [String] {
    var lines: [String] = []

    let placeLine = [record.racecourse, record.raceNumber.map { "\($0)" }]
        .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
        .joined(separator: " / ")
    if !placeLine.isEmpty {
        lines.append(placeLine)
    }

    let horseLine = [record.horseNumber.map { "\($0)" }, record.horseName, record.jockeyName]
        .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
        .joined(separator: " / ")
    if !horseLine.isEmpty {
        lines.append(horseLine)
    }

    let distance = record.courseLength.flatMap { value -> String? in
        guard !value.isEmpty else { return nil }
        if value.hasSuffix("m") { return value }
        if Int(value) != nil { return "\(value)m" }
        return value
    }

    let courseLine = [record.raceTimeDetail, record.courseSurface, record.courseDirection, distance]
        .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
        .joined(separator: " / ")
    if !courseLine.isEmpty {
        lines.append(courseLine)
    }

    let conditionLine = [record.weather, record.trackCondition]
        .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
        .joined(separator: " / ")
    if !conditionLine.isEmpty {
        lines.append(conditionLine)
    }

    if let memo = record.memo?.trimmingCharacters(in: .whitespacesAndNewlines), !memo.isEmpty {
        lines.append(memo)
    }

    return lines
}

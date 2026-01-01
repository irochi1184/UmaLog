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

struct InputSettingsSection: View {
    @Binding var prefersQuickEntry: Bool
    @Binding var showRacecourse: Bool
    @Binding var showRaceNumber: Bool
    @Binding var showHorseNumber: Bool
    @Binding var showJockey: Bool
    @Binding var showHorseName: Bool
    @Binding var showRaceTime: Bool
    @Binding var showCourse: Bool
    @Binding var showCourseLength: Bool
    @Binding var showMemo: Bool
    let cardBackground: Color
    let onSelectQuick: () -> Void
    let onSelectDetailed: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("入力項目のカスタマイズ")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 12) {
                Text("サクッと記録モードなら最低限のみ、がっつり記録モードなら詳細をすべて出し、好みに合わせてチェックを変えられます。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    modeButton(title: "サクッと記録", isSelected: prefersQuickEntry) {
                        prefersQuickEntry = true
                        onSelectQuick()
                    }
                    modeButton(title: "がっつり記録", isSelected: !prefersQuickEntry) {
                        prefersQuickEntry = false
                        onSelectDetailed()
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    toggleRow(title: "競馬場名", isOn: $showRacecourse)
                    toggleRow(title: "何レースか", isOn: $showRaceNumber)
                    toggleRow(title: "馬番", isOn: $showHorseNumber)
                    toggleRow(title: "騎手", isOn: $showJockey)
                    toggleRow(title: "馬名", isOn: $showHorseName)
                    toggleRow(title: "発走予定や詳細時間", isOn: $showRaceTime)
                    toggleRow(title: "コース種類（芝・ダートなど）", isOn: $showCourse)
                    toggleRow(title: "コースの長さ", isOn: $showCourseLength)
                    toggleRow(title: "ひと言メモ", isOn: $showMemo)
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
    let showCourse: Bool
    let showCourseLength: Bool
    let showMemo: Bool
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
            Text("日付")
                .font(.caption)
                .foregroundStyle(.secondary)
            DatePicker("日付", selection: $formState.selectedDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .environment(\.locale, datePickerLocale)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var formPickers: some View {
        VStack(alignment: .leading, spacing: 12) {
            pickerRow(title: "馬券種", selection: $formState.ticketType, options: TicketType.allCases)
            pickerRow(title: "人気帯", selection: $formState.popularityBand, options: PopularityBand.allCases)
            pickerRow(title: "レース格", selection: $formState.raceGrade, options: RaceGrade.allCases)
            pickerRow(title: "時間帯", selection: $formState.timeSlot, options: TimeSlot.allCases)
        }
    }

    private var formAmounts: some View {
        HStack(spacing: 12) {
            amountField(title: "投資額", placeholder: "例: 1200", text: $formState.investmentText, focus: .investment)
            amountField(title: "払戻額", placeholder: "例: 800", text: $formState.payoutText, focus: .payout)
        }
    }

    private var detailFields: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("必要に応じて自由に残せる項目")
                .font(.subheadline.weight(.semibold))
            if showRacecourse {
                detailTextField(title: "競馬場名", placeholder: "例: 東京競馬場", text: $formState.racecourse)
            }
            if showRaceNumber {
                detailTextField(title: "何レースか", placeholder: "例: 11R", text: $formState.raceNumber)
            }
            if showHorseNumber {
                detailTextField(title: "馬番", placeholder: "例: 7", text: $formState.horseNumber, keyboardType: .numberPad)
            }
            if showJockey {
                detailTextField(title: "騎手", placeholder: "例: C.ルメール", text: $formState.jockeyName)
            }
            if showHorseName {
                detailTextField(title: "馬名", placeholder: "例: ○○エース", text: $formState.horseName)
            }
            if showRaceTime {
                detailTextField(title: "発走予定や詳細時間", placeholder: "例: 15:05発走", text: $formState.raceTimeDetail)
            }
            if showCourse {
                detailTextField(title: "コース（芝・ダートなど）", placeholder: "例: 芝・右回り", text: $formState.course)
            }
            if showCourseLength {
                detailTextField(title: "コースの長さ", placeholder: "例: 1600m", text: $formState.courseLength, keyboardType: .numbersAndPunctuation)
            }
            if showMemo {
                detailTextField(title: "ひと言メモ", placeholder: "例: スタートで出負け", text: $formState.memo)
            }
        }
    }

    private var hasDetailedFields: Bool {
        showRacecourse || showRaceNumber || showHorseNumber || showJockey || showHorseName || showRaceTime || showCourse || showCourseLength || showMemo
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

    private func amountField(title: String, placeholder: String, text: Binding<String>, focus: AmountField) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField(placeholder, text: text)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .focused($focusedAmountField, equals: focus)
        }
        .frame(maxWidth: .infinity)
    }
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
    let showCourse: Bool
    let showCourseLength: Bool
    let showMemo: Bool
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("日付")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        DatePicker("日付", selection: $editState.date, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .environment(\.locale, datePickerLocale)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        pickerRow(title: "馬券種", selection: $editState.ticketType, options: TicketType.allCases)
                        pickerRow(title: "人気帯", selection: $editState.popularityBand, options: PopularityBand.allCases)
                        pickerRow(title: "レース格", selection: $editState.raceGrade, options: RaceGrade.allCases)
                        pickerRow(title: "時間帯", selection: $editState.timeSlot, options: TimeSlot.allCases)
                    }

                    HStack(spacing: 12) {
                        amountField(title: "投資額", placeholder: "例: 1200", text: $editState.investmentText, focus: .editInvestment)
                        amountField(title: "払戻額", placeholder: "例: 800", text: $editState.payoutText, focus: .editPayout)
                    }

                    if hasDetailedFields {
                        Divider()
                        VStack(alignment: .leading, spacing: 10) {
                            Text("詳細入力（任意）")
                                .font(.subheadline.weight(.semibold))
                            if showRacecourse || !editState.racecourse.isEmpty {
                                detailTextField(title: "競馬場名", placeholder: "例: 東京競馬場", text: $editState.racecourse)
                            }
                            if showRaceNumber || !editState.raceNumber.isEmpty {
                                detailTextField(title: "何レースか", placeholder: "例: 11R", text: $editState.raceNumber)
                            }
                            if showHorseNumber || !editState.horseNumber.isEmpty {
                                detailTextField(title: "馬番", placeholder: "例: 7", text: $editState.horseNumber, keyboardType: .numberPad)
                            }
                            if showJockey || !editState.jockeyName.isEmpty {
                                detailTextField(title: "騎手", placeholder: "例: C.ルメール", text: $editState.jockeyName)
                            }
                            if showHorseName || !editState.horseName.isEmpty {
                                detailTextField(title: "馬名", placeholder: "例: ○○エース", text: $editState.horseName)
                            }
                            if showRaceTime || !editState.raceTimeDetail.isEmpty {
                                detailTextField(title: "発走予定や詳細時間", placeholder: "例: 15:05発走", text: $editState.raceTimeDetail)
                            }
                            if showCourse || !editState.course.isEmpty {
                                detailTextField(title: "コース（芝・ダートなど）", placeholder: "例: 芝・右回り", text: $editState.course)
                            }
                            if showCourseLength || !editState.courseLength.isEmpty {
                                detailTextField(title: "コースの長さ", placeholder: "例: 1600m", text: $editState.courseLength, keyboardType: .numbersAndPunctuation)
                            }
                            if showMemo || !editState.memo.isEmpty {
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

    private var hasDetailedFields: Bool {
        showRacecourse
            || showRaceNumber
            || showHorseNumber
            || showJockey
            || showHorseName
            || showRaceTime
            || showCourse
            || showCourseLength
            || showMemo
            || !editState.racecourse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !editState.raceNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !editState.horseNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !editState.jockeyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !editState.horseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !editState.raceTimeDetail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !editState.course.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !editState.courseLength.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !editState.memo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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

    private func amountField(title: String, placeholder: String, text: Binding<String>, focus: AmountField) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField(placeholder, text: text)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .focused($focusedAmountField, equals: focus)
        }
        .frame(maxWidth: .infinity)
    }
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

    let placeLine = [record.racecourse, record.raceNumber]
        .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
        .joined(separator: " / ")
    if !placeLine.isEmpty {
        lines.append(placeLine)
    }

    let horseLine = [record.horseNumber, record.horseName, record.jockeyName]
        .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
        .joined(separator: " / ")
    if !horseLine.isEmpty {
        lines.append(horseLine)
    }

    let courseLine = [record.raceTimeDetail, record.course, record.courseLength]
        .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
        .joined(separator: " / ")
    if !courseLine.isEmpty {
        lines.append(courseLine)
    }

    if let memo = record.memo?.trimmingCharacters(in: .whitespacesAndNewlines), !memo.isEmpty {
        lines.append(memo)
    }

    return lines
}

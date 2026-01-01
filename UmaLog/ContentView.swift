//
//  ContentView.swift
//  UmaLog
//
//  Created by 有田健一郎 on 2025/12/31.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BetRecord.createdAt, order: .reverse) private var records: [BetRecord]

    @State private var ticketType: TicketType = .win
    @State private var popularityBand: PopularityBand = .favorite
    @State private var raceGrade: RaceGrade = .flat
    @State private var timeSlot: TimeSlot = .afternoon
    @State private var selectedDate: Date = .now
    @State private var displayedMonth: Date = Calendar.autoupdatingCurrent.date(
        from: Calendar.autoupdatingCurrent.dateComponents([.year, .month], from: Date())
    ) ?? Date()
    @State private var investmentText: String = ""
    @State private var payoutText: String = ""
    @State private var editingRecord: BetRecord?
    @State private var editingDate: Date = .now
    @State private var editingTicketType: TicketType = .win
    @State private var editingPopularityBand: PopularityBand = .favorite
    @State private var editingRaceGrade: RaceGrade = .flat
    @State private var editingTimeSlot: TimeSlot = .afternoon
    @State private var editingInvestmentText: String = ""
    @State private var editingPayoutText: String = ""
    @State private var isEditing: Bool = false
    @State private var showToast: Bool = false

    @FocusState private var focusedAmountField: AmountField?

    private var cardBackground: Color {
        Color(.secondarySystemBackground)
    }

    private var calendar: Calendar {
        var calendar = Calendar.autoupdatingCurrent
        calendar.locale = .autoupdatingCurrent
        return calendar
    }

    private var amountFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.usesGroupingSeparator = true
        return formatter
    }

    private var plainAmountFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.usesGroupingSeparator = false
        return formatter
    }

    var body: some View {
        TabView {
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
                            summarySection
                            analysisSection
                            recordForm
                            historySection
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
                .sheet(isPresented: $isEditing) {
                    editSheet
                }
                .overlay(alignment: .bottom) {
                    if showToast {
                        toastView
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .padding(.horizontal)
                            .padding(.bottom, 24)
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    if isKeyboardActive {
                        keyboardDismissBar
                    }
                }
            }
            .tabItem {
                Label("記録", systemImage: "square.and.pencil")
            }

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
                            calendarHeader
                            calendarSection
                        }
                        .padding()
                    }
                }
                .navigationTitle("カレンダー")
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("カレンダー", systemImage: "calendar")
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("負け方に気づく、静かな競馬ログ")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text("感情の波で買っていないか、数字で振り返り。最小限の記録と一言分析で、続け方を整えます。")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
        }
    }

    private var summarySection: some View {
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
                        Text("\(records.count)件")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                }

                HStack {
                    summaryStat(title: "投資合計", value: currency(totalInvestment))
                    summaryStat(title: "払戻合計", value: currency(totalPayout))
                }
            }
            .padding()
            .background(cardBackground, in: RoundedRectangle(cornerRadius: 16))
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

    private var analysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日の気づき")
                .font(.headline)
                .foregroundStyle(.white)

            if let pattern = worstPattern {
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

    private var recordForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("さくっと記録")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(spacing: 12) {
                dateField
                formPickers
                formAmounts
                Button(action: addRecord) {
                    Label("記録を追加", systemImage: "plus.circle.fill")
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

    private var editSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("日付")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        DatePicker("日付", selection: $editingDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .environment(\.locale, .autoupdatingCurrent)
                            .onChange(of: editingDate) { _, newValue in
                                displayedMonth = newValue
                            }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        pickerRow(title: "馬券種", selection: $editingTicketType, options: TicketType.allCases)
                        pickerRow(title: "人気帯", selection: $editingPopularityBand, options: PopularityBand.allCases)
                        pickerRow(title: "レース格", selection: $editingRaceGrade, options: RaceGrade.allCases)
                        pickerRow(title: "時間帯", selection: $editingTimeSlot, options: TimeSlot.allCases)
                    }

                    HStack(spacing: 12) {
                        amountField(title: "投資額", placeholder: "例: 1200", text: $editingInvestmentText, focus: .editInvestment)
                        amountField(title: "払戻額", placeholder: "例: 800", text: $editingPayoutText, focus: .editPayout)
                    }
                }
                .padding()
            }
            .navigationTitle("記録を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        isEditing = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveEditing()
                    }
                    .disabled(!isEditingValid)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("閉じる") {
                        focusedAmountField = nil
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if isKeyboardActive {
                    keyboardDismissBar
                }
            }
        }
    }

    private var formPickers: some View {
        VStack(alignment: .leading, spacing: 12) {
            pickerRow(title: "馬券種", selection: $ticketType, options: TicketType.allCases)
            pickerRow(title: "人気帯", selection: $popularityBand, options: PopularityBand.allCases)
            pickerRow(title: "レース格", selection: $raceGrade, options: RaceGrade.allCases)
            pickerRow(title: "時間帯", selection: $timeSlot, options: TimeSlot.allCases)
        }
    }

    private var formAmounts: some View {
        HStack(spacing: 12) {
            amountField(title: "投資額", placeholder: "例: 1200", text: $investmentText, focus: .investment)
            amountField(title: "払戻額", placeholder: "例: 800", text: $payoutText, focus: .payout)
        }
    }

    private var historySection: some View {
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

    private func addRecord() {
        guard
            let investment = parseAmount(investmentText),
            let payout = parseAmount(payoutText)
        else { return }

        let record = BetRecord(
            createdAt: calendar.startOfDay(for: selectedDate),
            ticketType: ticketType,
            popularityBand: popularityBand,
            raceGrade: raceGrade,
            timeSlot: timeSlot,
            investment: investment,
            payout: payout
        )

        withAnimation {
            modelContext.insert(record)
            investmentText = ""
            payoutText = ""
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
        editingRecord = record
        editingDate = record.createdAt
        editingTicketType = record.ticketType
        editingPopularityBand = record.popularityBand
        editingRaceGrade = record.raceGrade
        editingTimeSlot = record.timeSlot
        editingInvestmentText = plainAmount(record.investment)
        editingPayoutText = plainAmount(record.payout)
        isEditing = true
    }

    private func saveEditing() {
        guard
            let record = editingRecord,
            let investment = parseAmount(editingInvestmentText),
            let payout = parseAmount(editingPayoutText)
        else { return }

        withAnimation {
            record.createdAt = calendar.startOfDay(for: editingDate)
            record.ticketType = editingTicketType
            record.popularityBand = editingPopularityBand
            record.raceGrade = editingRaceGrade
            record.timeSlot = editingTimeSlot
            record.investment = investment
            record.payout = payout
            focusedAmountField = nil
            isEditing = false
        }
    }

    private var isValidInput: Bool {
        (parseAmount(investmentText) ?? 0) > 0
    }

    private var isEditingValid: Bool {
        (parseAmount(editingInvestmentText) ?? 0) > 0 && editingRecord != nil
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

    private var dateField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("日付")
                .font(.caption)
                .foregroundStyle(.secondary)
            DatePicker("日付", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .environment(\.locale, .autoupdatingCurrent)
                .onChange(of: selectedDate) { _, newValue in
                    displayedMonth = newValue
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

    private func placeholderCard(text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground, in: RoundedRectangle(cornerRadius: 16))
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

    private func currency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "JPY"
        formatter.maximumFractionDigits = 0
        formatter.locale = .autoupdatingCurrent
        return formatter.string(from: NSNumber(value: value)) ?? "¥0"
    }

    private func formattedAmount(_ value: Double) -> String {
        return amountFormatter.string(from: NSNumber(value: value)) ?? ""
    }

    private func plainAmount(_ value: Double) -> String {
        return plainAmountFormatter.string(from: NSNumber(value: value)) ?? ""
    }

    private func parseAmount(_ text: String) -> Double? {
        if let number = amountFormatter.number(from: text)?.doubleValue {
            return number
        }
        let grouping = amountFormatter.groupingSeparator ?? ","
        let sanitized = text.replacingOccurrences(of: grouping, with: "").replacingOccurrences(of: " ", with: "")
        return Double(sanitized)
    }

    private var currentMonthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
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

    private var historyDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.calendar = calendar
        formatter.setLocalizedDateFormatFromTemplate("yMd")
        return formatter
    }

    private var calendarDays: [Date?] {
        let dates = datesInMonth(for: displayedMonth)
        let offset = weekdayOffset(for: displayedMonth)
        return Array(repeating: nil, count: offset) + dates
    }

    private var keyboardDismissBar: some View {
        HStack {
            Spacer()
            Button {
                focusedAmountField = nil
            } label: {
                Label("閉じる", systemImage: "keyboard.chevron.compact.down")
                    .font(.body.weight(.semibold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            Spacer()
        }
        .background(.thinMaterial)
    }

    private var isKeyboardActive: Bool {
        focusedAmountField != nil
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

    private func changeMonth(by value: Int) {
        let baseMonth = startOfMonth(for: displayedMonth)

        if let next = calendar.date(byAdding: .month, value: value, to: baseMonth) {
            let normalized = startOfMonth(for: next)
            displayedMonth = normalized

            let day = calendar.component(.day, from: selectedDate)
            let maxDay = calendar.range(of: .day, in: .month, for: normalized)?.count ?? day
            let clampedDay = min(day, maxDay)

            if let alignedDate = calendar.date(
                bySetting: .day,
                value: clampedDay,
                of: normalized
            ) {
                selectedDate = alignedDate
            } else {
                selectedDate = normalized
            }
        }
    }

    private func startOfMonth(for date: Date) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }

    private func calendarCell(for date: Date) -> some View {
        let net = dailyNetTotals[calendar.startOfDay(for: date)]
        let isToday = calendar.isDateInToday(date)
        let background: Color

        if let net {
            background = net > 0 ? Color.green.opacity(0.15) : (net < 0 ? Color.red.opacity(0.15) : Color.gray.opacity(0.12))
        } else {
            background = Color(.systemGray6)
        }

        return VStack(alignment: .leading, spacing: 6) {
            Text("\(calendar.component(.day, from: date))")
                .font(.headline)

            if let net {
                let absNet = abs(net)
                Text(currency(absNet))
                    .font(.caption2.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(net >= 0 ? Color.green : Color.red)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            } else {
                Text("—")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
        .padding(8)
        .background(background, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.accentColor, lineWidth: isToday ? 2 : 0)
        )
    }

    private var dailyNetTotals: [Date: Double] {
        Dictionary(grouping: records) { record in
            calendar.startOfDay(for: record.createdAt)
        }
        .mapValues { dailyRecords in
            dailyRecords.reduce(0) { $0 + $1.netProfit }
        }
    }
}

private struct LossPattern {
    let message: String
    let loss: Double
    let count: Int
    let returnRate: Double

    var returnRateString: String {
        String(format: "%.0f%%", returnRate)
    }
}

#Preview {
    ContentView()
        .modelContainer(previewContainer)
}

struct LossPatternKey: Hashable {
    let timeSlot: TimeSlot
    let popularityBand: PopularityBand
}

let previewContainer: ModelContainer = {
    let container = try! ModelContainer(for: BetRecord.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = ModelContext(container)
    let samples: [BetRecord] = [
        BetRecord(
            createdAt: .now.addingTimeInterval(-3600 * 5),
            ticketType: .trio,
            popularityBand: .darkHorse,
            raceGrade: .g1,
            timeSlot: .afternoon,
            investment: 2000,
            payout: 0
        ),
        BetRecord(
            createdAt: .now.addingTimeInterval(-3600 * 10),
            ticketType: .win,
            popularityBand: .favorite,
            raceGrade: .flat,
            timeSlot: .morning,
            investment: 1000,
            payout: 1600
        ),
        BetRecord(
            createdAt: .now.addingTimeInterval(-3600 * 20),
            ticketType: .quinella,
            popularityBand: .mid,
            raceGrade: .graded,
            timeSlot: .afternoon,
            investment: 1500,
            payout: 500
        )
    ]
    samples.forEach { context.insert($0) }
    return container
}()

private enum AmountField: Hashable {
    case investment
    case payout
    case editInvestment
    case editPayout
}

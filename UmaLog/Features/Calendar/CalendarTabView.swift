import SwiftUI

struct CalendarTabView: View {
    let records: [BetRecord]

    @State private var displayedMonth: Date = Calendar.autoupdatingCurrent.date(
        from: Calendar.autoupdatingCurrent.dateComponents([.year, .month], from: Date())
    ) ?? Date()

    private var calendar: Calendar {
        var calendar = Calendar.autoupdatingCurrent
        calendar.locale = .autoupdatingCurrent
        return calendar
    }

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
                        calendarHeader
                        calendarSection
                    }
                    .padding()
                }
            }
            .navigationTitle("カレンダー")
            .navigationBarTitleDisplayMode(.inline)
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
            background = net > 0 ? Color.green.opacity(0.15) : (net < 0 ? Color.red.opacity(0.15) : Color.gray.opacity(0.12))
        } else {
            background = Color(.systemGray6)
        }

        return VStack(alignment: .leading, spacing: 6) {
            Text("\(calendar.component(.day, from: date))")
                .font(.headline)

            if let totals {
                VStack(alignment: .leading, spacing: 2) {
                    Text(AmountFormatting.currency(totals.investment))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)

                    Text(AmountFormatting.currency(totals.payout))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.green)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
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
}

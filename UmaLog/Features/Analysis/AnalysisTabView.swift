import SwiftUI

struct AnalysisTabView: View {
    let records: [BetRecord]

    @State private var startDate: Date = Calendar.autoupdatingCurrent.date(byAdding: .month, value: -1, to: .now) ?? .now
    @State private var endDate: Date = .now
    @State private var showingPaywall = false
    @AppStorage("themeColorSelection") private var themeColorSelection = ThemeColorPalette.defaultSelectionId
    @AppStorage("customThemeColorHex") private var customThemeColorHex = ThemeColorPalette.defaultCustomHex

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [mainColor.opacity(0.9), mainColor.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        dateFilterCard
                        overviewCard

                        ticketTypePieSection

                        analysisSection(
                            title: "グレード別の回収額",
                            subtitle: "レースの格ごとに払戻の傾向を整理します。",
                            data: gradePayoutBreakdown
                        )

//                        premiumSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("分析")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("有料プランで開放", isPresented: $showingPaywall) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("この分析は有料プランで見られる内容です。")
        }
    }

    private var dateFilterCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("期間の絞り込み")
                .font(.headline)

            HStack(spacing: 8) {
                DatePicker("", selection: $startDate, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .environment(\.locale, Locale(identifier: "ja_JP"))
                    .environment(\.calendar, calendar)
                    .accessibilityLabel("開始日")
                    .onChange(of: startDate) { _, _ in
                        adjustDateRange()
                    }

                Text("～")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                DatePicker("", selection: $endDate, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .environment(\.locale, Locale(identifier: "ja_JP"))
                    .environment(\.calendar, calendar)
                    .accessibilityLabel("終了日")
                    .onChange(of: endDate) { _, _ in
                        adjustDateRange()
                    }
            }
            .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var overviewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("サマリー")
                .font(.headline)

            HStack(spacing: 16) {
                summaryMetric(title: "投資", value: AmountFormatting.currency(totalInvestment))
                summaryMetric(title: "払戻", value: AmountFormatting.currency(totalPayout))
            }

            HStack(spacing: 16) {
                summaryMetric(title: "収支", value: netProfitText)
                summaryMetric(title: "回収率", value: returnRateText)
            }

            Text("対象件数: \(filteredRecords.count)件")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var ticketTypePieSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("券種別の傾向")
                .font(.headline)

            Text("購入割合と回収額の内訳を円グラフで確認できます。")
                .font(.caption)
                .foregroundStyle(.secondary)

            if ticketTypePieEntries.isEmpty {
                Text("対象期間の記録がありません。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                HStack(spacing: 12) {
                    pieChartCard(
                        title: "購入割合",
                        total: totalInvestment,
                        totalLabel: "総投資額",
                        value: \.investmentValue
                    )

                    pieChartCard(
                        title: "回収金額",
                        total: totalPayout,
                        totalLabel: "総回収額",
                        value: \.payoutValue
                    )
                }

                VStack(spacing: 10) {
                    ForEach(Array(ticketTypePieEntries.enumerated()), id: \.element.id) { index, entry in
                        legendRow(entry: entry, color: pieColor(for: index))
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func analysisSection(title: String, subtitle: String, data: [ChartEntry]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)

            if data.isEmpty {
                Text("対象期間の記録がありません。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 10) {
                    let maxValue = data.map { max($0.investmentValue, $0.payoutValue) }.max() ?? 1
                    ForEach(data) { entry in
                        analysisBar(entry: entry, maxValue: maxValue)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func analysisBar(entry: ChartEntry, maxValue: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.label)
                    .font(.subheadline)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(entry.investmentText)
                        .font(.subheadline)
                    Text(entry.payoutText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(spacing: 6) {
                barRow(
                    label: "投資額",
                    value: entry.investmentValue,
                    maxValue: maxValue,
                    barColor: .accentColor
                )
                barRow(
                    label: "回収額",
                    value: entry.payoutValue,
                    maxValue: maxValue,
                    barColor: .orange
                )
            }
        }
    }

    private func pieChartCard(
        title: String,
        total: Double,
        totalLabel: String,
        value: KeyPath<PieChartEntry, Double>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            PieChartView(entries: ticketTypePieEntries, total: total, value: value, colors: pieColors)
                .frame(height: 140)

            Text(totalLabel)
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text(AmountFormatting.currency(total))
                .font(.subheadline)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func legendRow(entry: PieChartEntry, color: Color) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)

                Text(entry.label)
                    .font(.subheadline)

                Spacer()

                Text(percentageText(entry.investmentRatio))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text("投資")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(AmountFormatting.currency(entry.investmentValue))
                    .font(.caption)

                Spacer()

                Text("回収")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(AmountFormatting.currency(entry.payoutValue))
                    .font(.caption)
            }
        }
    }

    private func barRow(label: String, value: Double, maxValue: Double, barColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)

            GeometryReader { proxy in
                let width = proxy.size.width
                let ratio = maxValue > 0 ? value / maxValue : 0
                RoundedRectangle(cornerRadius: 6)
                    .fill(barColor.opacity(0.25))
                    .frame(height: 8)
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(barColor)
                            .frame(width: width * ratio, height: 8)
                    }
            }
            .frame(height: 8)
        }
    }

    private var premiumSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("有料分析")
                .font(.headline)

            Text("より深い傾向分析は有料プランで表示されます。")
                .font(.caption)
                .foregroundStyle(.secondary)

            premiumLockedCard(
                title: "コースや馬場の深掘り",
                description: "馬場状態と距離の組み合わせから勝ち筋を見つけます。"
            )

            premiumLockedCard(
                title: "時間帯の勝率",
                description: "時間帯ごとの回収率を比較して狙い目を見える化します。"
            )
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func premiumLockedCard(title: String, description: String) -> some View {
        Button {
            showingPaywall = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("有料")
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.2))
                    .clipShape(Capsule())
            }
            .padding(12)
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func summaryMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func adjustDateRange() {
        if startDate > endDate {
            endDate = startDate
        }
    }

    private var filteredRecords: [BetRecord] {
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
        return records.filter { record in
            record.createdAt >= start && record.createdAt <= end
        }
    }

    private var totalInvestment: Double {
        filteredRecords.reduce(0) { $0 + $1.investment }
    }

    private var totalPayout: Double {
        filteredRecords.reduce(0) { $0 + $1.payout }
    }

    private var netProfitText: String {
        let net = totalPayout - totalInvestment
        let formatted = AmountFormatting.currency(abs(net))
        return net >= 0 ? "+\(formatted)" : "-\(formatted)"
    }

    private var returnRateText: String {
        guard totalInvestment > 0 else { return "— %" }
        return String(format: "%.0f%%", (totalPayout / totalInvestment) * 100)
    }

    private var ticketTypePieEntries: [PieChartEntry] {
        let grouped = Dictionary(grouping: filteredRecords, by: \.ticketType)
        return grouped.map { key, items in
            let investmentTotal = items.reduce(0) { $0 + $1.investment }
            let payoutTotal = items.reduce(0) { $0 + $1.payout }
            let investmentRatio = totalInvestment > 0 ? investmentTotal / totalInvestment : 0
            return PieChartEntry(
                label: key.rawValue,
                investmentValue: investmentTotal,
                payoutValue: payoutTotal,
                investmentRatio: investmentRatio
            )
        }
        .sorted { $0.investmentValue > $1.investmentValue }
    }

    private var gradePayoutBreakdown: [ChartEntry] {
        let grouped = Dictionary(grouping: filteredRecords, by: \.raceGrade)
        return grouped.map { key, items in
            let payoutTotal = items.reduce(0) { $0 + $1.payout }
            let investmentTotal = items.reduce(0) { $0 + $1.investment }
            return ChartEntry(
                label: key.rawValue,
                investmentValue: investmentTotal,
                payoutValue: payoutTotal,
                investmentText: "投資額 \(AmountFormatting.currency(investmentTotal))",
                payoutText: "回収額 \(AmountFormatting.currency(payoutTotal))"
            )
        }
        .sorted { $0.investmentValue > $1.investmentValue }
    }

    private func percentageText(_ ratio: Double) -> String {
        String(format: "%.0f%%", ratio * 100)
    }

    private var pieColors: [Color] {
        [
            .accentColor,
            .orange,
            .purple,
            .mint,
            .pink,
            .blue,
            .teal,
            .indigo
        ]
    }

    private func pieColor(for index: Int) -> Color {
        pieColors[index % pieColors.count]
    }

    private var cardBackground: Color {
        Color(.secondarySystemBackground)
    }

    private var mainColor: Color {
        ThemeColorPalette.color(for: themeColorSelection, customHex: customThemeColorHex)
    }

    private var calendar: Calendar {
        var calendar = Calendar.autoupdatingCurrent
        calendar.locale = .autoupdatingCurrent
        return calendar
    }
}

private struct ChartEntry: Identifiable {
    let id = UUID()
    let label: String
    let investmentValue: Double
    let payoutValue: Double
    let investmentText: String
    let payoutText: String
}

private struct PieChartEntry: Identifiable {
    let id = UUID()
    let label: String
    let investmentValue: Double
    let payoutValue: Double
    let investmentRatio: Double
}

private struct PieChartView: View {
    let entries: [PieChartEntry]
    let total: Double
    let value: KeyPath<PieChartEntry, Double>
    let colors: [Color]

    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)

            ZStack {
                if total > 0 {
                    ForEach(Array(entries.enumerated()), id: \.element.id) { index, _ in
                        PieSlice(
                            startAngle: startAngle(at: index),
                            endAngle: endAngle(at: index)
                        )
                        .fill(colors[index % colors.count])
                    }
                } else {
                    Circle()
                        .fill(Color.secondary.opacity(0.15))
                }

                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: size * 0.52, height: size * 0.52)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func startAngle(at index: Int) -> Angle {
        let previous = entries.prefix(index).reduce(0) { $0 + $1[keyPath: value] }
        return .degrees((previous / total) * 360 - 90)
    }

    private func endAngle(at index: Int) -> Angle {
        let current = entries.prefix(index + 1).reduce(0) { $0 + $1[keyPath: value] }
        return .degrees((current / total) * 360 - 90)
    }
}

private struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        var path = Path()
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}

import SwiftUI

struct AnalysisTabView: View {
    let records: [BetRecord]

    @State private var startDate: Date = Calendar.autoupdatingCurrent.date(byAdding: .month, value: -1, to: .now) ?? .now
    @State private var endDate: Date = .now
    @State private var showingPaywall = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    dateFilterCard
                    overviewCard

                    analysisSection(
                        title: "券種別の投資比率",
                        subtitle: "券種ごとの投資額を比べて、偏りを確認できます。",
                        data: ticketTypeBreakdown
                    )

                    analysisSection(
                        title: "グレード別の回収額",
                        subtitle: "レースの格ごとに払戻の傾向を整理します。",
                        data: gradePayoutBreakdown
                    )

                    premiumSection
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .navigationTitle("分析")
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

            HStack(spacing: 12) {
                DatePicker("開始", selection: $startDate, displayedComponents: .date)
                    .onChange(of: startDate) { _, _ in
                        adjustDateRange()
                    }

                DatePicker("終了", selection: $endDate, displayedComponents: .date)
                    .onChange(of: endDate) { _, _ in
                        adjustDateRange()
                    }
            }
            .font(.subheadline)
        }
        .padding()
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
                    ForEach(data) { entry in
                        analysisBar(entry: entry, maxValue: data.map(\.value).max() ?? 1)
                    }
                }
            }
        }
        .padding()
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func analysisBar(entry: ChartEntry, maxValue: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.label)
                    .font(.subheadline)
                Spacer()
                Text(entry.formattedValue)
                    .font(.subheadline)
            }

            GeometryReader { proxy in
                let width = proxy.size.width
                let ratio = maxValue > 0 ? entry.value / maxValue : 0
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.accentColor.opacity(0.25))
                    .frame(height: 10)
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.accentColor)
                            .frame(width: width * ratio, height: 10)
                    }
            }
            .frame(height: 10)
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

    private var ticketTypeBreakdown: [ChartEntry] {
        let grouped = Dictionary(grouping: filteredRecords, by: \.ticketType)
        return grouped.map { key, items in
            let total = items.reduce(0) { $0 + $1.investment }
            return ChartEntry(label: key.rawValue, value: total, formattedValue: AmountFormatting.currency(total))
        }
        .sorted { $0.value > $1.value }
    }

    private var gradePayoutBreakdown: [ChartEntry] {
        let grouped = Dictionary(grouping: filteredRecords, by: \.raceGrade)
        return grouped.map { key, items in
            let total = items.reduce(0) { $0 + $1.payout }
            return ChartEntry(label: key.rawValue, value: total, formattedValue: AmountFormatting.currency(total))
        }
        .sorted { $0.value > $1.value }
    }

    private var cardBackground: Color {
        Color(.secondarySystemBackground)
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
    let value: Double
    let formattedValue: String
}

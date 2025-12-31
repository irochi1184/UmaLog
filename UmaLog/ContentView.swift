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
    @State private var investmentText: String = ""
    @State private var payoutText: String = ""

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
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
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
            amountField(title: "投資額", placeholder: "例: 1200", text: $investmentText)
            amountField(title: "払戻額", placeholder: "例: 800", text: $payoutText)
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
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("\(record.timeSlot.rawValue) × \(record.popularityBand.rawValue)")
                                    .font(.headline)
                                Spacer()
                                Text(record.createdAt, style: .date)
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
            let investment = Double(investmentText),
            let payout = Double(payoutText)
        else { return }

        let record = BetRecord(
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
        }
    }

    private var isValidInput: Bool {
        (Double(investmentText) ?? 0) > 0
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

    private func amountField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField(placeholder, text: text)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
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
        return formatter.string(from: NSNumber(value: value)) ?? "¥0"
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

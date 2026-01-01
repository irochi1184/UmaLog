import Foundation

struct EditRecordState {
    var record: BetRecord?
    var date: Date = .now
    var ticketType: TicketType = .win
    var popularityBand: PopularityBand = .favorite
    var raceGrade: RaceGrade = .flat
    var timeSlot: TimeSlot = .afternoon
    var investmentText: String = ""
    var payoutText: String = ""
    var isPresented: Bool = false

    var isValid: Bool {
        let investment = AmountFormatting.parseAmount(investmentText) ?? 0
        let payout = AmountFormatting.parseAmount(payoutText) ?? 0
        return record != nil && investment > 0 && payout >= 0
    }

    mutating func load(from record: BetRecord) {
        self.record = record
        date = record.createdAt
        ticketType = record.ticketType
        popularityBand = record.popularityBand
        raceGrade = record.raceGrade
        timeSlot = record.timeSlot
        investmentText = AmountFormatting.plainFormatter().string(from: NSNumber(value: record.investment)) ?? ""
        payoutText = AmountFormatting.plainFormatter().string(from: NSNumber(value: record.payout)) ?? ""
        isPresented = true
    }
}

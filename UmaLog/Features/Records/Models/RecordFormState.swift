import Foundation

struct RecordFormState {
    var ticketType: TicketType = .win
    var popularityBand: PopularityBand = .favorite
    var raceGrade: RaceGrade = .flat
    var timeSlot: TimeSlot = .afternoon
    var selectedDate: Date = .now
    var investmentText: String = ""
    var payoutText: String = ""

    mutating func resetAmounts() {
        investmentText = ""
        payoutText = ""
    }
}

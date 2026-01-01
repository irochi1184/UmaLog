import Foundation

struct RecordFormState {
    var ticketType: TicketType = .win
    var popularityBand: PopularityBand = .favorite
    var raceGrade: RaceGrade = .flat
    var timeSlot: TimeSlot = .afternoon
    var selectedDate: Date = .now
    var investmentText: String = ""
    var payoutText: String = ""
    var racecourse: String = ""
    var raceNumber: String = ""
    var horseNumber: String = ""
    var jockeyName: String = ""
    var horseName: String = ""
    var raceTimeDetail: String = ""
    var course: String = ""
    var courseLength: String = ""
    var memo: String = ""

    mutating func resetAmounts() {
        investmentText = ""
        payoutText = ""
    }
}

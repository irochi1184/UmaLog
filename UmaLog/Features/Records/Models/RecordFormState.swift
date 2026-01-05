import Foundation

struct RecordFormState {
    var ticketType: TicketType = .win
    var popularityBand: PopularityBand = .favorite
    var raceGrade: RaceGrade = .flat
    var selectedDate: Date = .now
    var investmentText: String = ""
    var payoutText: String = ""
    var racecourse: Racecourse = .tokyo
    var raceNumber: Int = 1
    var horseNumbers: [Int] = []
    var jockeyName: String = ""
    var horseName: String = ""
    var raceTimeDetail: String = ""
    var courseSurface: CourseSurface? = nil
    var courseDirection: CourseDirection? = nil
    var courseLength: String = ""
    var weather: Weather? = nil
    var trackCondition: TrackCondition? = nil
    var memo: String = ""

    mutating func resetAmounts() {
        investmentText = ""
        payoutText = ""
    }
}

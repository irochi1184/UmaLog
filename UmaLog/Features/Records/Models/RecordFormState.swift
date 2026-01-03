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
    var courseSurface: CourseSurface = .turf
    var courseDirection: CourseDirection = .right
    var courseLength: RaceDistance = .m1600
    var weather: Weather = .sunny
    var trackCondition: TrackCondition = .good
    var memo: String = ""

    mutating func resetAmounts() {
        investmentText = ""
        payoutText = ""
    }
}

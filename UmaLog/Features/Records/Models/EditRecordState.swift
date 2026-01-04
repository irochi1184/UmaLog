import Foundation

struct EditRecordState {
    var record: BetRecord?
    var date: Date = .now
    var ticketType: TicketType = .win
    var popularityBand: PopularityBand = .favorite
    var raceGrade: RaceGrade = .flat
    var investmentText: String = ""
    var payoutText: String = ""
    var isPresented: Bool = false
    var racecourse: Racecourse = .tokyo
    var raceNumber: Int = 1
    var horseNumbers: [Int] = []
    var jockeyName: String = ""
    var horseName: String = ""
    var raceTimeDetail: String = ""
    var courseSurface: CourseSurface? = nil
    var courseDirection: CourseDirection? = nil
    var courseLength: RaceDistance? = nil
    var weather: Weather? = nil
    var trackCondition: TrackCondition? = nil
    var memo: String = ""

    var isValid: Bool {
        let investment = AmountFormatting.parseAmount(investmentText) ?? 0
        let payout = AmountFormatting.parseAmount(payoutText) ?? 0
        return record != nil && investment > 0 && payout >= 0 && raceNumber > 0
    }

    mutating func load(from record: BetRecord) {
        self.record = record
        date = record.createdAt
        ticketType = record.ticketType
        popularityBand = record.popularityBand
        raceGrade = record.raceGrade
        investmentText = AmountFormatting.plainFormatter().string(from: NSNumber(value: record.investment)) ?? ""
        payoutText = AmountFormatting.plainFormatter().string(from: NSNumber(value: record.payout)) ?? ""
        isPresented = true
        racecourse = record.racecourse.flatMap(Racecourse.init(rawValue:)) ?? .tokyo
        raceNumber = Int(record.raceNumberText) ?? 1
        horseNumbers = record.horseNumber?
            .split(whereSeparator: { $0 == "," || $0 == "-" || $0 == "/" || $0 == "・" })
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) } ?? []
        jockeyName = record.jockeyName ?? ""
        horseName = record.horseName ?? ""
        raceTimeDetail = record.raceTimeDetail ?? ""
        courseSurface = record.courseSurface.flatMap(CourseSurface.init(rawValue:))
        courseDirection = record.courseDirection.flatMap(CourseDirection.init(rawValue:))
        courseLength = record.courseLength.flatMap(RaceDistance.init(rawValue:))
        weather = record.weather.flatMap(Weather.init(rawValue:))
        trackCondition = record.trackCondition.flatMap(TrackCondition.init(rawValue:))
        memo = record.memo ?? ""
    }
}

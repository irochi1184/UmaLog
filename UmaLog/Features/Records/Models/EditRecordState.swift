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
    var isNewEntry: Bool = false
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

    var isValid: Bool {
        let investment = AmountFormatting.parseAmount(investmentText) ?? 0
        let payout = AmountFormatting.parseAmount(payoutText) ?? 0
        return (record != nil || isNewEntry) && investment > 0 && payout >= 0 && raceNumber > 0
    }

    mutating func load(from record: BetRecord) {
        self.record = record
        isNewEntry = false
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
        courseLength = Self.sanitizedCourseLength(from: record.courseLength)
        weather = record.weather.flatMap(Weather.init(rawValue:))
        trackCondition = record.trackCondition.flatMap(TrackCondition.init(rawValue:))
        memo = record.memo ?? ""
    }

    mutating func prepareForNew(date: Date) {
        record = nil
        isNewEntry = true
        self.date = date
        ticketType = .win
        popularityBand = .favorite
        raceGrade = .flat
        investmentText = ""
        payoutText = ""
        isPresented = true
        racecourse = .tokyo
        raceNumber = 1
        horseNumbers = []
        jockeyName = ""
        horseName = ""
        raceTimeDetail = ""
        courseSurface = nil
        courseDirection = nil
        courseLength = ""
        weather = nil
        trackCondition = nil
        memo = ""
    }

    private static func sanitizedCourseLength(from text: String?) -> String {
        guard let text else { return "" }
        let digits = text.filter(\.isNumber)
        return digits
    }
}

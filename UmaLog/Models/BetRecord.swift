//
//  BetRecord.swift
//  UmaLog
//
//  Created by 有田健一郎 on 2025/12/31.
//

import Foundation
import SwiftData

@Model
final class BetRecord {
    var createdAt: Date
    var ticketType: TicketType
    var popularityBand: PopularityBand
    var raceGrade: RaceGrade
    var timeSlot: TimeSlot
    var investment: Double
    var payout: Double
    var racecourse: String?
    var raceNumber: String?
    var horseNumber: String?
    var jockeyName: String?
    var horseName: String?
    var raceTimeDetail: String?
    var course: String?
    var courseLength: String?
    var memo: String?

    init(
        createdAt: Date = .now,
        ticketType: TicketType,
        popularityBand: PopularityBand,
        raceGrade: RaceGrade,
        timeSlot: TimeSlot,
        investment: Double,
        payout: Double,
        racecourse: String? = nil,
        raceNumber: String? = nil,
        horseNumber: String? = nil,
        jockeyName: String? = nil,
        horseName: String? = nil,
        raceTimeDetail: String? = nil,
        course: String? = nil,
        courseLength: String? = nil,
        memo: String? = nil
    ) {
        self.createdAt = createdAt
        self.ticketType = ticketType
        self.popularityBand = popularityBand
        self.raceGrade = raceGrade
        self.timeSlot = timeSlot
        self.investment = investment
        self.payout = payout
        self.racecourse = racecourse
        self.raceNumber = raceNumber
        self.horseNumber = horseNumber
        self.jockeyName = jockeyName
        self.horseName = horseName
        self.raceTimeDetail = raceTimeDetail
        self.course = course
        self.courseLength = courseLength
        self.memo = memo
    }

    var netProfit: Double {
        payout - investment
    }

    var returnRate: Double {
        guard investment > 0 else { return 0 }
        return (payout / investment) * 100
    }
}

enum TicketType: String, CaseIterable, Codable, Identifiable, Hashable {
    case win = "単勝"
    case place = "複勝"
    case quinella = "馬連"
    case trio = "三連系"

    var id: String { rawValue }
}

enum PopularityBand: String, CaseIterable, Codable, Identifiable, Hashable {
    case favorite = "1〜3番人気"
    case mid = "中穴"
    case darkHorse = "穴"

    var id: String { rawValue }
}

enum RaceGrade: String, CaseIterable, Codable, Identifiable, Hashable {
    case g1 = "G1"
    case graded = "重賞"
    case flat = "平場"

    var id: String { rawValue }
}

enum TimeSlot: String, CaseIterable, Codable, Identifiable, Hashable {
    case morning = "午前"
    case afternoon = "午後"

    var id: String { rawValue }
}

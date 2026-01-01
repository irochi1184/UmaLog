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
    var courseSurface: String?
    var courseDirection: String?
    var courseLength: String?
    var weather: String?
    var trackCondition: String?
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
        courseSurface: String? = nil,
        courseDirection: String? = nil,
        courseLength: String? = nil,
        weather: String? = nil,
        trackCondition: String? = nil,
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
        self.courseSurface = courseSurface
        self.courseDirection = courseDirection
        self.courseLength = courseLength
        self.weather = weather
        self.trackCondition = trackCondition
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

enum TicketType: String, Codable, Identifiable, Hashable {
    case win = "単勝"
    case place = "複勝"
    case bracketQuinella = "枠連"
    case quinella = "馬連"
    case exacta = "馬単"
    case wide = "ワイド"
    case trio = "3連複"
    case trifecta = "3連単"
    case legacyTrio = "三連系"

    var id: String { rawValue }

    static let allCases: [TicketType] = [
        .win, .place, .bracketQuinella, .quinella, .exacta, .wide, .trio, .trifecta
    ]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        switch value {
        case TicketType.win.rawValue:
            self = .win
        case TicketType.place.rawValue:
            self = .place
        case TicketType.bracketQuinella.rawValue:
            self = .bracketQuinella
        case TicketType.quinella.rawValue:
            self = .quinella
        case TicketType.exacta.rawValue:
            self = .exacta
        case TicketType.wide.rawValue:
            self = .wide
        case TicketType.trio.rawValue:
            self = .trio
        case TicketType.trifecta.rawValue:
            self = .trifecta
        case TicketType.legacyTrio.rawValue:
            self = .trio
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown TicketType value: \(value)")
        }
    }

    var requiredHorseSelections: Int {
        switch self {
        case .win, .place:
            return 1
        case .bracketQuinella, .quinella, .exacta, .wide:
            return 2
        case .trio, .trifecta:
            return 3
        }
    }
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

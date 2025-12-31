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

    init(
        createdAt: Date = .now,
        ticketType: TicketType,
        popularityBand: PopularityBand,
        raceGrade: RaceGrade,
        timeSlot: TimeSlot,
        investment: Double,
        payout: Double
    ) {
        self.createdAt = createdAt
        self.ticketType = ticketType
        self.popularityBand = popularityBand
        self.raceGrade = raceGrade
        self.timeSlot = timeSlot
        self.investment = investment
        self.payout = payout
    }

    var netProfit: Double {
        payout - investment
    }

    var returnRate: Double {
        guard investment > 0 else { return 0 }
        return (payout / investment) * 100
    }
}

enum TicketType: String, CaseIterable, Codable, Identifiable {
    case win = "単勝"
    case place = "複勝"
    case quinella = "馬連"
    case trio = "三連系"

    var id: String { rawValue }
}

enum PopularityBand: String, CaseIterable, Codable, Identifiable {
    case favorite = "1〜3番人気"
    case mid = "中穴"
    case darkHorse = "穴"

    var id: String { rawValue }
}

enum RaceGrade: String, CaseIterable, Codable, Identifiable {
    case g1 = "G1"
    case graded = "重賞"
    case flat = "平場"

    var id: String { rawValue }
}

enum TimeSlot: String, CaseIterable, Codable, Identifiable {
    case morning = "午前"
    case afternoon = "午後"

    var id: String { rawValue }
}

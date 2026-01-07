import Foundation
import SwiftData

let previewContainer: ModelContainer = {
    let container = try! ModelContainer(for: BetRecord.self, MemoNote.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = ModelContext(container)
    let samples: [BetRecord] = [
        BetRecord(
            createdAt: .now.addingTimeInterval(-3600 * 5),
            ticketType: .trio,
            popularityBand: .darkHorse,
            raceGrade: .g1,
            investment: 2000,
            payout: 0,
            raceNumber: "1"
        ),
        BetRecord(
            createdAt: .now.addingTimeInterval(-3600 * 10),
            ticketType: .win,
            popularityBand: .favorite,
            raceGrade: .flat,
            investment: 1000,
            payout: 1600,
            raceNumber: "5"
        ),
        BetRecord(
            createdAt: .now.addingTimeInterval(-3600 * 20),
            ticketType: .quinella,
            popularityBand: .mid,
            raceGrade: .graded,
            investment: 1500,
            payout: 500,
            raceNumber: "9"
        )
    ]
    samples.forEach { context.insert($0) }
    return container
}()

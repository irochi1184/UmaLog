import SwiftData

let previewContainer: ModelContainer = {
    let container = try! ModelContainer(for: BetRecord.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = ModelContext(container)
    let samples: [BetRecord] = [
        BetRecord(
            createdAt: .now.addingTimeInterval(-3600 * 5),
            ticketType: .trio,
            popularityBand: .darkHorse,
            raceGrade: .g1,
            timeSlot: .afternoon,
            investment: 2000,
            payout: 0
        ),
        BetRecord(
            createdAt: .now.addingTimeInterval(-3600 * 10),
            ticketType: .win,
            popularityBand: .favorite,
            raceGrade: .flat,
            timeSlot: .morning,
            investment: 1000,
            payout: 1600
        ),
        BetRecord(
            createdAt: .now.addingTimeInterval(-3600 * 20),
            ticketType: .quinella,
            popularityBand: .mid,
            raceGrade: .graded,
            timeSlot: .afternoon,
            investment: 1500,
            payout: 500
        )
    ]
    samples.forEach { context.insert($0) }
    return container
}()

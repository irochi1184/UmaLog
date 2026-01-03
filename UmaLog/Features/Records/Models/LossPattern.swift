import Foundation

struct LossPatternKey: Hashable {
    let popularityBand: PopularityBand
}

struct LossPattern {
    let message: String
    let loss: Double
    let count: Int
    let returnRate: Double

    var returnRateString: String {
        String(format: "%.0f%%", returnRate)
    }
}

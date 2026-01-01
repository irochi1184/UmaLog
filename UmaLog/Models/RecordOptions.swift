import Foundation

enum Racecourse: String, CaseIterable, Identifiable, Hashable, Codable {
    case sapporo = "札幌"
    case hakodate = "函館"
    case niigata = "新潟"
    case fukushima = "福島"
    case tokyo = "東京"
    case nakayama = "中山"
    case chukyo = "中京"
    case kyoto = "京都"
    case hanshin = "阪神"
    case kokura = "小倉"

    var id: String { rawValue }
}

enum CourseSurface: String, CaseIterable, Identifiable, Hashable, Codable {
    case turf = "芝"
    case dirt = "ダート"
    case jump = "障害"

    var id: String { rawValue }
}

enum CourseDirection: String, CaseIterable, Identifiable, Hashable, Codable {
    case right = "右回り"
    case left = "左回り"
    case straight = "直線"

    var id: String { rawValue }
}

enum RaceDistance: String, CaseIterable, Identifiable, Hashable, Codable {
    case m1000 = "1000"
    case m1200 = "1200"
    case m1400 = "1400"
    case m1500 = "1500"
    case m1600 = "1600"
    case m1700 = "1700"
    case m1800 = "1800"
    case m2000 = "2000"
    case m2200 = "2200"
    case m2400 = "2400"
    case m2500 = "2500"
    case m2600 = "2600"
    case m3000 = "3000"
    case m3200 = "3200"
    case m3400 = "3400"

    var id: String { rawValue }

    var display: String {
        "\(rawValue)m"
    }
}

enum Weather: String, CaseIterable, Identifiable, Hashable, Codable {
    case sunny = "晴れ"
    case cloudy = "くもり"
    case lightRain = "小雨"
    case rain = "雨"
    case snow = "雪"

    var id: String { rawValue }
}

enum TrackCondition: String, CaseIterable, Identifiable, Hashable, Codable {
    case good = "良"
    case yielding = "稍重"
    case soft = "重"
    case muddy = "不良"

    var id: String { rawValue }
}

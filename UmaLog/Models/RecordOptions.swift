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

import SwiftUI
import UIKit

struct ThemeColorPreset: Identifiable {
    let id: String
    let name: String
    let hex: String
}

enum ThemeColorPalette {
    static let customId = "custom"
    static let presets: [ThemeColorPreset] = [
        ThemeColorPreset(id: "deep-forest", name: "深い森", hex: "#138074"),
        ThemeColorPreset(id: "midnight-navy", name: "ミッドナイトネイビー", hex: "#1F2A44"),
        ThemeColorPreset(id: "charcoal", name: "チャコール", hex: "#2E2E2E"),
        ThemeColorPreset(id: "burgundy", name: "ボルドー", hex: "#5A1E2B"),
        ThemeColorPreset(id: "slate-blue", name: "スレートブルー", hex: "#3C4F76"),
        ThemeColorPreset(id: "smoky-teal", name: "スモーキーティール", hex: "#2F6F6D"),
        ThemeColorPreset(id: "olive", name: "オリーブ", hex: "#5B5A2A"),
        ThemeColorPreset(id: "coffee", name: "コーヒーブラウン", hex: "#4A342E"),
        ThemeColorPreset(id: "plum", name: "プラム", hex: "#6A4C6B"),
        ThemeColorPreset(id: "steel", name: "スチールブルー", hex: "#4A5E6A"),
        ThemeColorPreset(id: "sandstone", name: "サンドストーン", hex: "#7A6A4F")
    ]
    static let defaultSelectionId = presets.first?.id ?? "deep-forest"
    static let defaultCustomHex = presets.first?.hex ?? "#138074"

    static func color(for selectionId: String, customHex: String) -> Color {
        if selectionId == customId {
            return color(from: customHex)
        }
        if let preset = presets.first(where: { $0.id == selectionId }) {
            return color(from: preset.hex)
        }
        return color(from: defaultCustomHex)
    }

    static func color(from hex: String) -> Color {
        Color(hex: hex)
    }
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let red: Double
        let green: Double
        let blue: Double

        switch cleaned.count {
        case 6:
            red = Double((value >> 16) & 0xFF) / 255.0
            green = Double((value >> 8) & 0xFF) / 255.0
            blue = Double(value & 0xFF) / 255.0
        case 3:
            red = Double((value >> 8) & 0xF) / 15.0
            green = Double((value >> 4) & 0xF) / 15.0
            blue = Double(value & 0xF) / 15.0
        default:
            red = 0
            green = 0
            blue = 0
        }

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }

    func toHex() -> String? {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }

        let r = Int(round(red * 255))
        let g = Int(round(green * 255))
        let b = Int(round(blue * 255))
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

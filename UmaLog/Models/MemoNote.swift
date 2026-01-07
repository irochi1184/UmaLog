//
//  MemoNote.swift
//  UmaLog
//
//  Created by 有田健一郎 on 2026/03/02.
//

import Foundation
import SwiftData

@Model
final class MemoNote {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var updatedAt: Date
    var title: String
    var body: String

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        updatedAt: Date = .now,
        title: String = "",
        body: String = ""
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.title = title
        self.body = body
    }

    var displayTitle: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "新しいメモ" : trimmed
    }

    var previewText: String {
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "内容はまだありません" : trimmed
    }

    var isEmpty: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

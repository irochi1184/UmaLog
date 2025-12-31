//
//  Item.swift
//  UmaLog
//
//  Created by 有田健一郎 on 2025/12/31.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

//
//  UmaLogApp.swift
//  UmaLog
//
//  Created by 有田健一郎 on 2025/12/31.
//

import SwiftUI
import SwiftData

@main
struct UmaLogApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            BetRecord.self,
            MemoNote.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}

import SwiftData
import SwiftUI

struct ContentView: View {
    @Query(sort: \BetRecord.createdAt, order: .reverse) private var records: [BetRecord]

    var body: some View {
        TabView {
            RecordsTabView(records: records)
                .tabItem {
                    Label("記録", systemImage: "square.and.pencil")
                }

            CalendarTabView(records: records)
                .tabItem {
                    Label("カレンダー", systemImage: "calendar")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(previewContainer)
}

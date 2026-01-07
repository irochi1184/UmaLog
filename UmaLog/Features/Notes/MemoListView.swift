import SwiftData
import SwiftUI

struct MemoListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MemoNote.updatedAt, order: .reverse) private var memos: [MemoNote]

    @State private var editingMemo: MemoNote?

    var body: some View {
        List {
            if memos.isEmpty {
                ContentUnavailableView(
                    "メモがまだありません",
                    systemImage: "note.text",
                    description: Text("プラスボタンから新しいメモを追加できます。")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(memos) { memo in
                    NavigationLink {
                        MemoEditorView(memo: memo, isNew: false)
                    } label: {
                        MemoRow(memo: memo)
                    }
                }
                .onDelete(perform: deleteMemo)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("メモ帳")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    createMemo()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(item: $editingMemo) { memo in
            NavigationStack {
                MemoEditorView(memo: memo, isNew: true)
            }
        }
    }

    private func createMemo() {
        let memo = MemoNote()
        modelContext.insert(memo)
        editingMemo = memo
    }

    private func deleteMemo(at offsets: IndexSet) {
        offsets.map { memos[$0] }.forEach { memo in
            modelContext.delete(memo)
        }
    }
}

private struct MemoRow: View {
    let memo: MemoNote

    private var dateText: String {
        MemoRow.formatter.string(from: memo.updatedAt)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(memo.displayTitle)
                    .font(.headline)
                Spacer()
                Text(dateText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(memo.previewText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("yMd")
        return formatter
    }()
}

#Preview {
    NavigationStack {
        MemoListView()
    }
    .modelContainer(previewContainer)
}

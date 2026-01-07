import SwiftData
import SwiftUI

struct MemoEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var isShowingDeleteConfirmation = false

    @Bindable var memo: MemoNote
    let isNew: Bool

    var body: some View {
        Form {
            Section {
                TextField("タイトル", text: $memo.title)
            }

            Section("本文") {
                TextEditor(text: $memo.body)
                    .frame(minHeight: 220)
            }
        }
        .navigationTitle(isNew ? "メモを追加" : "メモを編集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isNew {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        cancelNewMemo()
                    }
                }
            } else {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(role: .destructive) {
                        isShowingDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("MainGreen", bundle: .main))
            }
        }
        .onChange(of: memo.title) { _, _ in
            memo.updatedAt = .now
        }
        .onChange(of: memo.body) { _, _ in
            memo.updatedAt = .now
        }
        .confirmationDialog("このメモを削除しますか？", isPresented: $isShowingDeleteConfirmation, titleVisibility: .visible) {
            Button("削除", role: .destructive) {
                deleteMemo()
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("削除すると元に戻せません。")
        }
        .onDisappear {
            removeEmptyMemoIfNeeded()
        }
    }

    private func cancelNewMemo() {
        removeEmptyMemoIfNeeded()
        dismiss()
    }

    private func deleteMemo() {
        modelContext.delete(memo)
        dismiss()
    }

    private func removeEmptyMemoIfNeeded() {
        guard isNew, memo.isEmpty else { return }
        modelContext.delete(memo)
    }
}

#Preview {
    NavigationStack {
        MemoEditorView(memo: MemoNote(title: "予想メモ", body: "今日は1番人気から。"), isNew: false)
    }
    .modelContainer(previewContainer)
}

import SwiftData
import SwiftUI

struct MemoEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var isShowingDeleteConfirmation = false
    @AppStorage("themeColorSelection") private var themeColorSelection = ThemeColorPalette.defaultSelectionId
    @AppStorage("customThemeColorHex") private var customThemeColorHex = ThemeColorPalette.defaultCustomHex

    @Bindable var memo: MemoNote
    let isNew: Bool

    private var mainColor: Color {
        ThemeColorPalette.color(for: themeColorSelection, customHex: customThemeColorHex)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("タイトル", text: $memo.title)
                .font(.title3.weight(.semibold))
                .padding(.top, 8)

            TextEditor(text: $memo.body)
                .font(.body)
                .scrollContentBackground(.hidden)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemBackground))
        .navigationTitle(isNew ? "メモを追加" : "メモを編集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !isNew {
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
                .tint(mainColor)
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

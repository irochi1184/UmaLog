import SwiftUI

struct SettingsTabView: View {
    @AppStorage("prefersQuickEntry") private var prefersQuickEntry = true
    @AppStorage("showRacecourseField") private var showRacecourseField = false
    @AppStorage("showRaceNumberField") private var showRaceNumberField = false
    @AppStorage("showHorseNumberField") private var showHorseNumberField = false
    @AppStorage("showJockeyField") private var showJockeyField = false
    @AppStorage("showHorseNameField") private var showHorseNameField = false
    @AppStorage("showRaceTimeField") private var showRaceTimeField = false
    @AppStorage("showCourseSurfaceField") private var showCourseSurfaceField = false
    @AppStorage("showCourseDirectionField") private var showCourseDirectionField = false
    @AppStorage("showCourseLengthField") private var showCourseLengthField = false
    @AppStorage("showWeatherField") private var showWeatherField = false
    @AppStorage("showTrackConditionField") private var showTrackConditionField = false
    @AppStorage("showMemoField") private var showMemoField = false

    private var cardBackground: Color {
        Color(.secondarySystemBackground)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                LinearGradient(
                    colors: [Color("MainGreen", bundle: .main).opacity(0.9), Color("MainGreen", bundle: .main).opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        modeSection
                        toggleSection
                        infoSection
                    }
                    .padding()
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("入力スタイルの設定")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text("サクッと記録か、がっつり記録か。表示する項目をここで切り替えられます。")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
        }
    }

    private var modeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("記録モード")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(spacing: 12) {
                Text("「サクッと」は必須項目だけ、「がっつり」は詳細をすべて出します。モードを変えると下のチェックも切り替わります。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    modeButton(title: "サクッと記録", isSelected: prefersQuickEntry) {
                        prefersQuickEntry = true
                        applyQuickPreset()
                    }
                    modeButton(title: "がっつり記録", isSelected: !prefersQuickEntry) {
                        prefersQuickEntry = false
                        applyDetailedPreset()
                    }
                }
            }
            .padding()
            .background(cardBackground, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var toggleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("表示する入力項目")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(spacing: 12) {
                toggleRow(title: "競馬場名", isOn: $showRacecourseField)
                toggleRow(title: "レース番号", isOn: $showRaceNumberField)
                toggleRow(title: "馬番", isOn: $showHorseNumberField)
                toggleRow(title: "騎手", isOn: $showJockeyField)
                toggleRow(title: "馬名", isOn: $showHorseNameField)
                toggleRow(title: "発走予定（5分刻み）", isOn: $showRaceTimeField)
                toggleRow(title: "コース（芝・ダートなど）", isOn: $showCourseSurfaceField)
                toggleRow(title: "コースの向き（右・左など）", isOn: $showCourseDirectionField)
                toggleRow(title: "コースの長さ", isOn: $showCourseLengthField)
                toggleRow(title: "天気", isOn: $showWeatherField)
                toggleRow(title: "馬場状態", isOn: $showTrackConditionField)
                toggleRow(title: "ひと言メモ", isOn: $showMemoField)
            }
            .padding()
            .background(cardBackground, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("メモ")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 8) {
                Text("発走予定をオンにすると時間帯の入力を自動で隠します。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text("モードはいつでも切り替え可能です。入力途中でも設定から変えられます。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(cardBackground, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private func modeButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? Color("MainGreen", bundle: .main).opacity(0.9) : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(.subheadline)
        }
        .toggleStyle(.switch)
    }

    private func applyQuickPreset() {
        showRacecourseField = false
        showRaceNumberField = false
        showHorseNumberField = false
        showJockeyField = false
        showHorseNameField = false
        showRaceTimeField = false
        showCourseSurfaceField = false
        showCourseDirectionField = false
        showCourseLengthField = false
        showWeatherField = false
        showTrackConditionField = false
        showMemoField = false
    }

    private func applyDetailedPreset() {
        showRacecourseField = true
        showRaceNumberField = true
        showHorseNumberField = true
        showJockeyField = true
        showHorseNameField = true
        showRaceTimeField = true
        showCourseSurfaceField = true
        showCourseDirectionField = true
        showCourseLengthField = true
        showWeatherField = true
        showTrackConditionField = true
        showMemoField = true
    }
}

#Preview {
    SettingsTabView()
}

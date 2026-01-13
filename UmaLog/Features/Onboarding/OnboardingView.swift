import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("prefersQuickEntry") private var prefersQuickEntry = true
    @AppStorage("showRacecourseField") private var showRacecourseField = false
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
    @AppStorage("themeColorSelection") private var themeColorSelection = ThemeColorPalette.defaultSelectionId
    @AppStorage("customThemeColorHex") private var customThemeColorHex = ThemeColorPalette.defaultCustomHex

    @State private var isShowingCustomColorPicker = false
    @State private var customColor = ThemeColorPalette.color(from: ThemeColorPalette.defaultCustomHex)

    private var cardBackground: Color {
        Color(.secondarySystemBackground)
    }

    private var mainColor: Color {
        ThemeColorPalette.color(for: themeColorSelection, customHex: customThemeColorHex)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [mainColor.opacity(0.9), mainColor.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    welcomeSection
                    modeSection
                    detailSection
                    appearanceSection
                    completionSection
                }
                .padding()
            }
        }
        .onAppear {
            customColor = ThemeColorPalette.color(from: customThemeColorHex)
            isShowingCustomColorPicker = themeColorSelection == ThemeColorPalette.customId
        }
        .onChange(of: customColor) { _, newValue in
            if let hex = newValue.toHex() {
                customThemeColorHex = hex
            }
        }
    }

    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("うまログへようこそ")
                .font(.title.bold())
                .foregroundStyle(.white)
            Text("最初に、記録のスタイルと見た目を決めましょう。あとから設定でいつでも変えられます。")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding()
        .background(cardBackground.opacity(0.15), in: RoundedRectangle(cornerRadius: 18))
    }

    private var modeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("記録スタイルの選択")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 12) {
                Text("まずはサクッと派か、しっかり派かを選んでください。")
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

    private var detailSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("どこまで記入するか")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 12) {
                Text("チェックを入れた項目が入力画面に出ます。迷ったらあとで変更できます。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                VStack(spacing: 10) {
                    toggleRow(title: "競馬場名", isOn: $showRacecourseField)
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

                VStack(alignment: .leading, spacing: 8) {
                    Text("入力プレビュー")
                        .font(.subheadline.weight(.semibold))
                    LazyVGrid(columns: previewColumns, spacing: 8) {
                        ForEach(previewFields, id: \.self) { field in
                            Text(field)
                                .font(.caption.weight(.semibold))
                                .padding(.vertical, 6)
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 12))
            }
            .padding()
            .background(cardBackground, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("カラーの選択")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 12) {
                Text("気分に合う色を選べます。カスタムカラーも使えます。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: colorGridColumns, spacing: 12) {
                    ForEach(ThemeColorPalette.presets) { preset in
                        Button {
                            themeColorSelection = preset.id
                            isShowingCustomColorPicker = false
                        } label: {
                            colorSwatch(
                                color: ThemeColorPalette.color(from: preset.hex),
                                title: preset.name,
                                isSelected: themeColorSelection == preset.id,
                                showsIcon: false
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        themeColorSelection = ThemeColorPalette.customId
                        withAnimation(.easeInOut) {
                            isShowingCustomColorPicker = true
                        }
                    } label: {
                        colorSwatch(
                            color: ThemeColorPalette.color(from: customThemeColorHex),
                            title: "カスタムカラー",
                            isSelected: themeColorSelection == ThemeColorPalette.customId,
                            showsIcon: true
                        )
                    }
                    .buttonStyle(.plain)
                }

                if isShowingCustomColorPicker {
                    ColorPicker("カスタムカラー", selection: $customColor, supportsOpacity: false)
                        .font(.headline)
                        .padding(.top, 4)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding()
            .background(cardBackground, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var completionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("準備完了")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 12) {
                Text("設定が終わったら、いつものホーム画面へ進みます。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button {
                    hasCompletedOnboarding = true
                } label: {
                    Text("この内容ではじめる")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(mainColor.opacity(0.9))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
            .background(cardBackground, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var previewFields: [String] {
        var fields = ["日付", "レース番号", "式別", "投資額", "払戻額"]
        if showRacecourseField {
            fields.append("競馬場名")
        }
        if showHorseNumberField {
            fields.append("馬番")
        }
        if showJockeyField {
            fields.append("騎手")
        }
        if showHorseNameField {
            fields.append("馬名")
        }
        if showRaceTimeField {
            fields.append("発走予定")
        }
        if showCourseSurfaceField {
            fields.append("コース")
        }
        if showCourseDirectionField {
            fields.append("コースの向き")
        }
        if showCourseLengthField {
            fields.append("コースの長さ")
        }
        if showWeatherField {
            fields.append("天気")
        }
        if showTrackConditionField {
            fields.append("馬場状態")
        }
        if showMemoField {
            fields.append("ひと言メモ")
        }
        return fields
    }

    private var colorGridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    }

    private var previewColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)
    }

    private func modeButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? mainColor.opacity(0.9) : Color(.systemGray5))
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

    private func colorSwatch(color: Color, title: String, isSelected: Bool, showsIcon: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(color)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? Color.white : Color.white.opacity(0.15), lineWidth: isSelected ? 3 : 1)
                )

            if showsIcon {
                Image(systemName: "paintbrush.pointed")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))
            } else if isSelected {
                Image(systemName: "checkmark")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(height: 72)
        .accessibilityLabel(title)
    }

    private func applyQuickPreset() {
        showRacecourseField = false
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
    OnboardingView()
        .modelContainer(previewContainer)
}

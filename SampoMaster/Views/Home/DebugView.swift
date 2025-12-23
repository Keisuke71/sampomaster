import SwiftUI

struct DebugView: View {
    @Bindable var gameData: GameDataManager
    @Environment(\.dismiss) var dismiss
    
    // 入力用の一時ステート
    @State private var targetDate: Date = Date()
    @State private var inputSteps: String = "1000"
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - 日付操作セクション
                Section(header: Text("タイムトラベル設定")) {
                    DatePicker("シミュレート日付", selection: $targetDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .onChange(of: targetDate) { _, newDate in
                            // 日付が変わったら即座にマネージャーに反映
                            gameData.setDebugDate(newDate)
                        }
                    
                    Button("今日（現在時刻）に戻す") {
                        targetDate = Date()
                        gameData.resetDebugMode()
                    }
                    .disabled(gameData.debugDate == nil)
                }
                
                // MARK: - 歩数操作セクション
                Section(header: Text("歩数追加シミュレーション")) {
                    HStack {
                        TextField("追加歩数", text: $inputSteps)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("歩")
                    }
                    
                    Button(action: {
                        if let steps = Int(inputSteps) {
                            gameData.debugAddSteps(steps)
                            // 触覚フィードバック
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                        }
                    }) {
                        HStack {
                            Image(systemName: "figure.walk")
                            Text("歩数を追加してスタミナ変換")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                // MARK: - ステータス確認
                Section(header: Text("現在の内部データ")) {
                    LabeledContent("現在の日付設定", value: gameData.getTodayString())
                    LabeledContent("スタミナ", value: String(format: "%.1f / %.0f", gameData.stamina, gameData.maxStamina))
                    LabeledContent("前回変換時の歩数", value: "\(gameData.lastConvertedSteps) 歩")
                    LabeledContent("最終同期日", value: gameData.lastSyncDate)
                }
                
                // MARK: - リセット系
                Section {
                    Button("スタミナ全回復", action: { gameData.stamina = gameData.maxStamina })
                    Button("スタミナを0にする", action: { gameData.stamina = 0 }).foregroundColor(.red)
                }
                
                Section("パラメーター操作") {
                    // レベル操作を追加
                    Stepper("プレイヤーLv: \(gameData.playerLevel)", value: $gameData.playerLevel, in: 1...99)
                    
                    Button("スタミナ全回復") {
                        // 全回復は maxStamina に合わせる
                        gameData.stamina = gameData.maxStamina
                    }
                    
                    // アイテムによる限界突破テスト用
                    Button("スタミナ石で回復 (+100 突破可)") {
                        gameData.useStaminaPotion(amount: 100)
                    }
                    .foregroundColor(.purple)
                }
                .navigationTitle("デバッグルーム")
                .scrollDismissesKeyboard(.interactively)
                .onAppear {
                    // 画面を開いたときに、現在設定されているデバッグ日付（または今日）をDatePickerに反映
                    targetDate = gameData.currentDate
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
}

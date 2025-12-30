import SwiftUI

struct DebugView: View {
    @Bindable var gameData: GameDataManager
    
    // LevelManagerを受け取れるように追加
    @ObservedObject var levelManager: UserLevelManager
    // var healthManager: HealthKitManager // HealthKitへの書き込みはしないので不要になりました
    
    @Environment(\.dismiss) var dismiss
    
    // 入力用
    @State private var inputSteps: String = "1000"
    
    // 日付操作系はもう不要なら削除してもOKですが、
    // 残す場合はそのまま置いておいてください
    @State private var targetDate: Date = Date()

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - 歩数・経験値追加
                Section(header: Text("デバッグ操作")) {
                    HStack {
                        TextField("追加する歩数(Exp)", text: $inputSteps)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("歩")
                    }
                    
                    Button(action: {
                        if let steps = Int(inputSteps) {
                            // 1. スタミナを加算 (GameDataManager)
                            gameData.debugAddSteps(steps)
                            
                            // 2. 経験値を加算してレベルアップ判定 (LevelManager)
                            levelManager.debugAddExperience(amount: steps)
                            
                            // 完了フィードバック
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                        }
                    }) {
                        HStack {
                            Image(systemName: "figure.walk")
                            Text("歩数を追加 (スタミナ＆Exp)")
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                // MARK: - パラメーター直接操作
                Section(header: Text("ステータス操作")) {
                    Stepper("プレイヤーLv: \(levelManager.level)", value: $levelManager.level, in: 1...Int.max)
                    
                    Button("スタミナ全回復") {
                        gameData.stamina = gameData.maxStamina
                    }
                    Button("スタミナを0にする") {
                        gameData.stamina = 0
                    }
                    .foregroundColor(.red)
                }
                
                // MARK: - 情報表示
                Section(header: Text("現在の状態")) {
                    LabeledContent("現在レベル", value: "\(levelManager.level)")
                    LabeledContent("次のLvまで", value: "\(Int(levelManager.nextLevelExp - levelManager.currentExp)) Exp")
                    LabeledContent("スタミナ", value: "\(Int(gameData.stamina)) / \(Int(gameData.maxStamina))")
                }
            }
            .navigationTitle("デバッグルーム")
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
}

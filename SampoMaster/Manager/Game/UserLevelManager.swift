import Foundation

class UserLevelManager: ObservableObject {
    @Published var level: Int = 1
    @Published var progress: Double = 0.0
    
    // UI表示用
    @Published var currentExp: Int = 0
    @Published var nextLevelExp: Int = 0
    
    // スプレッドシートの基準に合わせた設定
    // Lv100までの累計経験値 = 約370万
    let baseExp: Double = 500.0
    let exponent: Double = 1.1
    
    // ★重要: SwiftDataに保存された「累計経験値」を受け取って、表示を更新する関数
    func updateDisplay(from totalExperience: Double) {
        DispatchQueue.main.async {
            var tempExp = totalExperience
            var tempLevel = 1
            
            // 経験値を消費してレベルを上げていくシミュレーション
            while true {
                let required = self.calculateExpForLevel(tempLevel)
                if tempExp >= required {
                    tempExp -= required
                    tempLevel += 1
                } else {
                    // ここでストップ（現在のレベルと端数の経験値）
                    self.level = tempLevel
                    self.currentExp = Int(tempExp.rounded())
                    self.nextLevelExp = Int(required.rounded())
                    self.progress = tempExp / required
                    break
                }
            }
        }
    }
    
    // 各レベルに必要な経験値を算出する式
    private func calculateExpForLevel(_ level: Int) -> Double {
        return baseExp * pow(Double(level), exponent)
    }
}

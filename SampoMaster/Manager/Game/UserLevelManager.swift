import Foundation
import SwiftUI

class UserLevelManager: ObservableObject {
    
    // MARK: - 公開プロパティ
    @Published var level: Int = 1
    @Published var progress: Double = 0.0
    @Published var currentExp: Int = 0
    @Published var nextLevelExp: Int = 0
    
    // MARK: - 内部プロパティ (保存対象)
    // 累計獲得経験値 (これを保存して強さを維持する)
    private var totalAccumulatedExp: Double = 0.0
    
    // 設定値
    private let baseExp: Double = 500.0
    private let exponent: Double = 1.1
    private let kTotalExpKey = "UserTotalExperience"
    
    init() {
        // アプリ起動時にデータをロード
        loadData()
    }
    
    // MARK: - 経験値加算 (メイン)
    
    /// 経験値を加算してレベル計算を行い、保存する
    /// (本番の歩数反映も、デバッグの追加もこれを使う)
    func addExperience(amount: Int) {
        self.totalAccumulatedExp += Double(amount)
        self.recalculate()
        self.saveData() // ★変更のたびに保存
        
        print("【Level】Exp +\(amount) (Total: \(Int(totalAccumulatedExp)), Lv: \(level))")
    }
    
    // デバッグ用（addExperienceと同じ挙動にする）
    func debugAddExperience(amount: Int) {
        addExperience(amount: amount)
    }
    
    // MARK: - 計算ロジック
    
    private func recalculate() {
        DispatchQueue.main.async {
            var tempExp = self.totalAccumulatedExp
            var tempLevel = 1
            
            while true {
                let required = self.calculateExpForLevel(tempLevel)
                
                if tempExp >= required {
                    tempExp -= required
                    tempLevel += 1
                } else {
                    self.level = tempLevel
                    self.currentExp = Int(tempExp.rounded())
                    self.nextLevelExp = Int(required.rounded())
                    
                    if required > 0 {
                        self.progress = tempExp / required
                    } else {
                        self.progress = 0
                    }
                    break
                }
            }
        }
    }
    
    private func calculateExpForLevel(_ level: Int) -> Double {
        return baseExp * pow(Double(level), exponent)
    }
    
    // MARK: - データ保存/読み込み
    
    private func saveData() {
        UserDefaults.standard.set(totalAccumulatedExp, forKey: kTotalExpKey)
    }
    
    private func loadData() {
        self.totalAccumulatedExp = UserDefaults.standard.double(forKey: kTotalExpKey)
        // ロードした値に基づいてレベルなどを計算して復元
        recalculate()
    }
}

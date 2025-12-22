import Foundation
import SwiftData

@Model
class UserProgress {
    // 獲得した総経験値(レベル計算の元)
    var totalExperience: Double = 0.0
    // 最後に計算処理をした時点での「HealthKitの累計歩数」
    // これと現在の歩数の差分で新しい経験値を計算
    var lastSyncedSteps: Double = 0.0
    // データ作成日
    var createdAt: Date = Date()
    
    init(totalExperience: Double = 0.0, lastSyncedSteps: Double = 0.0) {
        self.totalExperience = totalExperience
        self.lastSyncedSteps = lastSyncedSteps
    }
    
}

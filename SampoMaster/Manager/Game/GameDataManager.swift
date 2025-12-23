import Foundation
import Observation
import HealthKit

@Observable
class GameDataManager {
    // MARK: - プレイヤー基本ステータス
    var playerLevel: Int = 1
    
    // 現在のスタミナ（上限を超えて保持可能）
    var stamina: Double = 0.0
    
    var combatRank: Int = 1
var gatheringRank: Int = 1
    
    // MARK: - スタミナ上限の計算ロジック
    // 「基本1000 + レベル×10 + 装備補正」で自動計算する
    
    var baseMaxStamina: Double = 1000.0
    var equipmentMaxStaminaBonus: Double = 0.0 // 将来の装備用
    
    // 計算型プロパティ：誰かが maxStamina を参照するたびに計算し直す
    var maxStamina: Double {
        let levelBonus = Double(playerLevel) * 10.0
        return baseMaxStamina + levelBonus + equipmentMaxStaminaBonus
    }
    
    // MARK: - 設定値
    // 10歩で1スタミナ
    let stepsPerStamina: Double = 10.0
    
    // MARK: - 内部管理用
    var lastConvertedSteps: Int {
        get { UserDefaults.standard.integer(forKey: "LastConvertedSteps") }
        set { UserDefaults.standard.set(newValue, forKey: "LastConvertedSteps") }
    }
    
    var lastSyncDate: String {
        get { UserDefaults.standard.string(forKey: "LastSyncDate") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "LastSyncDate") }
    }
    
    // デバッグ用
    var debugDate: Date? = nil
    var currentDate: Date { debugDate ?? Date() }

    // MARK: - 歩数 → スタミナ変換（仕様変更反映）
    
    func convertStepsToStamina(todayTotalSteps: Int) {
        let todayStr = getTodayString()
        
        // 日付変更チェック
        if lastSyncDate != todayStr {
            lastConvertedSteps = 0
            lastSyncDate = todayStr
        }
        
        // 差分（新規歩数）の計算
        let newSteps = max(0, todayTotalSteps - lastConvertedSteps)
        
        if newSteps > 0 {
            // 10歩 = 1スタミナ
            let gainedStamina = Double(newSteps) / stepsPerStamina
            
            // 【重要】オーバーフロー制御のロジック
            // 現在スタミナが上限未満の場合のみ、回復を受け付ける
            if stamina < maxStamina {
                let potentialStamina = stamina + gainedStamina
                
                // 歩数による回復は、最大値（maxStamina）で止まる（＝溢れない）
                // ただし、すでにアイテム等で maxStamina を超えている場合は、何もしない（減らしもしない）
                stamina = min(maxStamina, potentialStamina)
                
                print("歩数反映: +\(newSteps)歩 -> スタミナ回復 (現在: \(String(format: "%.1f", stamina)) / \(Int(maxStamina)))")
            } else {
                print("歩数反映スキップ: スタミナが上限に達しているため回復しません")
            }
            
            // スタミナが増えても増えなくても、「歩いた分の計算は終わった」として記録更新
            lastConvertedSteps = todayTotalSteps
        }
    }
    
    // MARK: - アイテム使用（例）
    
    /// スタミナ回復アイテムを使う（こちらは上限を超えて回復可能）
    func useStaminaPotion(amount: Double) {
        stamina += amount
        print("アイテム使用: スタミナ +\(amount) (現在: \(String(format: "%.1f", stamina)))")
    }
    
    // MARK: - ユーティリティ
    
    func getTodayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: currentDate)
    }
    
    // MARK: - デバッグ機能
    
    func setDebugDate(_ date: Date) { debugDate = date }
    func resetDebugMode() { debugDate = nil }
    
    func debugAddSteps(_ steps: Int) {
        let simulatedTotalSteps = lastConvertedSteps + steps
        convertStepsToStamina(todayTotalSteps: simulatedTotalSteps)
    }
    
    // レベルアップのテスト用
    func debugLevelUp() {
        playerLevel += 1
        print("レベルアップ！ Lv.\(playerLevel) Maxスタミナ -> \(Int(maxStamina))")
    }
}

// --- データ定義 ---

/// マップ上の探索ポイント
struct ExplorationPoint: Identifiable {
    let id: String
    let name: String
    let description: String
    let coordinate: CGPoint // マップ上の表示位置 (S-TPIAを中心とした相対座標)
    let requiredStoryId: Int // 解放に必要なストーリー進行度
}

/// ストーリーミッション
struct StoryMission: Identifiable {
    let id: Int
    let title: String
    let summary: String
    let rewardSteps: Int // クリア報酬（歩数/スタミナなど）
}

// --- マップデータ ---

// 拡張機能としてデータを持たせる
extension GameDataManager {
    
    // 現在のストーリー進行度（0: チュートリアル前, 1: 第1話クリア...）
    // ※実際は UserDefaults で保存すべきですが、今は変数で
    // var currentStoryProgress: Int = 0 // ← クラス内に定義してください
    
    // 全ミッションのリスト
    var allMissions: [StoryMission] {
        [
            StoryMission(id: 1, title: "Episode 0: 始動", summary: "周辺の静止濃度が上昇しています。まずは近場の『旧市街地・東』へ向かい、状況を確認してください。", rewardSteps: 500),
            StoryMission(id: 2, title: "Episode 1: 拡張", summary: "S-TPIA外部へのルート確保のため、障害を取り除きます。", rewardSteps: 1000)
        ]
    }
    
    // 全エリアのリスト
    var allLocations: [ExplorationPoint] {
        [
            // S-TPIA（拠点）
            ExplorationPoint(id: "home", name: "S-TPIA", description: "人類最後の砦。我らが拠点。", coordinate: CGPoint(x: 0, y: 0), requiredStoryId: 0),
            
            // チュートリアル用エリア
            ExplorationPoint(id: "area_a", name: "旧市街地・東", description: "かつての居住区。廃材が多く残るが、低ランクの静止体も徘徊している。", coordinate: CGPoint(x: 80, y: -50), requiredStoryId: 0),
            
            // ミッション1クリアで解放されるエリア
            ExplorationPoint(id: "forest", name: "石化の森", description: "植物が結晶化して固まった森。貴重なエネルギー資源が眠る。", coordinate: CGPoint(x: -60, y: 120), requiredStoryId: 1),
            
            // さらに奥地
            ExplorationPoint(id: "ruins", name: "産業廃棄区画", description: "危険度高。強力な静止反応あり。", coordinate: CGPoint(x: 150, y: 80), requiredStoryId: 2)
        ]
    }
    
    /// ストーリーを進める（デバッグ用・クリア処理用）
    func completeMission(missionId: Int) {
        if playerLevel <= missionId { // 簡易的な進行管理
            // currentStoryProgress = missionId // ← クラス内の変数を使う
            print("ミッション \(missionId) クリア！ 新しいエリアが解放されました。")
        }
    }
}

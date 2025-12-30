import Foundation
import SwiftUI
import Observation

// MARK: - データ定義構造体 (クラスの外に出してアクセスしやすくします)

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
    let rewardSteps: Int
}

@Observable
class GameDataManager {
    
    // MARK: - プレイヤー基本ステータス
    // UserLevelManagerのレベルを表示用に同期して保持する
    var playerLevel: Int = 1
    
    // ランクシステム（戦闘・採集）
    var combatRank: Int = 1
    var gatheringRank: Int = 1
    
    // 現在のスタミナ
    var stamina: Double = 0.0
    
    // スタミナ設定
    // ★修正: 10歩で1スタミナ
    let stepsPerStamina: Double = 10.0
    
    var baseMaxStamina: Double = 1000.0 // 基礎値
    // 計算プロパティ: レベルに応じて上限が増える
    var maxStamina: Double {
        let levelBonus = Double(playerLevel) * 10.0 // レベル×10 加算
        return baseMaxStamina + levelBonus
    }
    
    // MARK: - 内部管理用 (差分計算システム)
    
    // 最後に同期した時点でのHealthKit「累計」歩数
    private var lastSyncedCumulativeSteps: Double = 0
    
    // 最後にログインした日付 (日付変更判定用)
    private var lastLoginDate: Date = Date()
    
    // デバッグ用日付操作
    var debugDate: Date? = nil
    var currentDate: Date { debugDate ?? Date() }
    
    // MARK: - 保存キー定義
    private let kStaminaKey = "SavedStamina"
    private let kCombatRankKey = "CombatRank"
    private let kGatheringRankKey = "GatheringRank"
    private let kLastSyncedStepsKey = "LastSyncedSteps"
    private let kLastLoginDateKey = "LastLoginDate"
    
    // MARK: - 初期化
    init() {
        loadData()
    }
    
    // MARK: - メインロジック: 歩数同期 & 差分反映
    
    /// HealthKitの累計歩数を受け取り、前回からの差分を計算してスタミナと経験値にする
    func processStepsUpdate(currentCumulativeSteps: Double, levelManager: UserLevelManager) {
        
        // 1. レベルの同期 (表示用)
        self.playerLevel = levelManager.level
        
        // 2. 初回起動時などのガード処理
        if lastSyncedCumulativeSteps == 0 {
            lastSyncedCumulativeSteps = currentCumulativeSteps
            saveData()
            return
        }
        
        // 3. 差分を計算 (今回 - 前回)
        let diff = currentCumulativeSteps - lastSyncedCumulativeSteps
        
        // 4. 歩数が増えている場合のみ処理
        if diff > 0 {
            print("【Game】差分検知: +\(Int(diff))歩")
            
            // --- A. スタミナ回復 ---
            // 10歩で1スタミナ回復
            let gainedStamina = diff / stepsPerStamina
            addStamina(amount: gainedStamina)
            
            // --- B. 経験値加算 ---
            // LevelManagerに「増えた分」を渡して処理してもらう
            levelManager.addExperience(amount: Int(diff))
            
            // レベルアップした可能性があるので、表示用レベルを再取得
            self.playerLevel = levelManager.level
            
            // 5. 処理が終わったら「ここまで処理済み」として更新して保存
            lastSyncedCumulativeSteps = currentCumulativeSteps
            saveData()
        }
        
        // 5. 日付変更チェック (ログインボーナス等)
        checkDailyReset()
    }
    
    // MARK: - スタミナ管理
    
    /// スタミナを回復させる（上限maxStaminaまで）
    func addStamina(amount: Double) {
        if stamina < maxStamina {
            stamina += amount
            if stamina > maxStamina {
                stamina = maxStamina
            }
            saveData() // 回復時も保存
        }
    }
    
    /// スタミナを消費する（足りなければ false を返す）
    func consumeStamina(amount: Double) -> Bool {
        if stamina >= amount {
            stamina -= amount
            saveData() // 消費したら即保存
            return true
        } else {
            return false
        }
    }
    
    // MARK: - 日付変更・ログインボーナス処理
    
    private func checkDailyReset() {
        let calendar = Calendar.current
        // 保存されている最終ログイン日と「今日」が違う場合
        if !calendar.isDateInToday(lastLoginDate) {
            print("【Game】日付変更を検知！ (前回: \(lastLoginDate))")
            
            // --- ここにログインボーナス処理 ---
            
            // 日付を更新して保存
            lastLoginDate = Date()
            saveData()
        }
    }
    
    // MARK: - デバッグ機能
    
    func setDebugDate(_ date: Date) { debugDate = date }
    func resetDebugMode() { debugDate = nil }
    
    func debugAddSteps(_ steps: Int) {
        // デバッグ時は直接スタミナを増やす(10歩=1スタミナ換算)
        let gained = Double(steps) / stepsPerStamina
        addStamina(amount: gained)
    }
    
    // MARK: - データ保存/読み込み (UserDefaults)
    
    private func saveData() {
        let defaults = UserDefaults.standard
        defaults.set(stamina, forKey: kStaminaKey)
        defaults.set(combatRank, forKey: kCombatRankKey)
        defaults.set(gatheringRank, forKey: kGatheringRankKey)
        defaults.set(lastSyncedCumulativeSteps, forKey: kLastSyncedStepsKey)
        defaults.set(lastLoginDate, forKey: kLastLoginDateKey)
    }
    
    private func loadData() {
        let defaults = UserDefaults.standard
        self.stamina = defaults.double(forKey: kStaminaKey)
        self.combatRank = defaults.integer(forKey: kCombatRankKey)
        if self.combatRank == 0 { self.combatRank = 1 } // 初期値
        
        self.gatheringRank = defaults.integer(forKey: kGatheringRankKey)
        if self.gatheringRank == 0 { self.gatheringRank = 1 } // 初期値
        
        self.lastSyncedCumulativeSteps = defaults.double(forKey: kLastSyncedStepsKey)
        
        if let date = defaults.object(forKey: kLastLoginDateKey) as? Date {
            self.lastLoginDate = date
        }
    }
    
    // MARK: - マップ・ミッションデータ定義
    
    var allMissions: [StoryMission] {
        [
            StoryMission(id: 1, title: "Episode 0: 始動", summary: "周辺の静止濃度が上昇しています。まずは近場の『旧市街地・東』へ向かい、状況を確認してください。", rewardSteps: 500),
            StoryMission(id: 2, title: "Episode 1: 拡張", summary: "S-TPIA外部へのルート確保のため、障害を取り除きます。", rewardSteps: 1000)
        ]
    }
    
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
}

//
//  RankManager.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/07/01.
//

import Foundation
import Combine

/// ランクシステムの管理クラス

// MARK: - Rank計算

import Foundation
import Combine

/// 累計歩数に応じたゲーム風レベル管理クラス
final class RankManager: ObservableObject {
    static let shared = RankManager()

    /// 基本ステップ数 (1 レベル目)
    private let baseStepsPerRank: Int = 1000
    /// レベルアップごとの倍率 (1.005x)
    private let growthFactor: Double = 1.005

    /// UserDefaults 用キー
    private let totalKey = "rankTotalSteps"
    private let lastFetchKey = "rankLastFetch"
    private let rankKey = "rankCurrent"
    private let lastFetchDateKey    = "levelLastFetchDate"
    private let initialFetchDateKey = "rankInitialFetchDate"

    /// 累計歩数 (アプリ開始以降の合計)
    @Published private(set) var totalSteps: Int = 0
    /// 最後にフェッチした今日の歩数
    private var lastFetchedStepCount: Int = 0
    /// 現在レベル
    @Published private(set) var currentRank: Int = 0
    
    /// 最初にデータを取得した日時
    @Published private(set) var initialFetchDate: Date

    private var cancellables = Set<AnyCancellable>()

    private init() {
        let defaults = UserDefaults.standard

        // ── 初回起動またはリセット時に initialFetchDate を設定 ──
        if defaults.object(forKey: initialFetchDateKey) == nil {
            let now = Date()
            defaults.set(now.timeIntervalSince1970, forKey: initialFetchDateKey)
        }
        // 永続化データを読み込む
        initialFetchDate = Date(
            timeIntervalSince1970: defaults.double(forKey: initialFetchDateKey)
        )
        totalSteps       = defaults.integer(forKey: totalKey)
        currentRank     = defaults.integer(forKey: rankKey)

        // 歩数更新を購読
        StepCountViewModel.shared.$stepCount
            .sink { [weak self] newCount in
                self?.handleStepCountUpdate(newCount)
            }
            .store(in: &cancellables)
    }
    
    var lastFetchDate: Date {
            let epoch = UserDefaults.standard.double(forKey: lastFetchDateKey)
            return Date(timeIntervalSince1970: epoch)
        }
    
    ///初期化トリガー
    func startTracking() {
        let current = StepCountViewModel.shared.stepCount
        handleStepCountUpdate(current)
    }

    /// 歩数更新を受け取り、累計を更新してレベル計算
    private func handleStepCountUpdate(_ newCount: Int) {
        let defaults   = UserDefaults.standard
        let lastEpoch  = defaults.double(forKey: lastFetchDateKey)
        let lastDate   = Date(timeIntervalSince1970: lastEpoch)
        let now        = Date()
        
        HealthKitManager.shared.fetchStepCount(from: lastDate, to: now) { [weak self] (delta: Int, _ ) in
            guard let self = self else { return }
            // 累計に delta を加算
            self.totalSteps += delta
            // 取得時刻と累計を永続化
            defaults.set(now.timeIntervalSince1970, forKey: self.lastFetchDateKey)
            defaults.set(self.totalSteps,             forKey: self.totalKey)
            // メインスレッドでレベル計算
            DispatchQueue.main.async {
                self.updateRank()
            }
        }
    }

    /// レベル更新ロジック
    private func updateRank() {
        var stepsRemaining = totalSteps
        var rank = 0
        var required = baseStepsPerRank
        // 累計歩数を使って段階的にレベル計算
        while stepsRemaining >= required {
            stepsRemaining -= required
            rank += 1
            required = Int(Double(required) * growthFactor)
        }
        if rank != currentRank {
            currentRank = rank
            UserDefaults.standard.set(currentRank, forKey: rankKey)
        }
    }

    /// リセット：累計を0、レベルを0に戻す
    func resetTracking() {
            let now = Date(timeIntervalSince1970:
                UserDefaults.standard.double(forKey: lastFetchDateKey))
            // ① 起点を書き換え
            UserDefaults.standard.set(now.timeIntervalSince1970, forKey: lastFetchDateKey)
            // ② 累計＆レベルをゼロ化
            totalSteps = 0
            currentRank = 0
            UserDefaults.standard.set(0, forKey: totalKey)
            UserDefaults.standard.set(0, forKey: rankKey)
        }
    
    // MARK: プログレスバー
    
    /// 次のレベルに必要な歩数
        var stepsForNextRank: Int {
            var required = baseStepsPerRank
            for _ in 0..<currentRank {
                required = Int(Double(required) * growthFactor)
            }
            return required
        }

        /// 現レベル帯で消化された歩数
        var stepsIntoCurrentRank: Int {
            var consumed = 0
            var required = baseStepsPerRank
            for _ in 0..<currentRank {
                consumed += required
                required = Int(Double(required) * growthFactor)
            }
            return max(0, totalSteps - consumed)
        }

        /// 次のレベルへの進捗率 (0.0 ～ 1.0)
        var progress: Double {
            let req = stepsForNextRank
            guard req > 0 else { return 0 }
            return min(max(Double(stepsIntoCurrentRank) / Double(req), 0.0), 1.0)
        }

        /// 次のレベルまで残り何歩
        var stepsRemainingForNextRank: Int {
            max(0, stepsForNextRank - stepsIntoCurrentRank)
        }

}

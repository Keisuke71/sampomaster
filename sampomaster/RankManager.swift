//
//  RankManager.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/07/01.
//  Updated to use TotalDataManager for cumulative data

import Foundation
import Combine

/// ランクシステムの管理クラス
@MainActor
final class RankManager: ObservableObject {
    static let shared = RankManager()

    // MARK: - ランク計算定数
    private let baseStepsPerRank: Int = 1000      // 1ランクに必要な基礎歩数
    private let growthFactor: Double = 1.005      // ランクごとの増加倍率

    // MARK: - 公開プロパティ
    /// 現在ランク
    @Published private(set) var currentRank: Int = 0

    // MARK: - Combine
    private var cancellables = Set<AnyCancellable>()

    private init() {
        // TotalDataManager から累計歩数の変化を購読し、ランク更新
        TotalDataManager.shared.$totalSteps
            .sink { [weak self] total in
                self?.updateRank(totalSteps: total)
            }
            .store(in: &cancellables)
    }

    // MARK: - ランク更新ロジック
    private func updateRank(totalSteps: Int) {
        var stepsRemaining = totalSteps
        var rank = 0
        var required = baseStepsPerRank

        // 累計歩数を使って段階的にランク計算
        while stepsRemaining >= required {
            stepsRemaining -= required
            rank += 1
            required = Int(Double(required) * growthFactor)
        }
        if rank != currentRank {
            currentRank = rank
            // 永続化（必要に応じて）
            UserDefaults.standard.set(currentRank, forKey: "rankCurrent")
        }
    }

    // MARK: - プログレス計算
    /// 次のランクに必要な歩数
    var stepsForNextRank: Int {
        var required = baseStepsPerRank
        for _ in 0..<currentRank {
            required = Int(Double(required) * growthFactor)
        }
        return required
    }

    /// 現在ランク帯で消化された歩数
    var stepsIntoCurrentRank: Int {
        var consumed = 0
        var required = baseStepsPerRank
        for _ in 0..<currentRank {
            consumed += required
            required = Int(Double(required) * growthFactor)
        }
        return max(0, TotalDataManager.shared.totalSteps - consumed)
    }

    /// 次のランクへの進捗率 (0.0 ～ 1.0)
    var progress: Double {
        let req = stepsForNextRank
        guard req > 0 else { return 0 }
        return min(max(Double(stepsIntoCurrentRank) / Double(req), 0.0), 1.0)
    }

    /// 次のランクまで残り何歩
    var stepsRemainingForNextRank: Int {
        max(0, stepsForNextRank - stepsIntoCurrentRank)
    }
}

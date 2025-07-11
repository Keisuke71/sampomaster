//
//  CurrencyViewModel.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/07/09.
//

import SwiftUI
import Foundation
import Combine

/// ゲーム内通貨（クリスタル、シルバー）を管理する ViewModel
@MainActor
final class CurrencyViewModel: ObservableObject {
    static let shared = CurrencyViewModel()

    @Published private(set) var crystals: Int = 0
    @Published private(set) var silver: Int = 0

    // トースト表示フラグ
    @Published var showCrystalToast: Bool = false
    // トースト用に最後に付与されたクリスタル数
    @Published var lastAwardedAmount: Int = 0

    private var lastAwardedUnits: Int = 0
    private var cancellables = Set<AnyCancellable>()
    private let defaults = UserDefaults.standard
    private let totalManager = TotalDataManager.shared

    private init() {
        // 永続化データ読み込み
        crystals = defaults.integer(forKey: "crystals")
        silver   = defaults.integer(forKey: "silver")
        lastAwardedUnits = defaults.integer(forKey: "lastAwardedUnits")

        // 総歩数更新を購読してクリスタル付与をチェック
        totalManager.$totalSteps
                    .sink { [weak self] total in
                        Task { @MainActor in
                            self?.awardCrystals(for: total)
                        }
                    }
                    .store(in: &cancellables)
            }


    // MARK: - Award Logic
    /// 1000歩ごとに25クリスタル付与 (初回起動後の累計から重複防止)
    private func awardCrystals(for totalSteps: Int) {
            let units = totalSteps / 1000
            let diff = units - lastAwardedUnits
            guard diff > 0 else { return }
            let amount = diff * 25

            crystals += amount
            defaults.set(crystals, forKey: "crystals")

            // トースト用にセット
            lastAwardedAmount = amount
            showCrystalToast = true

            // 数秒後にトースト非表示
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    self.showCrystalToast = false
                }
            }

            // 起点更新
            lastAwardedUnits = units
            defaults.set(lastAwardedUnits, forKey: "lastAwardedUnits")
        }
    
    // MARK: - Silver logic placeholder
    func addSilver(_ amount: Int) {
        guard amount > 0 else { return }
        silver += amount
        defaults.set(silver, forKey: "silver")
    }

    /// デバッグ用：通貨リセット
    func resetCurrencies() {
        crystals = 0
        silver   = 0
        lastAwardedUnits = 0
        defaults.set(0, forKey: "crystals")
        defaults.set(0, forKey: "silver")
        defaults.set(0, forKey: "lastAwardedUnits")
    }
}

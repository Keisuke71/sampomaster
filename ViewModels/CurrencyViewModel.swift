//
//  CurrencyViewModel.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/07/09.
//

import SwiftUI

/// ゲーム内通貨（クリスタル、シルバー）を管理する ViewModel
@MainActor
final class CurrencyViewModel: ObservableObject {
    static let shared = CurrencyViewModel()

    /// クリスタル通貨
    @Published private(set) var crystals: Int = 0
    /// シルバー通貨
    @Published private(set) var silver: Int = 0

    private init() {
        // 初期値読み込みやデバッグ用サンプル
        loadStoredValues()
    }

    /// 通貨情報を永続化ストレージから読み込む
    private func loadStoredValues() {
        let defaults = UserDefaults.standard
        crystals = defaults.integer(forKey: "crystals")
        silver   = defaults.integer(forKey: "silver")
    }

    /// クリスタルを追加
    func addCrystals(_ amount: Int) {
        guard amount > 0 else { return }
        crystals += amount
        UserDefaults.standard.set(crystals, forKey: "crystals")
    }

    /// シルバーを追加
    func addSilver(_ amount: Int) {
        guard amount > 0 else { return }
        silver += amount
        UserDefaults.standard.set(silver, forKey: "silver")
    }

    /// 通貨をリセット（デバッグ用）
    func resetCurrencies() {
        crystals = 0
        silver   = 0
        let defaults = UserDefaults.standard
        defaults.set(0, forKey: "crystals")
        defaults.set(0, forKey: "silver")
    }
}

//
//  StepCountViewModel.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/04/28.
//

import SwiftUI

class StepCountViewModel: ObservableObject {
    @Published var stepCount: Int = 0
    @Published var goal: Int = 10000

    /// HealthKitの許可をリクエスト
    func requestAuthorization() {
        HealthKitManager.shared.requestAuthorization { success, error in
            // 必要に応じてエラー処理
        }
    }

    /// 今日の歩数合計を取得して published プロパティに反映
    func fetchTodayStepCount() {
        HealthKitManager.shared.fetchTodayStepCount { count, error in
            DispatchQueue.main.async {
                if let count = count {
                    self.stepCount = count
                }
                // 必要に応じてエラー処理
            }
        }
    }
}

//
//  StepCountViewModel.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/04/28.
//

import SwiftUI

class StepCountViewModel: ObservableObject {
    @Published var stepCount: Int = 0
    @Published var distance: Double = 0.0
    @Published var goal: Int = 10000
    @Published var weight: Double?
    @Published var calories: Int = 0
    
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
    
    /// 今日の歩行距離を取得して published プロパティに反映
    func fetchTodayWalkingDistance() {
        HealthKitManager.shared.fetchTodayWalkingDistance { meters, _ in
            DispatchQueue.main.async {
                if let m = meters {
                    self.distance = m
                    self.updateCalories()
                }
            }
        }
    }
    
    func fetchLatestWeight(){
        HealthKitManager.shared.fetchLatestWeight { kg, _ in
            DispatchQueue.main.async {
                self.weight = kg
                self.updateCalories()
            }
        }
    }
    
    // 体重・距離・歩数取得後に消費カロリーを計算
    private func updateCalories() {
        guard let w = weight else { return }
        let burned = CalorieCalc.caloriesBurned(distanceMeters: distance, weightKg: w)
        DispatchQueue.main.async {
            self.calories = Int(burned)
        }
    }
}

//
//  HealthKitManager.swift
//  SampoMaster
//
//  Created by 松本 圭祐 on 2025/12/21.
//

import Foundation
import HealthKit

// データをUIに伝えるために ObservableObject に準拠させる
class HealthKitManager: ObservableObject {
    
    // UI側で監視したいデータには @Published をつける
    @Published var calories: Double = 0
    @Published var stepCount: Double = 0
    @Published var walkingDistance: Double = 0 //距離(メートル)
    @Published var isAuthorized: Bool = false
    
    // HealthKitを扱うためのストア
    private let healthStore = HKHealthStore()
    
    // 読み書きしたいデータの種類を定義
    // 今回は「歩数(読む)」「体重(読む/書く)」「距離(読む)」などを想定
    private let readTypes: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .bodyMass)!
    ]
    
    private let shareTypes: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .bodyMass)!
    ]
    
    // 初期化時に権限リクエストを行う（または画面表示時に呼ぶ）
    func requestAuthorization() {
        // HealthKitが利用可能かチェック
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }
        
        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.isAuthorized = true
                    // 許可されたらデータを取得する
                    self?.fetchAllData()
                } else {
                    print("Authorization failed: \(String(describing: error))")
                }
            }
        }
    }
    
    // データ更新を一括で行う
    func fetchAllData() {
        fetchTodayStepCount()
        fetchTodayDistance()
        fetchTodayCalories()
    }
    
    // 今日の歩数を取得する関数
    func fetchTodayStepCount() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        // 今日の0:00を基準にする
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        // 検索条件: 今日の0:00 〜 現在
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        // クエリを作成 (StatisticsQueryを使うと合計計算が楽)
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            
            guard let result = result, let sum = result.sumQuantity() else {
                print("歩数データの取得に失敗、またはデータなし")
                return
            }
            
            // 取得した値を「歩(count)」単位のDoubleとして取り出す
            let steps = sum.doubleValue(for: HKUnit.count())
            
            // UIの更新はメインスレッドで行う
            DispatchQueue.main.async {
                self.stepCount = steps
                print("今日の歩数: \(steps)")
            }
        }
        healthStore.execute(query)
    }
    // 歩行距離を取得
    func fetchTodayDistance() {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            
            guard let result = result, let sum = result.sumQuantity() else {
                print("距離データの取得に失敗、またはデータなし")
                return
            }
            
            // 距離をメートル単位で取得
            let distance = sum.doubleValue(for: HKUnit.meter())
            
            DispatchQueue.main.async {
                self.walkingDistance = distance
                print("今日の距離: \(distance) m")
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchTodayCalories() {
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {return}
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: calorieType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("カロリーデータの取得に失敗、またはデータなし")
                return
            }
            //単位をキロカロリーで取得
            let kcal = sum.doubleValue(for: HKUnit.kilocalorie())
            
            DispatchQueue.main.async {
                self.calories = kcal
            }
        }
        
        healthStore.execute(query)
    }
}

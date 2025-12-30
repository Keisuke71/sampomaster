//
//  HealthKitManager.swift
//  SampoMaster
//
//  Created by 松本 圭祐 on 2025/12/21.
//

import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    
    // UI監視用
    @Published var calories: Double = 0
    @Published var stepCount: Double = 0
    @Published var walkingDistance: Double = 0
    @Published var cumulativeSteps: Double = 0
    @Published var isAuthorized: Bool = false
    @Published var activityHistory: [DailyActivity] = []
    
    private let healthStore = HKHealthStore()
    private let kInstallDateKey = "AppInstallDate"
    
    // 読み書きデータの定義
    private let readTypes: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .bodyMass)!
    ]
    
    private let shareTypes: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .bodyMass)!
    ]
    
    // MARK: - インストール日の管理
    
    /// アプリのインストール日（初回起動日）を取得。
    /// ★開発用修正: データが途切れないよう、初回保存時に「7日前」として保存する
    private var installDate: Date {
        let defaults = UserDefaults.standard
        if let date = defaults.object(forKey: kInstallDateKey) as? Date {
            return date
        } else {
            // ここで「今日」ではなく「7日前」を起点にする
            let now = Date()
            let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: now)!
            defaults.set(sevenDaysAgo, forKey: kInstallDateKey)
            print("【System】初回起動日をセット(7日前): \(sevenDaysAgo)")
            return sevenDaysAgo
        }
    }
    
    // MARK: - 認証・初期化
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        healthStore.requestAuthorization(toShare: shareTypes, read: readTypes) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.isAuthorized = true
                    self?.fetchAllData()
                } else {
                    print("Authorization failed: \(String(describing: error))")
                }
            }
        }
    }
    
    func fetchAllData() {
        fetchTodayStepCount()
        fetchTodayDistance()
        fetchTodayCalories()
        
        // インストール日（実質7日前）の0:00から取得
        let startOfInstallDate = Calendar.current.startOfDay(for: self.installDate)
        fetchCumulativeSteps(from: startOfInstallDate)
    }
    
    // MARK: - 今日のデータ取得
    
    func fetchTodayStepCount() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            // エラー時は何もしない（前の値をキープ）
            if error != nil { return }
            guard let result = result, let sum = result.sumQuantity() else { return }
            
            let steps = sum.doubleValue(for: .count())
            DispatchQueue.main.async { self.stepCount = steps }
        }
        healthStore.execute(query)
    }
    
    func fetchTodayDistance() {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else { return }
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            if error != nil { return }
            guard let result = result, let sum = result.sumQuantity() else { return }
            
            let dist = sum.doubleValue(for: .meter())
            DispatchQueue.main.async { self.walkingDistance = dist }
        }
        healthStore.execute(query)
    }
    
    func fetchTodayCalories() {
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: calorieType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            if error != nil { return }
            guard let result = result, let sum = result.sumQuantity() else { return }
            
            let cal = sum.doubleValue(for: .kilocalorie())
            DispatchQueue.main.async { self.calories = cal }
        }
        healthStore.execute(query)
    }
    
    // MARK: - 累計データ取得 (修正版)
    
    func fetchCumulativeSteps(from startDate: Date) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let now = Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            
            // ★修正1: エラーが出たら「0」にせず、リターンして無視する（画面の数字を消さない）
            if let error = error {
                print("累計取得エラー(無視): \(error.localizedDescription)")
                return
            }
            
            // データ自体がない場合は仕方ないので無視、あるいは0にする
            // ここでは念の為無視する（前のデータを残す）
            guard let result = result, let sum = result.sumQuantity() else {
                return
            }
            
            let totalSteps = sum.doubleValue(for: .count())
            
            DispatchQueue.main.async {
                self.cumulativeSteps = totalSteps
                // デバッグログ: 開始日時をJSTで確認しやすいように出力
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm"
                print("累計歩数更新: \(Int(totalSteps))歩 (集計開始: \(formatter.string(from: startDate)))")
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: - 履歴・その他
    
    func fetchHistory(days: Int, completion: @escaping ([DailyActivity]) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let now = Date()
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days + 1, to: calendar.startOfDay(for: now))!
        let interval = DateComponents(day: 1)
        
        let stepQuery = HKStatisticsCollectionQuery(
            quantityType: stepType,
            quantitySamplePredicate: nil,
            options: .cumulativeSum,
            anchorDate: calendar.startOfDay(for: now),
            intervalComponents: interval
        )
        
        stepQuery.initialResultsHandler = { _, results, error in
            if error != nil { return }
            
            var tempActivities: [DailyActivity] = []
            results?.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                let date = statistics.startDate
                let steps = statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0
                let activity = DailyActivity(date: date, steps: steps, distance: steps * 0.7, calories: steps * 0.04)
                tempActivities.append(activity)
            }
            DispatchQueue.main.async { completion(tempActivities.reversed()) }
        }
        healthStore.execute(stepQuery)
    }
    
    // デバッグ用
    func fetchSteps(for date: Date, completion: @escaping (Int) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0); return
        }
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            if error != nil { completion(0); return }
            let steps = Int(result?.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            DispatchQueue.main.async { completion(steps) }
        }
        healthStore.execute(query)
    }
}

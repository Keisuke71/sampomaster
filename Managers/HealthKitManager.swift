//
//  HealthKitManager.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/04/28.
//

import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    private var stepObserverQuery: HKObserverQuery?
    private var distanceObserverQuery: HKObserverQuery?
    
    /// HealthKitの使用許可をリクエスト
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable(),
              let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount),
              let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
              let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)
        else {
            completion(false, nil)
            return
        }
        healthStore.requestAuthorization(toShare: [], read: [stepType, distanceType, weightType], completion: completion)
    }
    
    /// 今日の歩数合計を取得
    func fetchTodayStepCount(completion: @escaping (Int?, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable(),
              let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)
        else {
            completion(nil, nil)
            return
        }
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )
        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            if let sum = result?.sumQuantity() {
                let count = Int(sum.doubleValue(for: .count()))
                completion(count, nil)
            } else {
                completion(nil, error)
            }
        }
        healthStore.execute(query)
    }
    
    //今日の歩数（メートル）を取得
    func fetchTodayWalkingDistance(completion: @escaping (Double?, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable(),
              let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
        else {
            completion(nil, nil)
            return
        }
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )
        let query = HKStatisticsQuery(
            quantityType: distanceType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            if let sum = result?.sumQuantity() {
                let meters = sum.doubleValue(for: HKUnit.meter())
                completion(meters, nil)
            } else {
                completion(nil, error)
            }
        }
        healthStore.execute(query)
    }
    
    func fetchLatestWeight(completion: @escaping (Double?, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable(),
              let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)
        else {
            completion(nil, nil)
            return
        }
        
        //日付の範囲は広くとって、最新１件を取得
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: weightType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            if let sample = samples?.first as? HKQuantitySample{
                let kg = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                completion(kg, nil)
            } else {
                completion(nil, error)
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: - Cumulative Queries
    /// 指定期間の累計を返すユーティリティ（noDataは0扱い）
    func fetchCumulativeSum(
        identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        from start: Date,
        to end: Date = Date(),
        completion: @escaping (Double, Error?) -> Void
    ) {
        guard let type = HKQuantityType.quantityType(forIdentifier: identifier) else {
            completion(0, nil)
            return
        }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [])
        let query = HKStatisticsQuery(
            quantityType: type,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            var value = 0.0
            if let sum = result?.sumQuantity() {
                value = sum.doubleValue(for: unit)
            } else if let hkError = error as? HKError, hkError.code == .errorNoData {
                value = 0.0
            }
            completion(value, nil)
        }
        healthStore.execute(query)
    }
    
    /// 起点日時から総歩数を取得
    func fetchTotalSteps(
        from start: Date,
        to end: Date = Date(),
        completion: @escaping (Int, Error?) -> Void
    ) {
        fetchCumulativeSum(identifier: .stepCount, unit: .count(), from: start, to: end) { value, _ in
            completion(Int(value), nil)
        }
    }
    
    /// 起点日時から総距離を取得
    func fetchTotalDistance(
        from start: Date,
        to end: Date = Date(),
        completion: @escaping (Double, Error?) -> Void
    ) {
        fetchCumulativeSum(identifier: .distanceWalkingRunning, unit: .meter(), from: start, to: end, completion: completion)
    }
}
extension HealthKitManager {
    /// バックグラウンドでの歩数・距離更新を有効化
    func enableStepBackgroundDelivery() {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount),
              let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)
        else {
            return
        }

        // Background Delivery の設定
        healthStore.enableBackgroundDelivery(
            for: stepType,
            frequency: .immediate
        ) { success, error in
            print("🔔 歩数バックグラウンド配信:", success, error ?? "")
        }
        healthStore.enableBackgroundDelivery(
            for: distanceType,
            frequency: .immediate
        ) { success, error in
            print("🔔 距離バックグラウンド配信:", success, error ?? "")
        }

        // 歩数更新の ObserverQuery
        stepObserverQuery = HKObserverQuery(
            sampleType: stepType,
            predicate: nil
        ) { [weak self] _, completionHandler, error in
            self?.fetchTodayStepCount { _, _ in }
            completionHandler()
        }
        healthStore.execute(stepObserverQuery!)

        // 距離更新の ObserverQuery
        distanceObserverQuery = HKObserverQuery(
            sampleType: distanceType,
            predicate: nil
        ) { [weak self] _, completionHandler, error in
            self?.fetchTodayWalkingDistance { _, _ in }
            completionHandler()
        }
        
        healthStore.execute(distanceObserverQuery!)
        
    }
}

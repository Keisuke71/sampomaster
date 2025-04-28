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

    /// HealthKitの使用許可をリクエスト
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable(),
              let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)
        else {
            completion(false, nil)
            return
        }
        healthStore.requestAuthorization(toShare: [], read: [stepType], completion: completion)
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
}

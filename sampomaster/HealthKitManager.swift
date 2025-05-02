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
              let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount),
              let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
        else {
            completion(false, nil)
            return
        }
        healthStore.requestAuthorization(toShare: [], read: [stepType, distanceType], completion: completion)
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
}

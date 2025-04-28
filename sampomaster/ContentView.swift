//
//  ContentView.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/04/26.
//

import SwiftUI
import HealthKit

let healthStore = HKHealthStore()

struct ContentView: View {
    let healthStore = HKHealthStore()  // HealthKitを使うためのオブジェクト

    var body: some View {
        VStack(spacing: 20) {
            Text("サンポマスターアプリ")
                .font(.title)
                .padding()

            Button(action: {
                requestAuthorization()
            }) {
                Text("HealthKitの許可をリクエスト")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            Button("今日の歩数を取得") {
                    fetchTodayStepCount()
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
        }
    }

    func requestAuthorization() {
        // 読み取るデータの型（歩数）
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            print("歩数の型を作成できませんでした")
            return
        }
        
        // 読み取りのリクエスト（書き込みなし）
        healthStore.requestAuthorization(toShare: [], read: [stepType]) { success, error in
            if success {
                print("HealthKitの許可に成功しました")
            } else {
                print("HealthKitの許可に失敗しました: \(String(describing: error))")
            }
        }
    }
    
    func fetchTodayStepCount() {
            guard HKHealthStore.isHealthDataAvailable(),
                  let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)
            else {
                print("⚠️ HealthKit非対応デバイス、または歩数型が取得できません")
                return
            }

            // 今日の0時から現在まで
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
                    let count = sum.doubleValue(for: .count())
                    print("今日の歩数合計：\(Int(count))歩")
                } else {
                    print("歩数取得エラー: \(String(describing: error))")
                }
            }

            healthStore.execute(query)
        }

#Preview {
    ContentView()
}

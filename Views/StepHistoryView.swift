//
//  StepHistoryView.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/06/25.
//

import SwiftUI
import HealthKit

// MARK: - Data Model
struct DailyStepRecord: Identifiable {
    let id = UUID()
    let date: Date
    let steps: Int
}

// MARK: - ViewModel
/// 過去歩数履歴を取得する ViewModel
class StepHistoryViewModel: ObservableObject {
    static let shared = StepHistoryViewModel()
    
    @Published var dailySteps: [DailyStepRecord] = []
    private let healthStore = HKHealthStore()

    /// 指定日の歩数を取得
    private func fetchSteps(on date: Date, completion: @escaping (Int) -> Void) {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }
        let predicate = HKQuery.predicateForSamples(
            withStart: start,
            end: end,
            options: .strictStartDate
        )
        let query = HKStatisticsQuery(
            quantityType: type,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            let count = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
            completion(Int(count))
        }
        healthStore.execute(query)
    }

    /// 過去 N 日分の歩数履歴をロード
    func loadHistory(days: Int = 7) {
        let calendar = Calendar.current
        var records: [DailyStepRecord] = []
        for offset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else { continue }
            fetchSteps(on: date) { count in
                DispatchQueue.main.async {
                    let record = DailyStepRecord(date: date, steps: count)
                    records.append(record)
                    records.sort { $0.date > $1.date }
                    self.dailySteps = records
                }
            }
        }
    }
}

// MARK: - View
/// 過去の歩数履歴をリスト表示する View
struct StepHistoryView: View {
    @State private var selectedDays: Int = 7  // ユーザーが選択する日数
    @StateObject private var viewModel = StepHistoryViewModel()
    private let dayOptions = [7, 14, 30]
    
    //グラフ関連
    private var records: [DailyStepRecord] { viewModel.dailySteps }

    /// リストに表示されている歩数の合計
    private var totalSteps: Int {
        viewModel.dailySteps.reduce(0) { $0 + $1.steps }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // プルダウンリスト（メニューピッカー）
                Picker("期間", selection: $selectedDays) {
                    ForEach(dayOptions, id: \ .self) { day in
                        Text("過去\(day)日")
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                //グラフの表示
                StepHistoryChartView(records: records)

                // 合計歩数の表示
                Text("合計：\(totalSteps)歩")
                    .font(.headline)
                    .padding(.bottom, 4)

                List(viewModel.dailySteps) { record in
                    HStack {
                        Text(record.date, style: .date)
                        Spacer()
                        Text("\(record.steps)歩")
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("歩数履歴")
            .onAppear {
                viewModel.loadHistory(days: selectedDays)
            }
            .onChange(of: selectedDays) { newValue in
                viewModel.loadHistory(days: newValue)
            }
        }
    }
}

struct StepHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        StepHistoryView()
    }
}

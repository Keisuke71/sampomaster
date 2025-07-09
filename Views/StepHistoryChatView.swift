//
//  StepHistoryChatView.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/06/27.
//
import SwiftUI
import Charts

/// 日付ごとの歩数を棒グラフで表示する View
struct StepHistoryChartView: View {
    let records: [DailyStepRecord]

    var body: some View {
        Chart(records) { record in
            BarMark(
                x: .value("日付", record.date, unit: .day),
                y: .value("歩数", record.steps)
            )
            .foregroundStyle(Color.blue.gradient)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: max(1, records.count / 5))) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .frame(height: 200)
        .padding()
    }
}

struct StepHistoryChartView_Previews: PreviewProvider {
    static var previews: some View {
        // サンプルデータ（過去7日分のランダム歩数）
        let sample: [DailyStepRecord] = (0..<7).map {
            DailyStepRecord(date: Calendar.current.date(byAdding: .day, value: -$0, to: .now)!,
                            steps: Int.random(in: 2000...12000))
        }.sorted { $0.date < $1.date }
        StepHistoryChartView(records: sample)
    }
}

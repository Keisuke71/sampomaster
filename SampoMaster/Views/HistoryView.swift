//
//  HistoryView.swift
//  SampoMaster
//
//  Created by 松本 圭祐 on 2025/12/22.
//

import SwiftUI
import Charts

struct HistoryView: View {
    @ObservedObject var healthManager: HealthKitManager
    @State private var selectedRange = 7 // 7日間 or 30日間
    @State private var activities: [DailyActivity] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                // 期間切り替えピッカー
                Picker("期間", selection: $selectedRange) {
                    Text("1週間").tag(7)
                    Text("1ヶ月").tag(30)
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: selectedRange) { _ in
                    loadData()
                }
                
                // グラフエリア
                Chart(activities) { activity in
                    BarMark(
                        x: .value("日付", activity.date, unit: .day),
                        y: .value("歩数", activity.steps)
                    )
                    .foregroundStyle(Color.green.gradient)
                }
                .frame(height: 200)
                .padding()
                
                // 詳細数値表
                List {
                    Section(header: Text("詳細記録")) {
                        ForEach(activities) { activity in
                            HStack {
                                Text(activity.date, format: .dateTime.month().day().weekday())
                                    .font(.subheadline)
                                    .frame(width: 80, alignment: .leading)
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("\(Int(activity.steps)) 歩")
                                        .bold()
                                    Text(String(format: "%.1f km / %.0f kcal", activity.distance / 1000, activity.calories))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("運動履歴")
            .onAppear {
                loadData()
            }
        }
    }
    
    private func loadData() {
        healthManager.fetchHistory(days: selectedRange) { fetchedData in
            self.activities = fetchedData
        }
    }
}

//
//  StatsTabView.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/07/05.
//

import SwiftUI

/// 表示カテゴリー
enum StatsCategory: String, CaseIterable, Identifiable {
    case history      = "履歴"
    case allStats     = "全ての統計"
    var id: Self { self }
}



@MainActor
struct StatsTabView: View {
    /// カテゴリ選択
    @State private var category: StatsCategory = .history
    /// 履歴表示日数
    @State private var days: Int = 7
    /// ビューモデル
    @StateObject private var historyVM = StepHistoryViewModel()

    /// 累計歩数（初回起動から現在まで）
    private var totalSteps: Int {
        TotalDataManager.shared.totalSteps
    }
    /// 累計距離（初回起動から現在まで）
    private var totalDistance: Double {
        TotalDataManager.shared.totalDistance
    }

    var body: some View {
        VStack(spacing: 16) {
            // カテゴリ切替セグメント
            Picker("統計内容", selection: $category) {
                ForEach(StatsCategory.allCases) { cat in
                    Text(cat.rawValue).tag(cat)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            // 選択に応じたコンテンツ
            switch category {
            case .history:
                // 履歴期間セグメント
                Picker("期間", selection: $days) {
                    Text("7日").tag(7)
                    Text("14日").tag(14)
                    Text("30日").tag(30)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                // 履歴グラフ: ビューモデルから取得したレコードを渡す
                StepHistoryChartView(records: historyVM.dailySteps)
                    .padding()

            case .allStats:
                // 全ての統計をまとめて表示
                GroupBox("全ての統計") {
                    VStack(spacing: 12) {
                        HStack {
                            Text("総歩数:")
                            Spacer()
                            Text("\(totalSteps) 歩")
                                .bold()
                        }
                        HStack {
                            Text("総距離:")
                            Spacer()
                            Text(String(format: "%.2f km", totalDistance / 1000))
                                .bold()
                        }
                    }
                    .font(.headline)
                    .padding()
                }
                .padding(.horizontal)
            }
            Spacer()
        }
        .onAppear {
            // ビューモデルで履歴データを取得
            historyVM.loadHistory(days: days)
            TotalDataManager.shared.fetchTotalSteps()
            TotalDataManager.shared.fetchTotalDistance()
        }
        .onChange(of: days) { newDays in
            historyVM.loadHistory(days: newDays)
            TotalDataManager.shared.fetchTotalSteps()
            TotalDataManager.shared.fetchTotalDistance()
        }
    }
}

struct StatsTabView_Previews: PreviewProvider {
    static var previews: some View {
        StatsTabView()
    }
}


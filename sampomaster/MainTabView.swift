//
//  MainTabView.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/07/01.
//

import SwiftUI

struct MainTabView: View {
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject private var rankManager = RankManager.shared
    @StateObject private var viewModel = StepCountViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            //ランク表示部分
            VStack(spacing: 8){
                Text("ランク: \(rankManager.currentRank)")
                    .font(.title2.bold())
                
                // 進捗バー
                ProgressView(value: rankManager.progress) {
                    Text("次のランクまで")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } currentValueLabel: {
                    Text("\(rankManager.stepsRemainingForNextRank) 歩")
                        .font(.caption)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground).shadow(radius: 2))

            
            //タブビュー部分
            TabView {
                ContentView()
                    .tabItem {
                        Label("ホーム", systemImage: "house")
                    }
                StatsTabView()
                    .tabItem{
                        Label("統計", systemImage: "chart.bar.xaxis")
                    }
                SettingsView()
                    .tabItem {
                        Label("その他", systemImage: "gearshape.2")
                    }
            }
        }
        .onAppear {
            viewModel.fetchTodayStepCount()
        }
        .onChange(of: scenePhase) { old, new in
            if new == .active {
                //フォアグラウンドに戻ってきたら最新データをとる
                StepCountViewModel.shared.fetchTodayStepCount()
                StepCountViewModel.shared.fetchTodayWalkingDistance()
            }
        }
        .refreshable{
            viewModel.fetchTodayStepCount()
            viewModel.fetchTodayWalkingDistance()
            viewModel.fetchLatestWeight()
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}

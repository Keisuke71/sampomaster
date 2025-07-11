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
            //ヘッダを表示
            HeaderTabView()
            
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
                TrainingRecordView()
                    .tabItem {
                        Image(systemName: "figure.strengthtraining.traditional")
                        Text("筋トレ")
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

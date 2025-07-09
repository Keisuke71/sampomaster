// NOTE: Make sure to add "main.jpg" to your asset catalog (Assets.xcassets) as "main" or include it in Copy Bundle Resources.
//
//  ContentView.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/04/26.
//

import SwiftUI
import UIKit

@MainActor
struct ContentView: View {
    
    // 設定画面で変更したユーザー名を取得
        @AppStorage("username") private var username: String = "サンポビギナー"
        // 時間帯に応じたあいさつ文
        private var greeting: String {
            let hour = Calendar.current.component(.hour, from: Date())
            switch hour {
            case 4..<12:
                return "おはようございます"
            case 12..<18:
                return "こんにちは"
            default:
                return "こんばんは"
            }
        }
    
    
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = StepCountViewModel()
    @State private var isShowingCompose = false
    @State private var isEditingGoal = false

    var body: some View {
        ZStack {
            // タイトル画面と同じ背景を敷く
            SplashBackgroundView()
                .ignoresSafeArea()
            
            ScrollView{
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(username)さん")
                            .font(.title2.bold())   // 文字を少し小さく
                        Text(greeting)
                            .font(.title3)           // 挨拶も控えめサイズに
                    }
                    .padding()
                    WeatherView()
                    GroupBox("今日の記録") {
                        VStack(spacing: 16) {
                            // 1行目：歩数と距離
                            HStack(spacing: 24) {
                                VStack {
                                    Image(systemName: "figure.walk")
                                    Text("\(viewModel.stepCount) 歩")
                                }
                                VStack {
                                    Image(systemName: "map")
                                    Text(String(format: "%.2f km", viewModel.distance / 1000))
                                }
                            }
                            // 2行目：体重と消費カロリー
                            HStack(spacing: 24) {
                                VStack {
                                    Image(systemName: "scalemass")
                                    if let w = viewModel.weight {
                                        Text(String(format: "%.1f kg", w))
                                    } else {
                                        Text("-- kg")
                                    }
                                }
                                VStack {
                                    Image(systemName: "flame")
                                    Text("\(viewModel.calories) kcal")
                                }
                            }
                            
                            //Xで投稿する部分
                            HStack(spacing: 24){
                                Button(action: {
                                    isShowingCompose = true
                                }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: "square.and.arrow.up.fill")
                                            .font(.title)
                                        Text("投稿")
                                            .font(.subheadline.bold())
                                    }
                                    .padding(8)
                                    .frame(width: 80, height: 80)
                                    .background(Color.accentColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)
                    }
                    .padding()
                    
                    
                    // 目標のリングを表示
                    GoalProgressView(goal: $viewModel.goal)
                        .padding()
                }
            }
            .background(
                // タイトル画面と同じ背景ビューをそのまま使う
                SplashBackgroundView()
                    .ignoresSafeArea()
            )
            // VStack 終了
            .padding()
            .onAppear {
                // 画面が現れたタイミングで自動取得
                HealthKitManager.shared.requestAuthorization{success, _ in
                    if success {
                        TotalDataManager.shared.fetchTotalSteps()
                        TotalDataManager.shared.fetchTotalDistance()
                    }
                }
                viewModel.requestAuthorization()
                viewModel.fetchTodayStepCount()
                viewModel.fetchTodayWalkingDistance()
                viewModel.fetchLatestWeight()
                
            }
            //画面遷移時（ホーム画面等から戻ってきた時）に更新
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    TotalDataManager.shared.fetchTotalSteps()
                    TotalDataManager.shared.fetchTotalDistance()
                    viewModel.fetchTodayStepCount()
                    viewModel.fetchTodayWalkingDistance()
                    viewModel.fetchLatestWeight()
                }
            }
            .refreshable {
                // プル後の更新処理
                TotalDataManager.shared.fetchTotalSteps()
                TotalDataManager.shared.fetchTotalDistance()
                viewModel.fetchTodayStepCount()
                viewModel.fetchTodayWalkingDistance()
                viewModel.fetchLatestWeight()
            }
            .sheet(isPresented: $isShowingCompose) {
                TwitterComposer(text: TweetPhraseSelector.message(for: viewModel.stepCount, distance: viewModel.distance / 1000),
                                image: UIImage(named: "main"))
            }
            .sheet(isPresented: $isEditingGoal) {
                GoalEditorView(isPresented: $isEditingGoal,
                               goal: $viewModel.goal)
            }
        }
    }
}

#Preview {
    ContentView()
}

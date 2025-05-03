// NOTE: Make sure to add "main.jpg" to your asset catalog (Assets.xcassets) as "main" or include it in Copy Bundle Resources.
//
//  ContentView.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/04/26.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var viewModel = StepCountViewModel()
    @State private var isShowingCompose = false
    @State private var isEditingGoal = false

    var body: some View {
        VStack(spacing: 20) {
            Text("サンポマスターアプリ")
                .font(.largeTitle.bold())
                .padding()
            
            Button("今日の歩数を取得") {
                viewModel.fetchTodayStepCount()
                viewModel.fetchTodayWalkingDistance()
            }
            .buttonStyle(PrimaryButtonStyle(color: .green))

            Text("📊 今日の歩数合計：\(viewModel.stepCount)歩")
                .font(.headline)
                .padding()
            //歩行距離表示
            Text(String(
                format:"🚶‍♂️ 今日の歩行距離: %.2f km",
                viewModel.distance / 1000
            ))
            .font(.subheadline)
            .foregroundStyle(.gray)
            
            //X投稿部分
            Button("X で画像付き投稿") {
                let msg = TweetPhraseSelector.message(for: viewModel.stepCount, distance: viewModel.distance / 1000)
                // main.jpg をバンドルからロード
                _ = UIImage(named: "main")
                isShowingCompose = true
            }
            .buttonStyle(PrimaryButtonStyle(color: .orange))

            // 目標のリングを表示
            RingView(current: viewModel.stepCount, goal: viewModel.goal)
            .padding()
            .onTapGesture {
                isEditingGoal = true
            }
        }
        // VStack 終了
        .padding()
        .onAppear {
            // 画面が現れたタイミングで自動取得
            viewModel.requestAuthorization()
            viewModel.fetchTodayStepCount()
            viewModel.fetchTodayWalkingDistance()
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

#Preview {
    ContentView()
}
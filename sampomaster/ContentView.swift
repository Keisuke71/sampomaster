// NOTE: Make sure to add "main.jpg" to your asset catalog (Assets.xcassets) as "main" or include it in Copy Bundle Resources.
//
//  ContentView.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/04/26.
//

import SwiftUI
import UIKit
import Social

struct ContentView: View {
    @StateObject private var viewModel = StepCountViewModel()
    @State private var isShowingCompose = false

    var body: some View {
        VStack(spacing: 20) {
            Text("サンポマスターアプリ")
                .font(.largeTitle.bold())
                .padding()

            Button("HealthKitの許可をリクエスト") {
                viewModel.requestAuthorization()
            }
            .buttonStyle(PrimaryButtonStyle(color: .blue))
            
            Button("今日の歩数を取得") {
                viewModel.fetchTodayStepCount()
            }
            .buttonStyle(PrimaryButtonStyle(color: .green))

            Text("📊 今日の歩数合計：\(viewModel.stepCount)歩")
                .font(.headline)
                .padding()
            
            //X投稿部分
            Button("X で画像付き投稿") {
                // 取得した歩数メッセージ
                let msg = TweetPhraseSelector.message(for: viewModel.stepCount)
                // main.jpg をバンドルからロード
                let img = UIImage(named: "main")
                isShowingCompose = true
            }
            .sheet(isPresented: $isShowingCompose) {
                TwitterComposer(text: TweetPhraseSelector.message(for: viewModel.stepCount),
                                   image: UIImage(named: "main"))
            }
            .buttonStyle(PrimaryButtonStyle(color: .orange))
        }
        RingView(current: viewModel.stepCount, goal: 10000)
        
        //アプリ起動時に歩数を自動取得
            .padding()
            .onAppear(){
                //画面が現れたタイミングで自動取得
                viewModel.fetchTodayStepCount()
            }
    }
        
}

#Preview {
    ContentView()
}
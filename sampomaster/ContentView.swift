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
                .font(.title)
                .padding()

            Button("HealthKitの許可をリクエスト") {
                viewModel.requestAuthorization()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            Button("今日の歩数を取得") {
                viewModel.fetchTodayStepCount()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)

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
        }
        RingView(current: viewModel.stepCount, goal: 10000)
    }
}

#Preview {
    ContentView()
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

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

            Button("Xで投稿") {
                let text = TweetPhraseSelector.message(for: viewModel.stepCount)
                TwitterComposer.openComposer(with: text)
            }
            .padding()
            .background(viewModel.stepCount > 0 ? Color.orange : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(viewModel.stepCount == 0)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

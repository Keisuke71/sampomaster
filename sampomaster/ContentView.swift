//
//  ContentView.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/04/26.
//

import SwiftUI

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
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

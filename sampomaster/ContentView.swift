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
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
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

            Button("Xで投稿（写真付き共有）") {
                let text = TweetPhraseSelector.message(for: viewModel.stepCount)
                // Attempt to load the image from the app bundle
                if let image = UIImage(named: "main") {
                    shareItems = [text, image]
                } else {
                    shareItems = [text]
                }
                showingShareSheet = true
            }
            .padding()
            .background(viewModel.stepCount > 0 ? Color.orange : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(viewModel.stepCount == 0)
        }
        .padding()
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: shareItems)
        }
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

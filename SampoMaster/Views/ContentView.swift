import SwiftUI
import Charts // HistoryViewが同じファイルにない場合はimport不要ですが、念のため

struct ContentView: View {
    // アプリ全体で使うデータマネージャーをここで1つだけ作る
    @StateObject private var healthManager = HealthKitManager()
    
    var body: some View {
        TabView {
            // --- 1つ目のタブ: 今日の記録 ---
            HomeView(healthManager: healthManager)
                .tabItem {
                    Label("ホーム", systemImage: "figure.walk")
                }
            
            // --- 2つ目のタブ: 履歴グラフ ---
            HistoryView(healthManager: healthManager)
                .tabItem {
                    Label("履歴", systemImage: "chart.bar")
                }
        }
        .accentColor(.green) // 選択中のアイコンの色
        .onAppear {
            // アプリ起動時に権限リクエスト
            healthManager.requestAuthorization()
        }
    }
}

// ▼ これまで ContentView に書いていた内容を「HomeView」として定義
struct HomeView: View {
    @ObservedObject var healthManager: HealthKitManager
    
    var body: some View {
        ScrollView { // 画面からはみ出ても大丈夫なようにスクロール追加
            VStack(spacing: 30) {
                Spacer().frame(height: 20)
                
                // 歩数
                VStack {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                    Text("今日の歩数")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(Int(healthManager.stepCount)) 歩")
                        .font(.system(size: 40, weight: .bold))
                }
                
                Divider()
                
                // 距離
                VStack {
                    Image(systemName: "map")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    Text("歩行距離")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(String(format: "%.2f km", healthManager.walkingDistance / 1000))
                        .font(.system(size: 40, weight: .bold))
                }
                
                Divider()
                
                // カロリー
                VStack {
                    Image(systemName: "flame")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    Text("消費カロリー")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(String(format: "%.0f kcal", healthManager.calories))
                        .font(.system(size: 40, weight: .bold))
                }
                
                Spacer().frame(height: 20)
                
                Button("データ更新") {
                    healthManager.fetchAllData()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}

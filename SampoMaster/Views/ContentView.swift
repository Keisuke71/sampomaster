import SwiftUI

struct ContentView: View {
    // アプリ全体で共有するヘルスケアマネージャー
    @StateObject private var healthManager = HealthKitManager()
    
    var body: some View {
        TabView {
            // HomeViewを呼び出すだけ！
            HomeView(healthManager: healthManager)
                .tabItem {
                    Label("ホーム", systemImage: "figure.walk")
                }
            
            // 履歴画面
            HistoryView(healthManager: healthManager)
                .tabItem {
                    Label("履歴", systemImage: "chart.bar")
                }
        }
        .accentColor(.green)
        .onAppear {
            healthManager.requestAuthorization()
        }
    }
}

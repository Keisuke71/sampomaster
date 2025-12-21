import SwiftUI

struct ContentView: View {
    @StateObject private var healthManager = HealthKitManager()
    
    var body: some View {
        VStack(spacing: 30) {
            
            // 歩数エリア
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
            
            Divider() // 仕切り線
            
            // 距離エリア
            VStack {
                Image(systemName: "map")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                Text("歩行距離")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // メートルをkmに変換し、小数点第2位まで表示 (例: 1.25 km)
                Text(String(format: "%.2f km", healthManager.walkingDistance / 1000))
                    .font(.system(size: 40, weight: .bold))
            }
            
            // カロリー表示エリア
            VStack {
                Image(systemName: "flame")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                Text("消費カロリー")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(String(format: "%.0f kcal", healthManager.calories)) //小数点は切り捨てて表示
                    .font(.system(size: 40, weight: .bold))
            }
            
            Spacer().frame(height: 20)
            
            Button("データ更新") {
                healthManager.fetchAllData()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .onAppear {
            healthManager.requestAuthorization()
            healthManager.fetchAllData()
        }
    }
}

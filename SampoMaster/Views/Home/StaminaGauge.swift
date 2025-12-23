import SwiftUI

struct StaminaGauge: View {
    var current: Double
    var max: Double
    
    var body: some View {
        VStack(spacing: 4) {
            // ラベルと数値
            HStack {
                Label("STAMINA", systemImage: "bolt.fill")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                
                Spacer()
                
                Text("\(Int(current)) / \(Int(max))")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .monospacedDigit() // 数字の幅を等幅にする
            }
            .padding(.horizontal, 2)
            
            // ゲージ本体
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景（空のゲージ）
                    Capsule()
                        .frame(width: geometry.size.width, height: 12)
                        .foregroundColor(Color.black.opacity(0.5))
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    
                    // 中身（現在のスタミナ）
                    let percent = min(current / max, 1.0)
                    Capsule()
                        .frame(width: geometry.size.width * percent, height: 12)
                        .foregroundColor(percent > 0.2 ? .green : .red) // ピンチになると赤くなる
                        .shadow(color: .green.opacity(0.5), radius: 4, x: 0, y: 0)
                }
            }
            .frame(height: 12)
        }
        .padding(8)
        .background(.ultraThinMaterial) // すりガラスのような背景
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

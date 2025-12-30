import SwiftUI

struct SplashView: View {
    // 親(ContentView)に「タップされたよ！」と伝えるための関数
    var onStart: () -> Void
    
    // 点滅アニメーション用の状態管理
    @State private var isBlinking = false
    
    var body: some View {
        ZStack {
            // 1. 背景画像
            Image("titlebg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // 2. コンテンツ (ロゴや文字)
            VStack {
                // タイトルロゴ (上部)
                Image("titlelogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 280)
                    .padding(.top, 80)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Spacer()
                
                // 点滅する TAP TO START
                Text("TAP TO START")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.3))
                            .blur(radius: 5)
                    )
                    .opacity(isBlinking ? 1.0 : 0.3)
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                            isBlinking = true
                        }
                    }
                    .padding(.bottom, 60)
                
                // コピーライト (下部)
                VStack(spacing: 4) {
                    Text("Project ASTER: S-TPIA Defense Protocol")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("©️2025 Project Sampomaster")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 40)
            }
        }
        // ZStack全体に対してタップ判定をつける
        .contentShape(Rectangle()) // 画面の隅々までタップ判定を持たせるおまじない
        .onTapGesture {
            startAction()
        }
    }
    
    private func startAction() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        onStart()
    }
}

#Preview {
    SplashView(onStart: {})
}

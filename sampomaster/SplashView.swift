import SwiftUI

struct SplashView: View {
    @State private var isActive = false

    var body: some View {
        ZStack {
            // 背景画像
            Image("titlebg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // ロゴとコピーライトを縦並び
            VStack {
                Spacer()   // 上部に余白

                // ロゴ（ここでサイズを大きく調整）
                Image("titlelogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300) // ←幅300×高さ300に拡大

                Spacer()   // ロゴとコピーライトの間に余白

                // コピーライト
                Text("©️ 2025 Project Sampomaster")
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .padding(.bottom, 24)  // 下端からの余白

            }
            .ignoresSafeArea(edges: .bottom)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeOut) {
                    isActive = true
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            MainTabView()
        }
    }
}

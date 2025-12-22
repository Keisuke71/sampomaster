import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            // 1. 背景画像
            Image("titlebg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                // 2. タイトルロゴ (上部)
                Image("titlelogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250)
                    .padding(.top, 50)
                
                Spacer()
                
                // 3. コピーライト (下部)
                Text("©️2025 Project Sampomaster")
                    .font(.caption)
                    .foregroundColor(.black) // 指定の黒文字
                    .padding(.bottom, 30)
            }
        }
    }
}

//
//  SplashView.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/07/04.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            SplashBackgroundView()     // 新しく作成した背景ビュー
            VStack(spacing: 16) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                Text("サンポマスターApp")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
            }
        }
        .ignoresSafeArea()
    }
}

//
//  SplashBackgroundView.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/07/04.
//

import SwiftUI

/// サンポマスターアプリの起動画面用背景ビュー
struct SplashBackgroundView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1. 空をイメージしたグラデーション（上：朝焼け、下：昼間の青空）
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 1.0, green: 0.75, blue: 0.5),  // 朝焼けオレンジ
                        Color(red: 0.4, green: 0.8, blue: 1.0)    // 青空ブルー
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // 2. さりげない足跡パターンをオーバーレイ
                FootprintPattern()
                    .opacity(0.2)
                    .frame(width: geo.size.width, height: geo.size.height)

                // 3. 中央にロゴとアプリ名（スプラッシュで使う場合は別ビューで追加）
                //   ここでは背景のみを担当
            }
        }
    }
}

/// 背景に表示する足跡パターンを描画するカスタムシェイプ
struct FootprintPattern: View {
    var body: some View {
        Canvas { context, size in
            let step = size.width / 10
            let footprint = Path { path in
                // シンプルな足跡形状
                path.addEllipse(in: CGRect(x: -step/4, y: -step/8, width: step/2, height: step/3))
                path.addEllipse(in: CGRect(x: -step/8, y: -step/2, width: step/4, height: step/3))
            }
            for x in stride(from: 0.0, to: size.width, by: step * 2) {
                for y in stride(from: 0.0, to: size.height, by: step * 2) {
                    context.withCGContext { ctx in
                        // 45度回転
                        ctx.translateBy(x: x + step, y: y + step)
                        ctx.rotate(by: .pi/4)
                        ctx.setFillColor(UIColor.white.cgColor)
                        ctx.addPath(footprint.cgPath)
                        ctx.fillPath()
                    }
                }
            }
        }
    }
}

struct SplashBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        SplashBackgroundView()
    }
}

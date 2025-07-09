//
//  RingView.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/04/30.
//

import SwiftUI

/// 現在歩数と目標歩数から進捗リングを描画する View
struct RingView: View {
    let current: Int
    let goal: Int

    // 0.0〜1.0 の進捗率
    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(Double(current) / Double(goal), 1.0)
    }

    var body: some View {
        VStack {
            ZStack {
                // 背景リング
                Circle()
                    .stroke(lineWidth: 20)
                    .opacity(0.2)
                    .foregroundColor(.blue)

                // 進捗リング
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .foregroundColor(.blue)
                    .animation(.easeOut, value: progress)

                // 中央のパーセント表示
                Text("\(Int(progress * 100))%")
                    .font(.title)
                    .bold()
            }
            .frame(width: 150, height: 150)

            // 目標歩数の表示
            Text("目標：\(goal)歩")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 8)
        }
    }
}

struct RingView_Previews: PreviewProvider {
    static var previews: some View {
        RingView(current: 7500, goal: 10000)
    }
}

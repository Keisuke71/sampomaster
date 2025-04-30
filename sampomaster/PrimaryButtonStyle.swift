//
//  PrimaryButtonStyle.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/04/30.
//

import SwiftUI

//汎用ボタンスタイル
//ボタンを作成するときはここから呼び出し

struct PrimaryButtonStyle: ButtonStyle {
    var color: Color = .orange
    func makeBody(configuration: Configuration) -> some View{
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .fixedSize(horizontal: true, vertical: false)
            .background(configuration.isPressed ? color.opacity(0.7) : color)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

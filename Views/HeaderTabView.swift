//
//  HeaderTabView.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/07/09.
//

import SwiftUI

/// アプリ共通ヘッダー：ランク表示とゲーム内通貨を表示
struct HeaderTabView: View {
    @StateObject private var rankManager    = RankManager.shared
    @StateObject private var currencyVM     = CurrencyViewModel.shared

    var body: some View {
        HStack(alignment: .center, spacing: 24) {
            // ランク表示
            VStack(spacing: 8) {
                HStack(spacing: 4){
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("ランク \(rankManager.currentRank)")
                        .font(.headline)
                }

                ProgressView(value: rankManager.progress) {
                    Text("次のランクまで")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } currentValueLabel: {
                    Text("\(rankManager.stepsRemainingForNextRank) 歩")
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            
            // 通貨表示
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Image("Cur_Crystal")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("\(currencyVM.crystals)")
                        .font(.subheadline).bold()
                }
                HStack(spacing: 4) {
                    Image("Cur_Silver")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("\(currencyVM.silver)")
                        .font(.subheadline).bold()
                }
            }
            .frame(maxWidth: .infinity,alignment: .leading)  // 幅を均等に
            .padding()
            
            //トースト
            if currencyVM.showCrystalToast {
                            HStack(spacing: 8) {
                                Image("Cur_Crystal")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("⚪️ \(currencyVM.lastAwardedAmount) 入手しました！")
                                    .font(.subheadline).bold()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .shadow(radius: 4)
                            .padding(.top, 80) // ヘッダーの少し下
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
        }
        .background(Color(UIColor.systemBackground).shadow(radius: 2))
    }
}

struct HeaderTabView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderTabView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

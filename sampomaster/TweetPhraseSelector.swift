//
//  TweetPhraseSelector.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/04/30.
//


import Foundation

struct TweetPhraseSelector {
    static func message(for steps: Int, distance: Double) -> String {
        let distKm = String(format: "%.2f", distance)
        switch steps {
        case ..<5000:
            return "さぼったサンポマスター\n\n世界はそれを散歩というんだぜ\n\n今日の歩数 \(steps)歩\n距離 \(distKm)km"
        case 5000..<10000:
            return "ちょっとさぼったサンポマスター\n\n世界はそれを散歩というんだぜ\n\n今日の歩数 \(steps)歩\n距離 \(distKm)km"
        case 10000..<15000:
            return "ちょっと頑張ったサンポマスター\n\n普通はそこまでチャリで行くんだぜ\n\n今日の歩数 \(steps)歩\n距離 \(distKm)km"
        case 15000..<20000:
            return "頑張ったサンポマスター\n\n普通はそこまで原付で行くんだぜ\n\n今日の歩数 \(steps)歩\n距離 \(distKm)km"
        case 20000..<25000:
            return "結構頑張ったサンポマスター\n\n散歩するんだどんな時も 俺なら歩くんだどんなとこも\n\n今日の歩数 \(steps)歩\n距離 \(distKm)km"
        case 25000..<30000:
            return "だいぶ頑張ったサンポマスター\n\n散歩するんだどんな時も 俺なら歩くんだどんなとこも\n今世界にひとつだけの 凄い散歩をしたよ\n\n今日の歩数 \(steps)歩\n距離 \(distKm)km"
        case 30000..<999999:
            return "凄まじく歩いたサンポマスター\n\n俺ならできない事だって\nできるんだ本当さ ウソじゃないよ\n今世界に一つだけの 凄い散歩をしたよ\nアイワナビーア 散歩が全て！\n\n今日の歩数 \(steps)歩\n距離 \(distKm)km"
      default:
        return "この歩数にツイート文は設定されていません"
      }
    }
}

//
//  TweetPhraseSelector.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/04/30.
//


import Foundation

struct TweetPhraseSelector {
  static func message(for steps: Int) -> String {
    switch steps {
    case ..<5000:
      return "さぼったサンポマスター\n\n世界はそれを散歩というんだぜ。\n今日の歩数 \(steps)歩"
    case 5000..<10000:
      return "ちょっとさぼったサンポマスター\n\n世界はそれを散歩というんだぜ。\n今日の歩数 \(steps)歩"
    case 10000..<15000:
      return "ちょっと頑張ったサンポマスター\n\n普通はそこまでチャリで行くんだぜ。\n今日の歩数 \(steps)歩"
    default:
      return "さすがサンポマスター！\n今日は\(steps)歩も歩いたんだぜ！"
    }
  }
}

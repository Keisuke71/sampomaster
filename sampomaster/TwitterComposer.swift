//
//  TwitterComposer.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/04/30.
//

import UIKit

/// X（旧Twitter）アプリの投稿コンポーザを直接呼び出すユーティリティ
struct TwitterComposer {
    /// Xアプリの投稿コンポーザを開く
    static func openComposer(with text: String) {
        // URLエンコードしたテキストをクエリに乗せる
        let encoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "twitter://post?message=\(encoded)"
        
        // Xアプリがインストールされていれば直接開く
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            // 見つからない場合はApp StoreのXアプリページへ誘導
            if let appStoreURL = URL(string: "https://apps.apple.com/app/twitter/id333903271") {
                UIApplication.shared.open(appStoreURL)
            }
        }
    }
}

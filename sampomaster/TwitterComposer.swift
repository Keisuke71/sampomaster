//
//  TwitterComposer.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/04/30.
//

import SwiftUI
import Social

// 1. SwiftUI から呼び出すラッパー
struct TwitterComposer: UIViewControllerRepresentable {
    let text: String
    let image: UIImage?

    func makeUIViewController(context: Context) -> SLComposeViewController {
        // サービスタイプは Twitter
        let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)!
        vc.setInitialText(text)
        if let img = image {
            vc.add(img)
        }
        return vc
    }
    func updateUIViewController(_ vc: SLComposeViewController, context: Context) {}
}

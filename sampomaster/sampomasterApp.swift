//
//  sampomasterApp.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/04/26.
//

import SwiftUI

@main
struct sampomasterApp: App {
    init() {
        //通知許可をリクエスト
        NotificationManager.shared.requestAuthrozation()
        //毎日何時にリマインダーを登録するか設定
        NotificationManager.shared.scheduleDailyReminder(hour: 18)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

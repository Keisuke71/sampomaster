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
        @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
        
        //通知許可をリクエスト
        HealthKitManager.shared.requestAuthorization { _, _ in
            //許可後にバックグラウンド更新を有効化
            HealthKitManager.shared.enableStepBackgroundDelivery()
        }
        //毎日何時にリマインダーを登録するか設定
        NotificationManager.shared.scheduleDailyReminder(hour: 18)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

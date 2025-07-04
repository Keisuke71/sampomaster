//
//  sampomasterApp.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/04/26.
//

import SwiftUI

@main
struct sampomasterApp: App {
    
    @State private var showSplash = true
    
    init() {
        @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
        
        
        
        //通知許可をリクエスト
        HealthKitManager.shared.requestAuthorization { _, _ in
            //許可後にバックグラウンド更新を有効化
            HealthKitManager.shared.enableStepBackgroundDelivery()
        }
        //毎日何時にリマインダーを登録するか設定
        NotificationManager.shared.scheduleDailyReminder(hour: 18)
        
        RankManager.shared.startTracking()
        
        /// 最新の今日の歩数を取得
        StepCountViewModel.shared.fetchTodayStepCount()
    }
    
    // MARK: 画面下部のタブ、上部のヘッダを表示
    /// タブのコードはMainTabViewに格納
    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashView()
                } else {
                    MainTabView()
                }
            }
            .onAppear {
                // 2秒後にスプラッシュを閉じる
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
            }
        }
    }
}

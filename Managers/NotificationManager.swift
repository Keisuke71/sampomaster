//
//  NotificationManager.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/05/03.
//
import Foundation
import UserNotifications

//通知の許可を取得
class NotificationManager{
    static let shared = NotificationManager()
    
    private let center = UNUserNotificationCenter.current()
    
    //通知の許可をリクエスト
    func requestAuthrozation(){
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("通知許可エラー: \(error)")
                } else {
                    print("🔔通知許可: \(granted)")
                }
        }
    }
    //毎日指定した時刻にリマインダーをスケジュール
    func scheduleDailyReminder(hour: Int, minute: Int = 0){
        //重複防止のために既存の通知を全て削除
        center.removeAllDeliveredNotifications()
        
        //通知のコンテンツ
        let content = UNMutableNotificationContent()
        content.title = "ツイートリマインダー"
        content.body = "今日の歩数と歩行距離をツイートしましょう！"
        content.sound = UNNotificationSound.default
        
        //毎日指定した時間にトリガー
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        //リクエスト作成
        let request = UNNotificationRequest(
            identifier: "dailyTweetReminder",
            content: content,
            trigger: trigger
        )
        //スケジュール登録
        center.add(request) { error in
            if let error = error {
                print("通知スケジュールエラー: \(error)")
            } else {
                print("🔔 毎日\(hour)時\(minute)分のリマインダーを登録しました")
            }
        }
    }
}

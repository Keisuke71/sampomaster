//
//  AppDelegate.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/05/07.
//

import UIKit
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 1) タスク登録
    BGTaskScheduler.shared.register(
      forTaskWithIdentifier: "com.keisuke71.sampomaster.refresh",
      using: nil
    ) { task in
      self.handleAppRefresh(task: task as! BGAppRefreshTask)
    }

    // 2) 初回スケジュール
    scheduleAppRefresh()
    print("🛠️ didFinishLaunchingWithOptions - scheduled first background refresh")
    return true
  }

  /// 定期バックグラウンド更新をスケジュール
  func scheduleAppRefresh() {
    let request = BGAppRefreshTaskRequest(identifier: "com.keisuke71.sampomaster.refresh")
    print("🛠️ scheduleAppRefresh - scheduling refresh at earliestBeginDate: \(request.earliestBeginDate?.description ?? "nil")")
    // earliestBeginDate を nil にするとシステムに最適化任せ
    request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60) // 1h後以降
    do {
      try BGTaskScheduler.shared.submit(request)
      print("🛠️ BGTaskScheduler.submit succeeded for \(request.identifier)")
    } catch {
      print("⚠️ BGTaskScheduler.submit failed for \(request.identifier): \(error)")
    }
  }

  /// 実際にフェッチ＆次回スケジュールを行うハンドラ
  func handleAppRefresh(task: BGAppRefreshTask) {
    print("🛠️ handleAppRefresh started for task: \(task.identifier)")
    // 1) 次回分を必ずスケジュール
    scheduleAppRefresh()

    // 2) フェッチ処理
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1

    let op = BlockOperation {
      let group = DispatchGroup()
      group.enter(); HealthKitManager.shared.fetchTodayStepCount { _,_ in group.leave() }
      group.enter(); HealthKitManager.shared.fetchTodayWalkingDistance { _,_ in group.leave() }
      group.wait()
    }
    task.expirationHandler = {
      print("⚠️ handleAppRefresh expired, cancelling operations")
      queue.cancelAllOperations()
    }
    op.completionBlock = {
      print("🛠️ handleAppRefresh - fetch operations completed; cancelled: \(op.isCancelled)")
      task.setTaskCompleted(success: !op.isCancelled)
    }
    queue.addOperation(op)
  }
}

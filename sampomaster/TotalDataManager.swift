import Foundation
import HealthKit

/// 累計歩数・距離とリセット管理クラス
@MainActor
final class TotalDataManager: ObservableObject {
    static let shared = TotalDataManager()

    // MARK: - UserDefaults Keys
    private let initialStepKey     = "initialStepFetchDate"
    private let initialDistanceKey = "initialDistanceFetchDate"

    // MARK: - Published
    @Published private(set) var totalSteps: Int = 0
    @Published private(set) var totalDistance: Double = 0

    private let defaults = UserDefaults.standard
    private let health = HealthKitManager.shared

    private init() {
        let now = Date()
        // 初回起動またはリセット時に、起点日時を"過去データを含める"ため日付の先頭に設定
        // 初回起動またはリセット時に、起点日時を1970-01-01に設定（全データ取得）
        if defaults.object(forKey: initialStepKey) == nil {
            defaults.set(0.0, forKey: initialStepKey)
        }
        // 初回起動またはリセット時に、距離起点日時を1970-01-01に設定（全データ取得）
        if defaults.object(forKey: initialDistanceKey) == nil {
            defaults.set(0.0, forKey: initialDistanceKey)
        }
    }

    /// 起点日から現在までの総歩数を一括取得
    func fetchTotalSteps() {
    let start = Date(timeIntervalSince1970: defaults.double(forKey: initialStepKey))
    let end = Date()
    health.fetchTotalSteps(from: start, to: end) { [weak self] value, error in
        Task { @MainActor in
            guard let self = self else { return }
            if let err = error {
                print("❌ fetchTotalSteps error:", err)
            } else {
                self.totalSteps = value
            }
        }
    }
}
    

    /// 起点日から現在までの総距離を一括取得
    func fetchTotalDistance() {
    let start = Date(timeIntervalSince1970: defaults.double(forKey: initialDistanceKey))
    let end = Date()
    health.fetchTotalDistance(from: start, to: end) { [weak self] value, error in
        Task { @MainActor in
            guard let self = self else { return }
            if let err = error {
                print("❌ fetchTotalDistance error:", err)
            } else {
                self.totalDistance = value
            }
        }
    }
}
    

    /// 累計データのリセット：起点を今日の開始時刻に戻す
    func resetAllData() {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        defaults.set(startOfDay.timeIntervalSince1970, forKey: initialStepKey)
        defaults.set(startOfDay.timeIntervalSince1970, forKey: initialDistanceKey)
        DispatchQueue.main.async {
            self.totalSteps = 0
            self.totalDistance = 0
        }
    }
}

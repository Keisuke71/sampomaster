//
//  LocationManager.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/05/14.
//

import Foundation
import CoreLocation

// Significant Location Changeを監視し、更新時にコールバックする
final class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    private let manager = CLLocationManager()
    
    private override init() {
        super.init()
        manager.delegate = self
        // 常時バックグラウンドでの取得を許可
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
    }
    
    //アプリ起動時に呼ぶ
    func startMonitoring() {
        //ユーザーにアクセス許可をリクエスト
        manager.requestAlwaysAuthorization()
        //実際にSignificant Location Changeを開始
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            manager.startMonitoringSignificantLocationChanges()
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        print("📍 Significant Location Update: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
        
        // バックグラウンドでも歩数と距離を取得
        StepCountViewModel.shared.fetchTodayStepCount()
        StepCountViewModel.shared.fetchTodayWalkingDistance()
 
        
   }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("⚠️ Location update failed:", error)
    }
}

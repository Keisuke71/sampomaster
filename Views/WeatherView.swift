//
//  WeatherView.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/07/04.
//

import SwiftUI
import CoreLocation
import Foundation

// MARK: - モデル
struct OWMWeatherResponse: Codable {
    struct Main: Codable {
        let temp: Double       // 摂氏で返る
        let humidity: Int      // % で返る
    }
    let main: Main
}

// MARK: - サービス
actor WeatherAPIService {
    private let apiKey: String
    
    init() {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "OPENWEATHER_API_KEY") as? String,
              !key.isEmpty
        else {
            fatalError("⚠️ API Key missing in Info.plist")
        }
        apiKey = key
    }
    
    func fetchWeather(lat: Double, lon: Double) async throws -> OWMWeatherResponse {
        // ここでは安全に apiKey が使える
        var comps = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")!
        comps.queryItems = [
            .init(name: "lat", value: "\(lat)"),
            .init(name: "lon", value: "\(lon)"),
            .init(name: "appid", value: apiKey),
            .init(name: "units", value: "metric"),
        ]
        let (data, _) = try await URLSession.shared.data(from: comps.url!)
        return try JSONDecoder().decode(OWMWeatherResponse.self, from: data)
    }
}

@MainActor
final class WeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var temperature: Double?
    @Published var humidity: Int?
    @Published var message: String = ""
    
    private let locationManager = CLLocationManager()
    private let api = WeatherAPIService()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        // 許可が出ていればすぐリクエスト
        if locationManager.authorizationStatus == .authorizedWhenInUse ||
           locationManager.authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
    
    @objc func locationManager(_ manager: CLLocationManager,
                               didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else { return }
        manager.stopUpdatingLocation()
        Task {
            do {
                let resp = try await api.fetchWeather(lat: loc.coordinate.latitude,
                                                      lon: loc.coordinate.longitude)
                temperature = resp.main.temp
                humidity    = resp.main.humidity
                // 警告メッセージ
                switch resp.main.temp {
                case let t where t >= 30:
                    message = "熱中症に注意してください"
                case 20..<30:
                    message = "今日は運動日和です"
                default:
                    message = "寒さに注意してください"
                }
            } catch {
                message = "天気情報を取得できませんでした"
            }
        }
    }
    
    @objc func locationManager(_ manager: CLLocationManager,
                               didFailWithError error: Error) {
        message = "位置情報の取得に失敗しました"
    }
}

struct WeatherView: View {
    @StateObject private var vm = WeatherViewModel()
    
    var body: some View {
        GroupBox("今日の天気と注意") {
            VStack(alignment: .leading, spacing: 8) {
                if let t = vm.temperature, let h = vm.humidity {
                    Text("🌡️ \(Int(t))℃   💧 \(h)%")
                        .font(.headline)
                } else {
                    ProgressView()
                }
                Text(vm.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .padding(.horizontal)
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView()
    }
}

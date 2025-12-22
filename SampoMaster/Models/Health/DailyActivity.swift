//
//  DailyActivity.swift
//  SampoMaster
//
//  Created by 松本 圭祐 on 2025/12/22.
//

import Foundation

struct DailyActivity: Identifiable {
    let id = UUID()
    let date: Date
    let steps: Double
    let distance: Double
    let calories: Double
}

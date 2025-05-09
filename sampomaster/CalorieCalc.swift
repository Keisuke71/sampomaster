//
//  CalorieCalc.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/05/09.
//

import Foundation

//消費カロリー計算ユーティリティ
struct CalorieCalc{
    ///体重(kg)と歩行距離(m)から推定消費カロリー(kcal)を計算
    /// - Parameters:
    ///     - distanceMeters: 歩行距離(メートル)
    ///     - weightkKg: 体重(キログラム)
    /// - Returns: 推定消費カロリー
    static func caloriesBurned(distanceMeters: Double, weightKg: Double) -> Double {
        let distanceKm = distanceMeters / 1000
        // 推定消費カロリーは 1kgあたり、1kmで1kcal消費
        return weightKg * distanceKm
    }
    
    /// 体重と歩数から推定消費カロリーを計算
    /// - Parameters:
    ///     - steps: 歩数
    ///     - weightKg: 体重（キログラム）
    ///     - StepsPerMeters: 一歩当たりの距離（デフォルト 0.76m)
    /// - Returns: 推定消費カロリー
    static func caloriesBurned(steps: Int, weightKg: Double, StepsPerMeters: Double = 0.76) -> Double {
        let distance = Double(steps) * StepsPerMeters
        return caloriesBurned(distanceMeters: distance, weightKg: weightKg)
    }
}

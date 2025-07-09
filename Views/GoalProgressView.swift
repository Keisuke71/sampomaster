//
//  GoalProgressView.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/07/04.
//

import SwiftUI

/// 目標歩数に対する進捗バーと設定ボタンを表示する View
@MainActor
struct GoalProgressView: View {
    @Binding var goal: Int
    /// 共有された ViewModel を参照
    @ObservedObject private var viewModel = StepCountViewModel.shared
    @State private var isEditingGoal = false

    /// 進捗率 (0.0 ～ 1.0)
    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(Double(viewModel.stepCount) / Double(goal), 1.0)
    }

    /// 目標までの残り歩数
    private var stepsRemaining: Int {
        max(0, goal - viewModel.stepCount)
    }

    var body: some View {
        GroupBox("目標進捗") {
            VStack(alignment: .leading, spacing: 12) {
                // プログレスバー
                ProgressView(value: progress) {
                    Text("目標: \(goal) 歩")
                        .font(.subheadline)
                } currentValueLabel: {
                    Text(String(format: "%.0f%%", progress * 100))
                        .font(.subheadline.bold())
                }
                .padding(.vertical, 4)

                // 残り歩数表示
                Text("あと \(stepsRemaining) 歩")
                    .font(.caption)
                    .foregroundColor(.secondary)

                // 目標設定ボタン
                HStack {
                    Spacer()
                    Button(action: {
                        isEditingGoal = true
                    }) {
                        Text("目標設定")
                            .font(.subheadline.bold())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(PrimaryButtonStyle(color: .blue))
                }
            }
            .padding(.vertical, 8)
        }
        .sheet(isPresented: $isEditingGoal) {
            GoalEditorView(isPresented: $isEditingGoal,
                           goal: $goal)
        }
        .onAppear {
            // 起動時に最新の歩数を取得して進捗を更新
            viewModel.fetchTodayStepCount()
            viewModel.fetchTodayWalkingDistance()
        }
    }
}

struct GoalProgressView_Previews: PreviewProvider {
    static var previews: some View {
        GoalProgressView(goal: .constant(10000))
    }
}

//
//  GoalEditorView.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/05/01.
//

import SwiftUI

//目標歩数を編集するシート
/// 目標歩数を編集するシート
struct GoalEditorView: View {
    @Binding var isPresented: Bool    // シートの開閉
    @Binding var goal: Int           // ViewModel の goal
    @State private var draftText: String

    init(isPresented: Binding<Bool>, goal: Binding<Int>) {
        self._isPresented = isPresented
        self._goal = goal
        self._draftText = State(initialValue: "\(goal.wrappedValue)")
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("目標歩数を入力")
                    .font(.headline)
                TextField("目標歩数", text: $draftText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationBarTitle("目標設定", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        if let newGoal = Int(draftText), newGoal > 0 {
                            goal = newGoal
                        }
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct GoalEditorView_Previews: PreviewProvider {
    @State static var show = true
    @State static var goal = 10000
    static var previews: some View {
        GoalEditorView(isPresented: $show, goal: $goal)
    }
}

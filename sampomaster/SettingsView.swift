import SwiftUI

/// 設定タブ：ユーザー名変更 & データリセット
struct SettingsView: View {
    @AppStorage("username") private var username = "サンポビギナー"
    @State private var showResetAlert = false
    @State private var isEditingUsername = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("プロフィール")) {
                    HStack {
                        Text("ユーザー名:")
                        Spacer()
                        Text(username)
                            .foregroundColor(.secondary)
                    }
                    Button("ユーザー名の変更") {
                        isEditingUsername = true
                    }
                }
                Section(header: Text("データ管理")) {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Text("データをリセット")
                    }
                }
            }
            .navigationTitle("設定")
        }
        // ユーザー名編集用シート
        .sheet(isPresented: $isEditingUsername) {
            NavigationStack {
                Form {
                    Section(header: Text("新しいユーザー名を入力")) {
                        TextField("ユーザー名", text: $username)
                    }
                }
            }
            .navigationTitle("ユーザー名変更")
            .toolbar(content: {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        isEditingUsername = false
                    }
                }
            })
        }
        // リセット確認アラート
        .alert("リセットの確認", isPresented: $showResetAlert) {
            Button("キャンセル", role: .cancel) {}
            Button("リセット", role: .destructive) {
                TotalDataManager.shared.resetAllData()
            }
        } message: {
            Text("累計歩数と距離をリセットします。")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

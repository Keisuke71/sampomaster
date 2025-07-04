import SwiftUI

/// 設定タブ：ユーザー名変更 & データリセット & 日時表示
struct SettingsView: View {
    @AppStorage("username") private var username = "サンポビギナー"
    @State private var showResetAlert = false
    @State private var isEditingUsername = false

    private let rankMgr = RankManager.shared

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .medium
        return f
    }()

    var body: some View {
        NavigationStack {
            // Form の content: ラベルを外して末尾クロージャ構文にする
            Form {
                // プロフィール
                // headerにはViewを直接渡し、contentは末尾クロージャにする
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

                // データ記録日時表示
                Section(header: Text("データ記録")) {

                    VStack {
                        HStack {
                            Text("初回取得日時:")
                            Spacer()
                            Text(dateFormatter.string(from: rankMgr.initialFetchDate))
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("最終更新日時:")
                            Spacer()
                            Text(dateFormatter.string(from: rankMgr.lastFetchDate))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // データリセット
                Section(header: Text("データ管理")) {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Text("データをリセット")
                    }
                }
            }
            .navigationTitle("設定")
            // ユーザー名編集用シート
            .sheet(isPresented: $isEditingUsername) {
                NavigationStack {
                    Form {
                        Section(header: Text("新しいユーザー名を入力")) {
                            TextField("ユーザー名", text: $username)
                        }
                    }
                    .navigationTitle("ユーザー名変更")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("完了") {
                                isEditingUsername = false
                            }
                        }
                    }
                }
            }
            // リセット確認アラート
            .alert("リセットの確認", isPresented: $showResetAlert) {
                Button("キャンセル", role: .cancel) {}
                Button("リセット", role: .destructive) {
                    rankMgr.resetTracking()
                }
            } message: {
                Text("累計歩数とレベルを初期化します。")
            }
        }
    }
}

// Previewは変更不要
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

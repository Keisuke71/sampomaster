//
//  TrainingFeature.swift
//  sampomaster
//
//  Created by 松本 圭祐 on 2025/07/10.
//

import SwiftUI
import Combine

// MARK: - Model
/// 筋トレメニュー1項目
struct TrainingMenu: Identifiable, Codable, Hashable {
    let id: String
    let type: String
    let parts: String
    let description: String
}

// MARK: - Google Sheets API Response
private struct SheetsResponse: Codable {
    let values: [[String]]
}

// MARK: - Service
/// Googleスプレッドシートからメニューを取得
final class TrainingService {
    static let shared = TrainingService()
    private let apiKey = "GOOGLE_SHEETS_API_KEY"
    private let spreadsheetId = "SPREADSHEET_ID"
    private init() {}

    /// カテゴリに応じたシート名(body-weight, free-weight, machine)からメニューを読み込む
    func fetchMenus(
        category: String,
        completion: @escaping ([TrainingMenu]) -> Void
    ) {
        let sheetName = category
        let range = "A2:D"  // 1行目はヘッダ
        let urlString = "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId)/values/\(sheetName)!(\(range))?key=\(apiKey)"
        guard let url = URL(string: urlString) else { completion([]); return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else { DispatchQueue.main.async { completion([]) }; return }
            do {
                let resp = try JSONDecoder().decode(SheetsResponse.self, from: data)
                let menus = resp.values.compactMap { row -> TrainingMenu? in
                    guard row.count >= 4 else { return nil }
                    return TrainingMenu(
                        id: row[0],
                        type: row[1],
                        parts: row[2],
                        description: row[3]
                    )
                }
                DispatchQueue.main.async { completion(menus) }
            } catch {
                print("[TrainingService] decode error: \(error)")
                DispatchQueue.main.async { completion([]) }
            }
        }.resume()
    }
}

// MARK: - ViewModel
/// 筋トレ記録用 ViewModel
@MainActor
final class TrainingViewModel: ObservableObject {
    static let shared = TrainingViewModel()

    // メニューカテゴリ
    let categories = ["body-weight", "free-weight", "machine"]
    @Published var selectedCategory = "body-weight" {
        didSet { loadMenus() }
    }
    // 選択中メニューリスト
    @Published var menus: [TrainingMenu] = []
    @Published var selectedMenu: TrainingMenu?
    // 入力データ
    @Published var reps: String = ""
    @Published var weight: String = ""

    private init() {
        loadMenus()
    }

    /// 指定カテゴリのメニューを読み込む
    func loadMenus() {
        TrainingService.shared.fetchMenus(category: selectedCategory) { [weak self] list in
            self?.menus = list
            self?.selectedMenu = list.first
        }
    }

    /// 表示中のカテゴリで重量入力が必要か
    var needsWeight: Bool {
        selectedCategory != "body-weight"
    }

    /// 記録保存 (TODO: 実装例)
    func saveRecord() {
        guard let menu = selectedMenu,
              let repsInt = Int(reps) else { return }
        let weightVal = Double(weight) ?? 0.0
        print("Save: \(menu.type), reps=\(repsInt), weight=\(weightVal)")
        // ここでローカルDBやAPI呼び出し等を行う
    }
}

// MARK: - View
struct TrainingRecordView: View {
    @StateObject private var vm = TrainingViewModel.shared

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("メニュー種類")) {
                    Picker("カテゴリ", selection: $vm.selectedCategory) {
                        ForEach(vm.categories, id: \.self) { cat in
                            Text(cat)
                                .tag(cat)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                Section(header: Text("メニュー選択")) {
                    Picker("メニュー", selection: $vm.selectedMenu) {
                        ForEach(vm.menus) { menu in
                            Text(menu.type)
                                .tag(Optional(menu))  // TrainingMenu? 用の Optional タグ
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                Section(header: Text("記録入力")) {
                    TextField("回数", text: $vm.reps)
                        .keyboardType(.numberPad)
                    if vm.needsWeight {
                        TextField("重量(kg)", text: $vm.weight)
                            .keyboardType(.decimalPad)
                    }
                }

                Button("保存") {
                    vm.saveRecord()
                }
            }
            .navigationTitle("筋トレ記録")
        }
    }
}

struct TrainingRecordView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingRecordView()
    }
}

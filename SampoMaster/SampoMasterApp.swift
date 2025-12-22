import SwiftUI
import SwiftData

@main
struct SampoMasterApp: App {
    // データコンテナの定義
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProgress.self, // ここにモデルを追加
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer) // コンテナを注入
    }
}

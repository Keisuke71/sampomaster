import SwiftUI
import SwiftData

@main
struct SampoMasterApp: App {
    // 起動画面の表示フラグ
    @State private var isLoading = true
    
    // SwiftDataの設定
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([UserProgress.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if isLoading {
                // 起動画面を表示
                SplashView()
                    .onAppear {
                        // 5秒後にメイン画面へ切り替え
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                isLoading = false
                            }
                        }
                    }
            } else {
                // メイン画面（ContentView）を表示
                ContentView()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

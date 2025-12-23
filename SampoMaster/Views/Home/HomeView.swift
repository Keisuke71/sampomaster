import SwiftUI
import SwiftData

struct HomeView: View {
    @ObservedObject var healthManager: HealthKitManager
    @StateObject private var levelManager = UserLevelManager()
    
    @State private var gameData = GameDataManager()
    
    // アプリの状態を監視する
    @Environment(\.scenePhase) private var scenePhase
    
    // SwiftDataへのアクセス
    @Environment(\.modelContext) private var modelContext
    @Query private var userProgresses: [UserProgress]
    
    // 計測開始日（デバッグ用）
    @AppStorage("startDate") private var startDateTimestamp: Double = Date().timeIntervalSince1970
    
    @State private var showDebugSheet = false
    
    //画面遷移フラグ
    @State private var showExplorationMap = false
    @State private var showStoryList = false
    
    // キャラのセリフを歩数に応じて決める計算プロパティ
        var characterDialogue: String {
            let steps = Int(healthManager.stepCount)
            switch steps {
            case 0..<100:
                return "おはよう！\nさあ、一緒に歩きに行こう？"
            case 100..<1000:
                return "いい調子！\nその調子で体を温めていこう！"
            case 1000..<5000:
                return "お疲れ様！\n結構歩いたね、えらいえらい！"
            case 5000..<10000:
                return "すごいすごい！\n今日の目標、達成できそうだよ！"
            default:
                return "１万歩達成！？\nあなたは私の自慢のパートナーだよ！"
            }
        }
    
    var body: some View {
            ZStack {
                // --- 背景 ---
                // 画像は画面いっぱいに広げる（タブバーの裏まで描画）
                Image("S-TPIA_2")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                // --- コンテンツ ---
                // コンテンツはセーフエリア内に収める（これでタブバーと被らない）
                VStack(spacing: 0) {
                    
                    // --- ① ヘッダーエリア ---
                    HStack(alignment: .center) {
                        StaminaGauge(current: gameData.stamina, max: gameData.maxStamina)
                            .frame(width: 180)
                        
                        Spacer()
                        
                        Button(action: { showDebugSheet = true }) {
                            Image(systemName: "ladybug.fill")
                                .font(.headline)
                                .padding(8)
                                .background(.black.opacity(0.5))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 40) // ← 余白を増やして、左端に寄りすぎないように調整
                    .padding(.top, 10)       // 上部のバランス調整
                    
                    // --- ② ステータスエリア ---
                    HStack(alignment: .top, spacing: 15) {
                        LevelRingView(
                            level: levelManager.level,
                            progress: levelManager.progress,
                            currentExp: levelManager.currentExp,
                            nextLevelExp: levelManager.nextLevelExp
                        )
                        
                        ActivitySummaryCard(healthManager: healthManager)
                    }
                    .scaleEffect(0.9)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    Spacer() // 中央のスペース確保
                    
                    // --- ③ キャラクター & ボタンエリア ---
                    ZStack(alignment: .bottom) {
                        // キャラクター
                        Image("chara_ayumi_normal")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 380) // サイズ微調整
                            .padding(.bottom, 60)  // ボタンより少し上に配置
                        
                        // 下部アクションボタン
                        HStack(spacing: 20) {
                            Button(action: { showStoryList = true }) {
                                VStack(spacing: 0) {
                                    Image(systemName: "book.fill").font(.subheadline)
                                    Text("STORY").font(.caption2).fontWeight(.bold)
                                }
                                .frame(width: 70, height: 50)
                                .background(.ultraThinMaterial)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            
                            Button(action: { showExplorationMap = true }) {
                                HStack {
                                    Image(systemName: "map.fill")
                                    Text("EXPLORE")
                                        .fontWeight(.bold)
                                        .font(.callout)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.blue.opacity(0.85))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 4)
                            }
                        }
                        .padding(.horizontal, 30)
                        // ↓ 重要: タブバーがある場合、少し底上げしないとタップしにくい
                        .padding(.bottom, 10)
                    }
                }
                // VStack自体には ignoresSafeArea をつけないことで、
                // タブバー領域（画面下部）にはコンテンツが被らないようになる
            }
            .onAppear {
                initializeDataIfNeeded()
                syncData()
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active { syncData() }
            }
            .onReceive(healthManager.$cumulativeSteps) { currentTotalSteps in
                processStepUpdate(currentTotalSteps: currentTotalSteps)
            }
            .sheet(isPresented: $showDebugSheet) {
                DebugView(gameData: gameData)
            }
            // 探索マップ（全画面）
            .fullScreenCover(isPresented: $showExplorationMap) {
                ExplorationView(gameData: gameData)
            }
            // ストーリーリスト（全画面に変更）
            .fullScreenCover(isPresented: $showStoryList) {
                // ここにストーリー画面（StoryListViewなど）を入れる
                // 閉じるボタンが必要になるので注意
            }
        }
    // MARK: - ロジック部分
    
    // データがなければ作成する
    private func initializeDataIfNeeded() {
        if userProgresses.isEmpty {
            let newProgress = UserProgress()
            modelContext.insert(newProgress)
            // 最初は0歩スタートとみなす
            newProgress.lastSyncedSteps = 0
        }
    }
    
    // データの読み込みと同期開始
    private func syncData() {
        let start = Date(timeIntervalSince1970: startDateTimestamp)
        healthManager.fetchAllData()
        healthManager.fetchCumulativeSteps(from: start)
        
        // 画面を開いた時点で、保存されている経験値をレベル表示に反映
        if let progress = userProgresses.first {
            levelManager.updateDisplay(from: progress.totalExperience)
        }
    }
    
    // ★歩数の差分を計算して経験値にする処理
    private func processStepUpdate(currentTotalSteps: Double) {
        guard let progress = userProgresses.first else { return }
        
        // HealthKitがまだ0を返している間は無視
        guard currentTotalSteps > 0 else { return }
        
        // 初回同期の場合
        if progress.lastSyncedSteps == 0 {
            
        }
        
        // 前回の同期時より歩数が増えているか確認
        let diff = currentTotalSteps - progress.lastSyncedSteps
        
        if diff > 0 {
            // 差分を経験値として加算 (倍率アイテムがあればここで掛け算できる)
            let expMultiplier: Double = 1.0 // 将来的にアイテムで変更可能
            let gainedExp = diff * expMultiplier
            
            progress.totalExperience += gainedExp
            progress.lastSyncedSteps = currentTotalSteps // 同期済み歩数を更新
            
            // 保存
            do {
                try modelContext.save()
                print("経験値獲得: +\(gainedExp) (差分歩数: \(diff))")
            } catch {
                print("保存失敗: \(error)")
            }
            
            // 表示を更新
            levelManager.updateDisplay(from: progress.totalExperience)
        } else if diff < 0 {
            // デバッグで日付を過去に戻した場合など、HKの歩数が減った場合の補正
            // 今回は「同期位置をリセット」して対応
            progress.lastSyncedSteps = currentTotalSteps
        }
    }
}
// MARK: - Sub Components (部品)

// レベル表示リング
struct LevelRingView: View {
    let level: Int
    let progress: Double
    let currentExp: Int
    let nextLevelExp: Int
    
    var body: some View {
        VStack(spacing: 5) {
            // リング部分
            ZStack {
                Circle()
                    .stroke(lineWidth: 6)
                    .opacity(0.2)
                    .foregroundColor(.purple)
                
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .foregroundColor(.purple)
                    .rotationEffect(Angle(degrees: 270))
                    .animation(.spring(), value: progress)
                
                VStack(spacing: 0) {
                    Text("Lv")
                        .font(.caption2)
                        .bold()
                        .foregroundColor(.purple)
                    Text("\(level)")
                        .font(.title)
                        .bold()
                        .foregroundColor(.purple)
                }
            }
            .frame(width: 70, height: 70)
            .background(Color.white.opacity(0.9))
            .clipShape(Circle())
            .shadow(radius: 3)
            
            // 経験値テキスト (例: 1540 / 2000)
            Text("\(currentExp) / \(nextLevelExp)")
                .font(.system(size: 10, weight: .bold, design: .monospaced)) // 等幅フォントで見やすく
                .foregroundColor(.gray)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.white.opacity(0.8))
                .cornerRadius(4)
        }
    }
}

// ステータスカード（歩数・距離・カロリーを集約）
// ステータスカード（累計歩数を追加）
struct ActivitySummaryCard: View {
    @ObservedObject var healthManager: HealthKitManager
    // 累計歩数を表示するために、LevelManagerのデータも受け取るのが簡単ですが、
    // HealthManagerがcumulativeStepsを持っているのでそれを使います
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 今日の歩数
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Image(systemName: "figure.walk")
                            .foregroundColor(.green)
                        Text("今日の歩数")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(Int(healthManager.stepCount))")
                            .font(.title2)
                            .bold()
                        Text("歩")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // ★追加: 累計歩数
                VStack(alignment: .trailing, spacing: 2) {
                    Text("累計")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(Int(healthManager.cumulativeSteps)) 歩")
                        .font(.headline)
                        .foregroundColor(.green)
                }
            }
            
            Divider()
            
            HStack(spacing: 15) {
                // 距離
                HStack(spacing: 4) {
                    Image(systemName: "map.fill").foregroundColor(.blue)
                    Text(String(format: "%.1f km", healthManager.walkingDistance / 1000))
                        .font(.callout)
                        .bold()
                }
                
                // カロリー
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill").foregroundColor(.orange)
                    Text(String(format: "%.0f kcal", healthManager.calories))
                        .font(.callout)
                        .bold()
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(15)
        .shadow(radius: 3)
    }
}

// 吹き出し
struct SpeechBubble: View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(.black)
            .padding()
            .background(Color.white.opacity(0.95))
            .cornerRadius(15)
            .overlay(
                Image(systemName: "arrowtriangle.down.fill")
                    .resizable()
                    .frame(width: 20, height: 15)
                    .foregroundColor(.white.opacity(0.95))
                    .offset(y: 10),
                alignment: .bottom
            )
            .shadow(radius: 4)
    }
}

// --- デバッグ専用画面 ---

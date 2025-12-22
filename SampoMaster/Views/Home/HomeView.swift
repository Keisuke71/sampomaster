import SwiftUI
import SwiftData

struct HomeView: View {
    @ObservedObject var healthManager: HealthKitManager
    @StateObject private var levelManager = UserLevelManager()
    
    // SwiftDataへのアクセス
    @Environment(\.modelContext) private var modelContext
    @Query private var userProgresses: [UserProgress]
    
    // 計測開始日（デバッグ用）
    @AppStorage("startDate") private var startDateTimestamp: Double = Date().timeIntervalSince1970
    
    @State private var showDebugSheet = false
    @State private var tempDate = Date()
    
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
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                // --- 上部エリア ---
                HStack(alignment: .top, spacing: 15) {
                    // レベルリング (長押しでデバッグ)
                    LevelRingView(
                        level: levelManager.level,
                        progress: levelManager.progress,
                        currentExp: levelManager.currentExp,
                        nextLevelExp: levelManager.nextLevelExp
                    )
                    .onLongPressGesture {
                        tempDate = Date(timeIntervalSince1970: startDateTimestamp)
                        showDebugSheet = true
                    }
                    
                    ActivitySummaryCard(healthManager: healthManager)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
                
                // --- キャラエリア ---
                VStack(spacing: 15) {
                    SpeechBubble(text: characterDialogue)
                        .frame(maxWidth: 280)
                        .animation(.easeInOut, value: characterDialogue)
                    
                    Image("chara_ayumi_normal")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 420)
                }
                .padding(.bottom, 10)
            }
        }
        .onAppear {
            initializeDataIfNeeded()
            syncData()
        }
        // HealthKitの累計歩数が更新されたら、ゲームデータと同期する
        .onReceive(healthManager.$cumulativeSteps) { currentTotalSteps in
            processStepUpdate(currentTotalSteps: currentTotalSteps)
        }
        .sheet(isPresented: $showDebugSheet) {
            debugSheetContent
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
    
    // ★重要: 歩数の差分を計算して経験値にする処理
    private func processStepUpdate(currentTotalSteps: Double) {
        guard let progress = userProgresses.first else { return }
        
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
    
    // デバッグシートの中身
    var debugSheetContent: some View {
        VStack {
            Text("【デバッグ】計測開始日の変更")
                .font(.headline)
                .padding()
            
            DatePicker("開始日", selection: $tempDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
            
            Button("この日付から再計算") {
                startDateTimestamp = tempDate.timeIntervalSince1970
                
                // デバッグ時は「これまでの経験値をリセット」するか、
                // 「今の経験値に上乗せ」するか選べますが、
                // 今回はシンプルに再計算するためにリセット処理を入れます
                if let progress = userProgresses.first {
                    // リセットしたくない場合はこの2行をコメントアウトしてください
                    progress.totalExperience = 0
                    progress.lastSyncedSteps = 0
                }
                
                syncData()
                showDebugSheet = false
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .presentationDetents([.medium])
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

import SwiftUI

struct ExplorationView: View {
    @Bindable var gameData: GameDataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedPoint: ExplorationPoint?
    let mapAreaName = "静止限界領域・S-TPIA周辺セクター"
    
    var body: some View {
        ZStack(alignment: .top) {
            // --- 1. 背景 ---
            Image("map_around-stpia")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.5))
            
            // --- 2. マップコンテンツ ---
            GeometryReader { geo in
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                ZStack {
                    ForEach(gameData.allLocations) { point in
                        MapPointButton(point: point, isUnlocked: 0 >= point.requiredStoryId, selectedPoint: $selectedPoint)
                            .position(x: center.x + point.coordinate.x, y: center.y - point.coordinate.y)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            
            // --- 3. UIレイヤー（ヘッダーとボタンを分離して配置） ---
            
            // A. 中央のステータスヘッダー
            VStack {
                ExplorationHeaderView(gameData: gameData, areaName: mapAreaName)
                    .padding(.top, 10) // ノッチからの距離
                Spacer()
            }
            // タップ判定を阻害しないように、ヘッダー部分以外はタッチ透過
            .allowsHitTesting(false)
            
            // B. 左上のカッコいい戻るボタン
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .bold))
                            Text("BACK")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .offset(y: 1) // フォントの微調整
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule()) // カプセル型
                        .overlay(
                            Capsule()
                                .stroke(LinearGradient(
                                    colors: [.white.opacity(0.5), .white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .padding(.leading, 100) // 左端からの余白
                    .padding(.top, 10)     // 上端からの余白
                    
                    Spacer() // 右に押しやる
                }
                Spacer() // 下に押しやる
            }
        }
        // --- エリア詳細シート ---
        .sheet(item: $selectedPoint) { point in
            Text("エリア詳細: \(point.name)")
                .presentationDetents([.medium])
        }
    }
}
// マップポイントボタン（変更なし）
struct MapPointButton: View {
    let point: ExplorationPoint
    let isUnlocked: Bool
    @Binding var selectedPoint: ExplorationPoint?
    
    var body: some View {
        Button(action: {
            if isUnlocked { selectedPoint = point }
        }) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(point.id == "home" ? Color.blue : (isUnlocked ? Color.green : Color.gray))
                        .frame(width: 22, height: 22) // 少し大きく
                        .shadow(color: isUnlocked ? .green.opacity(0.6) : .clear, radius: 6)
                        .overlay(Circle().stroke(Color.white, lineWidth: 1)) // 白フチ追加
                    if !isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundColor(.white)
                    }
                }
                if isUnlocked {
                    Text(point.name)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 3)
                        .padding(.horizontal, 8)
                        .background(Material.thinMaterial, in: RoundedRectangle(cornerRadius: 6))
                        // .background(.black.opacity(0.7)) // Materialが重ければこちら
                        // .cornerRadius(6)
                }
            }
        }
    }
}

struct AreaDetailView: View {
    let point: ExplorationPoint
    var gameData: GameDataManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text(point.name)
                .font(.title)
                .fontWeight(.bold)
            
            Text(point.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Divider()
            
            if point.id == "home" {
                Text("ここは安全な拠点です。")
                    .padding()
            } else {
                HStack(spacing: 20) {
                    // 戦闘ボタン
                    Button(action: {
                        print("戦闘開始: \(point.name)")
                        // ここで戦闘画面へ遷移
                    }) {
                        VStack {
                            Image(systemName: "burst.fill")
                                .font(.largeTitle)
                            Text("中和（戦闘）")
                                .fontWeight(.bold)
                        }
                        .frame(width: 120, height: 100)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red, lineWidth: 2))
                    }
                    
                    // 採取ボタン
                    Button(action: {
                        print("採取開始: \(point.name)")
                        // ここで労働力を消費して素材ゲット処理
                    }) {
                        VStack {
                            Image(systemName: "leaf.fill")
                                .font(.largeTitle)
                            Text("素材採取")
                                .fontWeight(.bold)
                        }
                        .frame(width: 120, height: 100)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.green, lineWidth: 2))
                    }
                }
            }
        }
        .padding()
    }
}

struct ExplorationHeaderView: View {
    var gameData: GameDataManager
    let areaName: String
    
    var body: some View {
        VStack(spacing: 8) { // 縦の間隔を少し詰める
            // 1. エリア名
            HStack {
                Image(systemName: "location.fill")
                    .font(.caption2)
                    .foregroundColor(.yellow)
                Text(areaName)
                    .font(.caption) // 文字サイズを少し小さく
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.8), radius: 1, x: 0, y: 1)
                    .lineLimit(1)
            }
            .padding(.top, 8)
            
            // 2. スタミナゲージ
            // 横幅いっぱいではなく、少し余白を持たせる
            StaminaGauge(current: gameData.stamina, max: gameData.maxStamina)
                .padding(.horizontal, 12)

            // 3. ランク表示
            HStack(spacing: 8) {
                RankBadge(icon: "person.fill", color: .cyan, title: "PLYR", level: gameData.playerLevel)
                RankBadge(icon: "burst.fill", color: .red, title: "CMBT", level: gameData.combatRank)
                RankBadge(icon: "leaf.fill", color: .green, title: "GATH", level: gameData.gatheringRank)
            }
            .padding(.horizontal, 8) // 横の余白
            .padding(.bottom, 10)
        }
        // ここで横幅を制限する！
        .frame(width: 320) // ← これで横長になりすぎるのを防ぐ
        .background(
            ZStack {
                Color.black.opacity(0.6)
                Rectangle().fill(.ultraThinMaterial)
            }
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
    }
}

struct RankBadge: View {
    let icon: String
    let color: Color
    let title: String
    let level: Int
    
    var body: some View {
        VStack(spacing: 3) { // 内部の隙間も詰める
            // 上段
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundColor(color)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.system(size: 7, weight: .bold)) // 文字サイズ微調整
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(level)")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }
                Spacer() // 左寄せにする
            }
            
            // プログレスバー
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.2))
                    Capsule().fill(color).frame(width: g.size.width * 0.5)
                }
            }
            .frame(height: 3) // 少し細く
            
            // 数値
            Text("500/1K") // 文字数減らす工夫
                .font(.system(size: 6, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(6) // 内側のパディングを減らす
        .background(Color.black.opacity(0.4))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.4), lineWidth: 1)
        )
        // ここが重要：固定幅ではなく、親の幅（320）を3等分するように伸縮させる
        .frame(maxWidth: .infinity)
    }
}

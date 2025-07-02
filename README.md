# サンポマスターアプリ

歩くことをゲーム感覚で楽しめる iOS アプリ「サンポマスターアプリ」のです。

---

## 🚀 概要

サンポマスターアプリは、HealthKit を使って歩数・歩行距離・体重を取得し、消費カロリーやゲーム風のランクアップシステムで日々のウォーキングを可視化・モチベーションアップします。

* **累計歩数** に応じたランクアップ（基準歩数1000×成長率1.005）
* **プログレスバー** と **残り歩数表示** で次レベルまでの進捗を表示
* **歩数履歴タブ** で過去7/14/30日の履歴と合計歩数を確認
* **履歴グラフ**（Charts フレームワーク）による視覚的表示
* **プル・トゥ・リフレッシュ** 機能で手動更新
* **プッシュ通知リマインダー** 毎日18:00に投稿忘れをお知らせ
* **X（旧 Twitter）共有** 機能でその日の歩数と距離を投稿
* **設定タブ** でユーザー名変更・データのリセット

---

## 📱 動作環境

* iOS 15.0 以上
* Swift 5.7 以上
* Xcode 15 以上
* 実機テスト推奨 

---

## ⚙️ セットアップ手順

1. このリポジトリをクローン

   ```bash
   git clone https://github.com/ユーザー名/sampomaster.git
   cd sampomaster
   ```
2. Xcode で `.xcodeproj` または `.xcworkspace` を開く
3. プロジェクト設定 → **Signing & Capabilities** で以下を有効化

   * HealthKit（Background Delivery）
   * Background Modes → Background fetch, Remote notifications, Location updates
4. `Info.plist` を開き、必要な権限説明文を追加

   ```xml
   <key>NSHealthShareUsageDescription</key>
   <string>歩数・距離を取得するために必要です</string>
   <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
   <string>歩行距離の正確な取得のために必要です</string>
   ```
5. 実機を選択してビルド＆実行

---

## 📂 プロジェクト構成例

```
├── sampomasterApp.swift       // @main エントリポイント
├── MainTabView.swift          // レベル表示＋タブ切替メインビュー
├── ContentView.swift          // ホーム画面（歩数・距離・カルマなど）
├── HealthKitManager.swift     // HealthKit 権限 & データ取得
├── StepCountViewModel.swift   // ViewModel: 歩数・距離・体重・カロリー
├── RankManager.swift         // ランクアップ管理ロジック
├── StepHistoryView.swift      // 過去歩数リスト表示
├── StepHistoryChartView.swift // グラフ表示用チャートビュー
├── NotificationManager.swift  // プッシュ通知リマインダー
└── SettingsView.swift         // ユーザー名変更・データリセット設定画面
```

---

## 🛠️ 主要機能の使い方

### ホーム画面

* **下に引っ張って更新** で最新データを取得
* **Xで画像付き投稿** で当日歩数＆距離を共有

### 歩数履歴タブ

* プルダウンで 7/14/30 日を切り替え
* 履歴合計・個別リストを表示
* チャートで歩数推移を可視化

### 設定タブ

* **ユーザー名の変更** ボタンで別画面にて編集
* **データをリセット** ボタンで累計歩数＆レベルを初期化
 

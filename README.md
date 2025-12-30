# SampoMaster (Project ASTER)

> **S-TPIA Defense Protocol Initiated.**
> 歩くことが、生存への力になる。ポストアポカリプス世界探索型・歩数計アプリ。

![Banner Image](https://placehold.co/800x200?text=Project+ASTER) 
## 📖 概要 (Overview)
**SampoMaster** は、iOSのヘルスケア（HealthKit）と連携したアプリです。
現実世界での「歩数」がゲーム内の「経験値」や「スタミナ」に変換され、荒廃した世界（S-TPIA周辺セクター）を探索・防衛する力を得ることができます。

## ✨ 主な機能 (Features)

* **HealthKit連携**
    * 歩数、移動距離、消費カロリーを自動取得。
    * アプリ起動時に、バックグラウンドでの活動分も差分更新として反映。
* **RPG育成システム**
    * **レベルアップ:** 累計歩数に応じてプレイヤーレベルが上昇。
    * **スタミナ管理:** 歩いた分だけスタミナが回復（10歩 = 1スタミナ）。
    * **ランク制度:** 戦闘ランク・採集ランクの実装（予定）。
* **探索（Exploration）**
    * 拠点「S-TPIA」を中心としたマップ探索。
    * ストーリー進行に応じたエリア解放システム。

## 使用技術

* **Language:** Swift 5.9+
* **UI Framework:** SwiftUI
* **Data Persistence:** SwiftData / UserDefaults
* **Health Data:** HealthKit
* **State Management:** Observation Framework (`@Observable`)
* **Target:** iOS 17.0+

## セットアップ (Setup)

1.  リポジトリをクローンします。
    ```bash
    git clone [https://github.com/your-username/SampoMaster.git](https://github.com/Keisuke71/SampoMaster.git)
    ```
2.  `SampoMaster.xcodeproj` を Xcode で開きます。
3.  **Signing & Capabilities** の設定:
    * Team をご自身の Apple ID に変更してください。
    * "HealthKit" Capability が有効になっていることを確認してください。
4.  実機（iPhone）を選択してビルド・実行します。
    * ※シミュレーターではHealthKitデータが存在しないため、基本動作確認には実機推奨です（またはデバッグ機能を使用）。

## 📱 画面イメージ (Screenshots)

| タイトル画面 | 探索マップ | デバッグ画面 |
|:---:|:---:|:---:|
| | | |


---

©️ 2025 Project Sampomaster

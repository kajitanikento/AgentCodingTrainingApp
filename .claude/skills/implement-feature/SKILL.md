---
name: implement-feature
description: 画面単位で実装を進めるsubagent用スキル。設計書・アーキテクチャ方針に沿って実装し、/create-pr に必要な情報を揃えた上でPRを作成する。
argument-hint: "<plan_path> <機能名> (例: design-document/1st-scope/plan.md タスク一覧画面)"
---

## Step 1: 設計書・方針の確認

以下を必ず読んでから実装を開始する：

- `<plan_path>` （引数で受け取ったパス）— 実装ファイル一覧・テストケースの確認
- plan.md が参照している spec ファイル — 受け入れ条件・画面遷移・データモデル・バリデーションルールの確認
- `docs/ARCHITECTURE.md` — レイヤー構成・依存の方向・エラーハンドリング・非同期方針の確認

---

## Step 2: 重複チェック（実装前に必ず実施）

以下の観点で既存実装を調査し、結果を記録する（後でPRに記載する）：

### UIコンポーネント
- 実装しようとしているViewに類似した既存コンポーネントがないか検索する
- 調査したキーワードと結果（流用 or 新規作成の理由）を記録する

### ロジック・ユーティリティ
- 実装しようとしているViewModel・Repositoryに類似した既存実装がないか検索する
- 調査したキーワードと結果（流用 or 新規作成の理由）を記録する

---

## Step 3: ブランチ作成

```
git checkout -b feature/<機能名>
```

---

## Step 4: 実装（レイヤー順）

`docs/ARCHITECTURE.md` のレイヤー構成に従い、以下の順で実装する：

1. **Model** — データ構造・バリデーションルール
2. **Repository** — プロトコル定義 → 実装クラス（`async throws`）
3. **ViewModel** — `ObservableObject`。Repository をプロトコル経由でDI
4. **View** — `@StateObject` でViewModelを保持

### 実装ルール
- `CLAUDE.md` の実装ルールをすべて遵守する
- セキュリティ：外部入力は必ずバリデーション。機密データはKeychain
- ログに個人情報・認証情報を出力しない

---

## Step 5: テスト実装

`CLAUDE.md` のテストコードルールに従い、受け入れ条件をすべてテストケースに落とし込む：

- 各テストのdocコメントに「何をテストするか」と「期待値」を自然言語で明記する
- assertionは期待値と正確に対応させる（`XCTAssertNotNil` のような曖昧なassertionは使わない）

```swift
/// [何をテストするか]
/// 期待値: [期待する結果]
func test...() {
    ...
}
```

---

## Step 6: コミット

実装とテストをレイヤー単位でコミットする。

---

## Step 7: PR作成

`/create-pr` スキルを呼び出してPRを作成する。

PRの各セクションには Step 2 で記録した重複チェック結果と、設計書を引用した設計判断を必ず記載する。

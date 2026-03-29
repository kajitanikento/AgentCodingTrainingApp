---
name: create-plan
description: specを元に実装計画（plan.md）を生成するスキル。テストケースを含めて人間がレビューできる状態にする。
argument-hint: "<spec_path> (例: design-document/1st-scope/spec.md)"
---

## Step 1: ドキュメントの読み込み

以下を読んでから計画を作成する：

- `<spec_path>` （引数で受け取ったパス）— 受け入れ条件・画面遷移・データモデルの確認
- `docs/ARCHITECTURE.md` — レイヤー構成・テスト方針の確認

---

## Step 2: plan.md の生成

spec と同じディレクトリに `plan.md` を生成する。

以下の構成で記述する：

---

### plan.md の構成

```
# 実装計画

## 共有コンポーネント（PR #1）
- ブランチ: `feature/shared-components`
- 実装するファイル一覧（Model・Repository・共有UIコンポーネントなど）

> [!IMPORTANT]
> 人間レビューポイント: Modelのコード定義（Swiftコードブロック）

> [!IMPORTANT]
> 人間レビューポイント: テストケース一覧

## [画面名]（PR #2〜）
- ブランチ: `feature/[画面名]`
- Figma URL（specの画面一覧から引き継ぐ）
- 実装するファイル一覧（ViewModel・View）
- ViewModelの依存関係（依存するRepositoryプロトコルと用途）

> [!IMPORTANT]
> 人間レビューポイント: テストケース一覧

> [!IMPORTANT]
> 人間レビューポイント: UITest動画撮影シナリオ一覧

## タスク分割

| # | ブランチ名 | 内容 | PR |
|---|-----------|------|----|
| 1 | feature/shared-components | 共有コンポーネント（Model・Repository） | PR #1 |
| 2 | feature/[画面名] | [画面名]の実装 | PR #2 |
| 3 | feature/[画面名] | [画面名]の実装 | PR #3 |
| ... | | | |
```

---

## Step 3: Modelのコード定義の記述ルール

共有コンポーネントPRのModelについて、specのデータモデル定義を元にSwiftコードブロックで記述する。

```swift
struct Task: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    // ...
}

enum Priority: String, Codable, CaseIterable {
    case high
    // ...
}
```

- struct / enum / protocol をすべて記述する
- プロパティにはコメントで必須・任意・デフォルト値を明記する
- specのバリデーションルールをコメントで添える

---

## Step 5: ViewModelの依存関係の記述ルール

各画面PRのViewModelについて、依存するRepositoryプロトコルを以下のフォーマットで記述する：

```
### ViewModelの依存関係

| ViewModel | 依存するプロトコル | 用途 |
|-----------|------------------|------|
| `XxxViewModel` | `XxxRepositoryProtocol` | 〜の取得・保存など |
```

- 依存先は具体的な実装クラスではなくプロトコル名で書く（アーキテクチャ方針に従い、VMはプロトコルに依存する）
- 複数のRepositoryに依存する場合は行を分けて書く
- 用途は「何のためにこのRepositoryを使うか」を具体的に書く

---

## Step 6: テストケースの記述ルール

受け入れ条件を1つずつテストケースに落とし込む。以下のフォーマットで記述する：

```
#### [テスト対象クラス名]

| テスト関数名 | テスト内容 | 期待値 |
|-------------|-----------|--------|
| testXxx | 〜したとき | 〜になる |
```

- テスト関数名は `test` + 動作を表す英語で命名する
- テスト内容・期待値は日本語で具体的に書く
- 曖昧な期待値（「正しく動く」など）は使わない

---

## Step 7: UITest動画撮影シナリオの記述ルール

各画面PRについて、PRに添付する動画のシナリオを記述する。主要なユーザー操作フローを対象にする。

```
### UITest動画撮影シナリオ

| シナリオ名 | 操作フロー |
|-----------|-----------|
| testXxx | 1. 〜する 2. 〜する 3. 〜を確認する |
```

- シナリオはハッピーパスを中心に、画面の主要な操作フローを網羅する
- 操作フローは番号付きで具体的に書く
- `/record` スキルで撮影できる単位で切る

---

## Step 8: 完了報告

生成した `plan.md` のパスをユーザーに報告し、テストケースのレビューを促す。

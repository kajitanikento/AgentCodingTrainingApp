# アーキテクチャ方針

---

## レイヤー構成

```
View
  └── ViewModel（ObservableObject）
        └── Repository（Protocol）
              └── UserDefaults
```

## 依存の方向

- View は ViewModel のみに依存する
- ViewModel は Repository プロトコルに依存する（実装クラスには依存しない）
- Repository 実装は UserDefaults に依存する
- Model はどのレイヤーにも依存しない。View・ViewModel・Repository から参照される

## ファイル配置

- レイヤーごとにディレクトリを分ける（Models / Repositories / ViewModels / Views）
- Views は画面単位でサブディレクトリを切る
- プロトコルと実装クラスは同じディレクトリに置く

## 状態管理

- ViewModel は `ObservableObject` プロトコルを採用する
- View は `@StateObject` でViewModelを保持する
- ViewModel 間のデータ共有は親Viewが Repository を通じて再取得する

---

## エラーハンドリング方針

### エラー型

```swift
enum AppError: Error, LocalizedError {
    case saveFailed
    case loadFailed
    case deleteFailed

    var errorDescription: String? {
        switch self {
        case .saveFailed:   return "保存に失敗しました"
        case .loadFailed:   return "データの読み込みに失敗しました"
        case .deleteFailed: return "削除に失敗しました"
        }
    }
}
```

### UIへの出し方

アラートは使わず、インライン表示で統一する。

| ケース | 表示パターン |
|--------|-------------|
| 画面全体のコンテンツ取得失敗 | 全画面インライン表示（例: 「データを読み込めませんでした」＋再試行ボタン） |
| 部分的なコンテンツ取得失敗 | 該当コンテンツの箇所のみインライン表示 |

---

## 非同期方針

- Repository のメソッドは `async throws` で定義する
- 永続化先は UserDefaults だが、API通信を模倣するため擬似的な通信遅延を入れる
- ViewModel は `async` コンテキストで Repository を呼び出す
- データ取得・保存中はロード中の状態を表示する

---

## テスト方針

### テスト対象

| レイヤー | テスト種別 | 観点 |
|----------|------------|------|
| TaskRepository | UnitTest | CRUD が UserDefaults に正しく保存・取得・削除されるか |
| FilterRepository | UnitTest | フィルター選択が保存・復元されるか |
| TaskListViewModel | UnitTest | フィルタリングロジック・タスク追加削除後の状態が正しいか |
| AddTaskViewModel | UnitTest | バリデーション（空タイトルでの保存禁止）が正しく動くか |

### モック方針

- Repository はプロトコル経由で DI するため `MockTaskRepository` を作成してViewModel テストに使う
- UserDefaults への実書き込みは Repository の UnitTest でのみ行う（`suiteName` を指定してテスト用ドメインに分離）

```swift
// テスト用UserDefaults分離の例
let defaults = UserDefaults(suiteName: "test.todo")!
let repository = TaskRepository(userDefaults: defaults)
```

### UITest

- 基本的なハッピーパス（作成→一覧表示→完了→削除）をカバーする
- simctl で動画撮影できる構成にする

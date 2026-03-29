# 実装計画

## 実装方針

- 共有 Model・Repository を先に PR#1 としてまとめる
- その後、画面単位で PR を作成する（#2 タスク一覧 → #3 タスク作成 → #4 タスク編集 → #5 フィルター選択）
- ViewModel はすべて Repository プロトコルに依存させ、テストでは Mock を使う

---

## 共有コンポーネント（PR #1）

### 実装ファイル一覧

| ファイル | 種別 |
|---------|------|
| `Models/Task.swift` | Model |
| `Models/Filter.swift` | Model |
| `Models/TaskRepositoryError.swift` | Model |
| `Models/FilterRepositoryError.swift` | Model |
| `Models/ValidationError.swift` | Model |
| `Repositories/TaskRepositoryProtocol.swift` | Protocol |
| `Repositories/TaskRepository.swift` | 実装 |
| `Repositories/FilterRepositoryProtocol.swift` | Protocol |
| `Repositories/FilterRepository.swift` | 実装 |

---

> [!IMPORTANT]
> **人間レビューポイント: Modelのコード定義**
>
> ```swift
> struct Task: Identifiable, Codable, Equatable {
>     let id: UUID          // 必須・自動生成
>     var title: String     // 必須・最大30文字・空文字/空白のみ不可
>     var memo: String      // 任意・デフォルト空文字・最大100文字
>     var priority: Priority // 必須・デフォルト .medium
>     var isCompleted: Bool  // 必須・デフォルト false
>     let createdAt: Date   // 必須・作成時刻で自動セット
>     var updatedAt: Date   // 必須・保存のたびに更新
> }
>
> enum Priority: String, Codable, CaseIterable {
>     case high   // 優先度 高
>     case medium // 優先度 中（デフォルト）
>     case low    // 優先度 低
> }
>
> enum Filter: String, Codable, CaseIterable {
>     case all        // すべて（完了済み含む全タスク）
>     case incomplete // 未完了のみ
>     case completed  // 完了済みのみ
> }
>
> // Repository 層エラー（LocalizedError は持たない。UI向けメッセージは ViewModel で決める）
> enum TaskRepositoryError: Error {
>     case saveFailed
>     case loadFailed
>     case deleteFailed
> }
>
> enum FilterRepositoryError: Error {
>     case saveFailed
>     case loadFailed
> }
>
> // ViewModel 層エラー（バリデーション）
> enum ValidationError: Error, LocalizedError {
>     case titleEmpty
>     case titleTooLong     // 30文字超
>     case memoTooLong      // 100文字超
>
>     var errorDescription: String? {
>         switch self {
>         case .titleEmpty:   return "タイトルを入力してください"
>         case .titleTooLong: return "タイトルは30文字以内で入力してください"
>         case .memoTooLong:  return "メモは100文字以内で入力してください"
>         }
>     }
> }
>
> protocol TaskRepositoryProtocol {
>     func fetchAll() async throws -> [Task]
>     func save(_ task: Task) async throws
>     func delete(id: UUID) async throws
> }
>
> protocol FilterRepositoryProtocol {
>     func fetchFilter() async throws -> Filter
>     func save(_ filter: Filter) async throws
> }
> ```

---

> [!IMPORTANT]
> **人間レビューポイント: テストケース一覧**
>
> #### TaskRepository
>
> | テスト関数名 | テスト内容 | 期待値 |
> |-------------|-----------|--------|
> | `testSaveAndFetchTask` | タスクを保存して取得したとき | 保存したタスクと同じ内容が返る |
> | `testFetchAllReturnsMultipleTasks` | 複数タスクを保存して取得したとき | 保存した順に全タスクが返る |
> | `testDeleteTask` | タスクを削除したとき | 一覧からそのタスクが消える |
> | `testUpdateTask` | タスクを上書き保存したとき | 更新後の内容が返る |
> | `testFetchReturnsEmptyWhenNoData` | データが未保存のとき | 空配列が返る |
>
> #### FilterRepository
>
> | テスト関数名 | テスト内容 | 期待値 |
> |-------------|-----------|--------|
> | `testSaveAndFetchFilter` | フィルターを保存して取得したとき | 保存したフィルター値が返る |
> | `testDefaultFilterIsAll` | フィルターが未保存のとき | `.all` が返る |

---

## タスク一覧（PR #2）

**Figma:** https://www.figma.com/design/9W6qjTVGJWlBqrQXR1A0ed/TodoApp_Smaple?node-id=2001-1262

### 実装ファイル一覧

| ファイル | 種別 |
|---------|------|
| `ViewModels/TaskList/TaskListViewModel.swift` | ViewModel |
| `Views/TaskList/TaskListView.swift` | View |

### ViewModelの依存関係

| ViewModel | 依存するプロトコル | 用途 |
|-----------|------------------|------|
| `TaskListViewModel` | `TaskRepositoryProtocol` | タスクの一覧取得・削除・完了状態の切り替え |
| `TaskListViewModel` | `FilterRepositoryProtocol` | フィルターの取得・保存 |

---

> [!IMPORTANT]
> **人間レビューポイント: テストケース一覧**
>
> #### TaskListViewModel
>
> | テスト関数名 | テスト内容 | 期待値 |
> |-------------|-----------|--------|
> | `testFilterAllShowsAllTasks` | フィルターが `.all` のとき | 完了済みを含む全タスクが表示される |
> | `testFilterIncompleteShowsOnlyIncompleteTasks` | フィルターが `.incomplete` のとき | 未完了タスクのみ表示される |
> | `testDeleteTask` | タスクを削除したとき | 一覧から該当タスクが消える |
> | `testToggleTaskComplete` | 未完了タスクの完了をトグルしたとき | `isCompleted` が `true` になる |
> | `testFilterPersistsAfterSelection` | フィルターを選択したとき | `FilterRepository` に保存が呼ばれる |

---

> [!IMPORTANT]
> **人間レビューポイント: UITest動画撮影シナリオ一覧**
>
> #### UITest動画撮影シナリオ
>
> | シナリオ名 | 操作フロー |
> |-----------|-----------|
> | `testTaskCompleteAndDelete` | 1. アプリ起動 2. 既存タスクの完了ボタンをタップ 3. 打ち消し線が表示されることを確認 4. 3点メニューから削除を選択 5. 確認アラートで削除ボタンをタップ 6. 一覧から消えることを確認 |
> | `testFilterSwitch` | 1. アプリ起動（完了済みタスクあり） 2. フィルターボタンをタップ 3. 「未完了」を選択 4. 完了済みタスクが非表示になることを確認 |

---

## タスク作成（PR #3）

**Figma:** https://www.figma.com/design/9W6qjTVGJWlBqrQXR1A0ed/TodoApp_Smaple?node-id=2001-1290

### 実装ファイル一覧

| ファイル | 種別 |
|---------|------|
| `ViewModels/AddTask/AddTaskViewModel.swift` | ViewModel |
| `Views/AddTask/AddTaskView.swift` | View |

### ViewModelの依存関係

| ViewModel | 依存するプロトコル | 用途 |
|-----------|------------------|------|
| `AddTaskViewModel` | `TaskRepositoryProtocol` | 新規タスクの保存 |

---

> [!IMPORTANT]
> **人間レビューポイント: テストケース一覧**
>
> #### AddTaskViewModel
>
> | テスト関数名 | テスト内容 | 期待値 |
> |-------------|-----------|--------|
> | `testSaveButtonDisabledWhenTitleEmpty` | タイトルが空文字のとき | 保存ボタンが非活性（`isSaveEnabled == false`） |
> | `testSaveButtonDisabledWhenTitleWhitespaceOnly` | タイトルが空白のみのとき | 保存ボタンが非活性（`isSaveEnabled == false`） |
> | `testSaveButtonEnabledWhenTitleValid` | タイトルが有効な文字列のとき | 保存ボタンが活性（`isSaveEnabled == true`） |
> | `testTitleCannotExceed30Characters` | タイトルに31文字入力したとき | タイトルが30文字に切り詰められる |
> | `testMemoCannotExceed100Characters` | メモに101文字入力したとき | メモが100文字に切り詰められる |
> | `testDefaultPriorityIsMedium` | ViewModel初期化時 | 優先度が `.medium` になっている |
> | `testSaveTaskCallsRepository` | 有効なタイトルで保存したとき | `TaskRepository.save` が呼ばれる |

---

> [!IMPORTANT]
> **人間レビューポイント: UITest動画撮影シナリオ一覧**
>
> #### UITest動画撮影シナリオ
>
> | シナリオ名 | 操作フロー |
> |-----------|-----------|
> | `testCreateTask` | 1. アプリ起動 2. ナビゲーションバーの+ボタンをタップ 3. タイトルを入力 4. 優先度を選択 5. メモを入力 6. 保存ボタンをタップ 7. 一覧にタスクが追加されることを確認 |
> | `testSaveButtonDisabledWithEmptyTitle` | 1. +ボタンをタップ 2. タイトルを入力しない 3. 保存ボタンが非活性であることを確認 4. キャンセルをタップして一覧に戻ることを確認 |

---

## タスク編集（PR #4）

**Figma:** https://www.figma.com/design/9W6qjTVGJWlBqrQXR1A0ed/TodoApp_Smaple?node-id=2001-1326

### 実装ファイル一覧

| ファイル | 種別 |
|---------|------|
| `ViewModels/EditTask/EditTaskViewModel.swift` | ViewModel |
| `Views/EditTask/EditTaskView.swift` | View |

### ViewModelの依存関係

| ViewModel | 依存するプロトコル | 用途 |
|-----------|------------------|------|
| `EditTaskViewModel` | `TaskRepositoryProtocol` | 既存タスクの更新・保存 |

---

> [!IMPORTANT]
> **人間レビューポイント: テストケース一覧**
>
> #### EditTaskViewModel
>
> | テスト関数名 | テスト内容 | 期待値 |
> |-------------|-----------|--------|
> | `testExistingTaskDataPreloaded` | 既存タスクを渡してViewModel初期化したとき | フォームに既存タスクの内容が反映されている |
> | `testSaveUpdatesTask` | 内容を変更して保存したとき | `TaskRepository.save` が更新内容で呼ばれる |
> | `testCancelDoesNotCallRepository` | キャンセルしたとき | `TaskRepository.save` が呼ばれない |
> | `testSaveButtonDisabledWhenTitleEmpty` | タイトルを空にしたとき | 保存ボタンが非活性（`isSaveEnabled == false`） |

---

> [!IMPORTANT]
> **人間レビューポイント: UITest動画撮影シナリオ一覧**
>
> #### UITest動画撮影シナリオ
>
> | シナリオ名 | 操作フロー |
> |-----------|-----------|
> | `testEditTask` | 1. アプリ起動 2. タスクの3点メニューをタップ 3. 「編集」を選択 4. タイトルを変更 5. 保存ボタンをタップ 6. 一覧のタスクタイトルが変更されていることを確認 |

---

## フィルター選択（PR #5）

**Figma:** https://www.figma.com/design/9W6qjTVGJWlBqrQXR1A0ed/TodoApp_Smaple?node-id=2001-1361

### 実装ファイル一覧

| ファイル | 種別 |
|---------|------|
| `ViewModels/FilterSelection/FilterSelectionViewModel.swift` | ViewModel |
| `Views/FilterSelection/FilterSelectionView.swift` | View |

### ViewModelの依存関係

| ViewModel | 依存するプロトコル | 用途 |
|-----------|------------------|------|
| `FilterSelectionViewModel` | `FilterRepositoryProtocol` | 現在のフィルター取得・選択したフィルターの保存 |

---

> [!IMPORTANT]
> **人間レビューポイント: テストケース一覧**
>
> #### FilterSelectionViewModel
>
> | テスト関数名 | テスト内容 | 期待値 |
> |-------------|-----------|--------|
> | `testCurrentFilterIsPreselected` | ViewModel初期化時に保存済みフィルターがあるとき | そのフィルターが選択状態になっている |
> | `testSelectFilterSavesToRepository` | フィルターを選択したとき | `FilterRepository.save` が選択値で呼ばれる |

---

> [!IMPORTANT]
> **人間レビューポイント: UITest動画撮影シナリオ一覧**
>
> #### UITest動画撮影シナリオ
>
> | シナリオ名 | 操作フロー |
> |-----------|-----------|
> | `testFilterSelectionPersists` | 1. アプリ起動 2. フィルターボタンをタップ 3. 「未完了」を選択してボトムシートを閉じる 4. アプリを再起動する 5. フィルターが「未完了」のままになっていることを確認 |

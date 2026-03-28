---
name: record
description: UITestケースを録画する。make record TEST=<テストケース> を実行する。
argument-hint: "[UITestケース名] (例: AgentCodingTrainingAppUITests/ListViewUITests/testListViewLaunch)"
---

ユーザーが録画したいUITestケースを指定している場合は、そのまま `make record TEST=<指定されたケース>` を実行する。

ケースが指定されていない場合は、以下をヒアリングする：
- どのUITestケースを録画したいか（例: `AgentCodingTrainingAppUITests/ListViewUITests/testListViewLaunch` の形式で）

ケースが確定したら、Bashツールで以下を実行する：

```
make record TEST=<テストケース>
```

実行後、成功・失敗に関わらず結果をユーザーに報告する。

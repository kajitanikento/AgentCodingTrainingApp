#!/bin/bash
set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/TestArtifacts"
XCODE_LOG=$(mktemp)

# 実行するテストケースを引数から取得（未指定時はエラー）
TEST_ID="${1}"
if [ -z "$TEST_ID" ]; then
  echo "Usage: $0 <TestTarget/TestClass/testMethod>"
  echo "Example: $0 AgentCodingTrainingAppUITests/ListViewUITests/testListViewLaunch"
  exit 1
fi

# 動画ファイル名をテストケース名から生成
TEST_NAME=$(basename "$TEST_ID")
VIDEO_PATH="$OUTPUT_DIR/${TEST_NAME}_$(date +%Y%m%d_%H%M%S).mp4"

mkdir -p "$OUTPUT_DIR"

# 起動中のシミュレーターのUDIDを取得。未起動なら自動でbootする
FALLBACK_UDID="0A1CA698-5142-453E-B767-2E02A3CB0B90" # iPhone 17 Pro iOS 26.3.1
BOOTED_UDID=$(xcrun simctl list devices | grep "Booted" | grep -E -o '[0-9A-F-]{36}' | head -1)
if [ -z "$BOOTED_UDID" ]; then
  echo "起動中のシミュレーターが見つかりません。$FALLBACK_UDID を起動します..."
  xcrun simctl boot "$FALLBACK_UDID"
  sleep 3
  BOOTED_UDID="$FALLBACK_UDID"
fi
echo "Recording target: $BOOTED_UDID"

# テストをバックグラウンドで実行し、ログをファイルに書き出す
xcodebuild test \
  -project "$PROJECT_ROOT/AgentCodingTrainingApp.xcodeproj" \
  -scheme "AgentCodingTrainingApp" \
  -destination "platform=iOS Simulator,id=$BOOTED_UDID" \
  -parallel-testing-enabled NO \
  -only-testing "$TEST_ID" \
  > "$XCODE_LOG" 2>&1 &
XCODE_PID=$!

# アプリのプロセスが起動したタイミングで録画開始
echo "Waiting for app launch..."
TIMEOUT=60
DEADLINE=$((SECONDS + TIMEOUT))
until pgrep -f "AgentCodingTrainingApp" > /dev/null 2>&1; do
  sleep 0.3
  if [ $SECONDS -ge $DEADLINE ]; then
    echo "Error: アプリ起動待ちがタイムアウトしました（${TIMEOUT}秒）"
    kill "$XCODE_PID" 2>/dev/null || true
    rm -f "$XCODE_LOG"
    exit 1
  fi
done
xcrun simctl io booted recordVideo "$VIDEO_PATH" &
RECORD_PID=$!
echo "Recording started (PID: $RECORD_PID)"

# テスト完了を待つ
wait "$XCODE_PID"
TEST_EXIT=$?
cat "$XCODE_LOG"
rm -f "$XCODE_LOG"

# 録画停止
kill -SIGINT "$RECORD_PID"
wait "$RECORD_PID" 2>/dev/null || true

if [ $TEST_EXIT -ne 0 ]; then
  echo "✗ テスト失敗 (exit code: $TEST_EXIT)"
  exit $TEST_EXIT
fi

# 動画を圧縮（PR添付用）
COMPRESSED_PATH="${VIDEO_PATH%.mp4}_compressed.mp4"
echo "Compressing video..."
ffmpeg -i "$VIDEO_PATH" -vcodec libx264 -crf 28 -preset fast -vf "scale=600:-2" "$COMPRESSED_PATH" -y 2>/dev/null
ORIGINAL_SIZE=$(du -sh "$VIDEO_PATH" | cut -f1)
COMPRESSED_SIZE=$(du -sh "$COMPRESSED_PATH" | cut -f1)
rm -f "$VIDEO_PATH"

echo "✓ テスト成功"
echo "✓ 動画: $COMPRESSED_PATH ($ORIGINAL_SIZE → $COMPRESSED_SIZE)"

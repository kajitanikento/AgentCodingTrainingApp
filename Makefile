.PHONY: setup record

setup:
	@echo "Installing dependencies..."
	@which brew > /dev/null || (echo "Error: Homebrew が見つかりません。https://brew.sh からインストールしてください。" && exit 1)
	@which ffmpeg > /dev/null && echo "ffmpeg: already installed" || (brew install ffmpeg && echo "ffmpeg: installed")
	@echo "Setup complete!"

record:
	@[ -n "$(TEST)" ] || (echo "Error: TEST を指定してください。\nExample: make record TEST=AgentCodingTrainingAppUITests/ListViewUITests/testListViewLaunch" && exit 1)
	@./scripts/record_uitest.sh "$(TEST)"

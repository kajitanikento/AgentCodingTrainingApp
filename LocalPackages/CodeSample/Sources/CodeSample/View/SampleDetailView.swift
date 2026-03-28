import SwiftUI

public struct SampleDetailView: View {
    @StateObject private var viewModel: SampleDetailViewModel

    public init(itemId: UUID, repository: any SampleListItemRepository) {
        _viewModel = StateObject(wrappedValue: SampleDetailViewModel(itemId: itemId, repository: repository))
    }

    public var body: some View {
        content
            .navigationTitle(viewModel.item?.title ?? "詳細")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.fetchItem()
            }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("読み込み中...")
        } else if let errorMessage = viewModel.errorMessage {
            ContentUnavailableView(
                "エラー",
                systemImage: "exclamationmark.triangle",
                description: Text(errorMessage)
            )
        } else if let item = viewModel.item {
            List {
                Section("ステータス") {
                    HStack {
                        Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(item.isCompleted ? .green : .secondary)
                        Text(item.isCompleted ? "完了" : "未完了")
                    }
                }
                Section("作成日時") {
                    Text(item.createdAt.formatted(date: .long, time: .shortened))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview("正常") {
    NavigationStack {
        SampleDetailView(
            itemId: MockSampleListItemRepository.previewItemId,
            repository: MockSampleListItemRepository()
        )
    }
}

#Preview("エラー") {
    NavigationStack {
        SampleDetailView(
            itemId: MockSampleListItemRepository.previewItemId,
            repository: MockSampleListItemRepository(shouldThrow: true)
        )
    }
}

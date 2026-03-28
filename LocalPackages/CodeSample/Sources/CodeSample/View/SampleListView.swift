import SwiftUI

public struct SampleListView: View {
    @StateObject private var viewModel = SampleListViewModel(
        repository: MockSampleListItemRepository()
    )

    public init() {}

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("リスト一覧")
        }
        .task {
            await viewModel.fetchItems()
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
        } else {
            List(viewModel.items) { item in
                NavigationLink(value: item) {
                    SampleListRowView(item: item)
                }
            }
            .navigationDestination(for: SampleListItem.self) { item in
                SampleDetailView(itemId: item.id, repository: MockSampleListItemRepository())
            }
        }
    }
}

private struct SampleListRowView: View {
    let item: SampleListItem

    var body: some View {
        HStack {
            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(item.isCompleted ? .green : .secondary)
            Text(item.title)
                .strikethrough(item.isCompleted)
                .foregroundStyle(item.isCompleted ? .secondary : .primary)
        }
    }
}

#Preview {
    SampleListView()
}

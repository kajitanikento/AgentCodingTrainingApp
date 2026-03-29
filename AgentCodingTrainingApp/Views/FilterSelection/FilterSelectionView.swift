import SwiftUI

struct FilterSelectionView: View {
    @StateObject private var viewModel: FilterSelectionViewModel
    @Environment(\.dismiss) private var dismiss
    var onFilterSelected: ((Filter) -> Void)?

    init(currentFilter: Filter, onFilterSelected: ((Filter) -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: FilterSelectionViewModel(
            currentFilter: currentFilter,
            repository: FilterRepository()
        ))
        self.onFilterSelected = onFilterSelected
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("フィルター選択")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("閉じる") { dismiss() }
                            .accessibilityIdentifier("close-button")
                    }
                }
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            filterList
                .padding(16)
            Spacer()
        }
        .background(Color(.systemGroupedBackground))
    }

    private var filterList: some View {
        VStack(spacing: 0) {
            ForEach(Filter.allCases, id: \.self) { filter in
                filterRow(filter)
                if filter != Filter.allCases.last {
                    Divider().padding(.leading, 16)
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }

    private func filterRow(_ filter: Filter) -> some View {
        Button {
            Task {
                let saved = await viewModel.select(filter)
                if saved {
                    onFilterSelected?(filter)
                }
            }
        } label: {
            HStack {
                Text(filter.label)
                    .font(.body)
                    .foregroundStyle(Color(hex: "#101828"))
                Spacer()
                if viewModel.selectedFilter == filter {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 17)
        }
        .accessibilityIdentifier("filter-option-\(filter.rawValue)")
        .buttonStyle(.plain)
    }
}

private extension Filter {
    var label: String {
        switch self {
        case .all:        return "すべて"
        case .incomplete: return "未完了"
        case .completed:  return "完了済み"
        }
    }
}

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xff) / 255
        let g = Double((int >> 8) & 0xff) / 255
        let b = Double(int & 0xff) / 255
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    FilterSelectionView(currentFilter: .all)
}

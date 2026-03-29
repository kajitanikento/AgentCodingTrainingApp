import SwiftUI
import CodeSample

private enum LaunchScreen: String {
    // Code samples
    case sampleList = "--list"
    case sampleDetail = "--detail"
    case sampleDetailError = "--detail-error"

    static func resolve(from arguments: [String]) -> LaunchScreen? {
        guard arguments.contains("--screen") else { return nil }
        return arguments.compactMap { LaunchScreen(rawValue: $0) }.first
    }
}

@main
struct AgentCodingTrainingAppApp: App {
    var body: some Scene {
        WindowGroup {
            switch LaunchScreen.resolve(from: ProcessInfo.processInfo.arguments) {
            case .sampleList:
                SampleListView()
            case .sampleDetail:
                NavigationStack {
                    SampleDetailView(
                        itemId: MockSampleListItemRepository.previewItemId,
                        repository: MockSampleListItemRepository()
                    )
                }
            case .sampleDetailError:
                NavigationStack {
                    SampleDetailView(
                        itemId: MockSampleListItemRepository.previewItemId,
                        repository: MockSampleListItemRepository(shouldThrow: true)
                    )
                }
            case nil:
                TaskListView()
            }
        }
    }
}

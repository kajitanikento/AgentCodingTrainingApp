import Foundation

struct TodoTask: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var memo: String
    var priority: Priority
    var isCompleted: Bool
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        memo: String = "",
        priority: Priority = .medium,
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.memo = memo
        self.priority = priority
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum Priority: String, Codable, CaseIterable {
    case high
    case medium
    case low
}

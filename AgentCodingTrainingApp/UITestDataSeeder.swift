import Foundation

enum UITestDataSeeder {
    static func seed() {
        let tasks: [TodoTask] = [
            TodoTask(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                title: "牛乳を買う",
                memo: "近所のスーパーで低脂肪牛乳を購入する",
                priority: .high,
                isCompleted: false,
                createdAt: Date(),
                updatedAt: Date()
            ),
            TodoTask(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                title: "メール返信",
                memo: "",
                priority: .low,
                isCompleted: true,
                createdAt: Date(),
                updatedAt: Date()
            ),
            TodoTask(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
                title: "企画書作成",
                memo: "",
                priority: .medium,
                isCompleted: false,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]

        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: "tasks")
        }
        UserDefaults.standard.removeObject(forKey: "filter")
    }
}

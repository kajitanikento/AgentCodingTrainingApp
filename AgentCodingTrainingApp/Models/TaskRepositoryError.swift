import Foundation

enum TaskRepositoryError: Error {
    case saveFailed
    case loadFailed
    case deleteFailed
}

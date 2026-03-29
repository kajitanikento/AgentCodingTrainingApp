import Foundation

enum Filter: String, Codable, CaseIterable {
    case all
    case incomplete
    case completed
}

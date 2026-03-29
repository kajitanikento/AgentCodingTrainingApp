import Foundation

enum ValidationError: Error, LocalizedError {
    case titleEmpty
    case titleTooLong
    case memoTooLong

    var errorDescription: String? {
        switch self {
        case .titleEmpty:   return "タイトルを入力してください"
        case .titleTooLong: return "タイトルは30文字以内で入力してください"
        case .memoTooLong:  return "メモは100文字以内で入力してください"
        }
    }
}

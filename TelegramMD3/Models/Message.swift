import Foundation

struct Message: Identifiable {
    let id: Int64
    let text: String
    let isMine: Bool
    let timestamp: Date
}

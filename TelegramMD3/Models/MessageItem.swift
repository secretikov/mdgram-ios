import Foundation

enum TextEntityType: Equatable {
    case bold
    case italic
    case strikethrough
    case underline
    case code
    case url
    case textUrl(url: String)
    case customEmoji(id: Int64)
    case spoiler
    case expandableBlockQuote
}

struct TextEntity: Equatable {
    let offset: Int
    let length: Int
    let type: TextEntityType
}

struct MessageItem: Identifiable {
    let id: Int64
    let text: String
    let isMine: Bool
    let timestamp: Date
    var entities: [TextEntity] = []
}

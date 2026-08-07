import Foundation

// Интерфейс сервиса (Dependency Inversion)
protocol TelegramServiceProtocol {
    func getChats(limit: Int) async throws -> [ChatItem]
    func sendMessage(chatId: Int64, text: String) async throws
}

// Заглушка для Preview и тестов
class MockTelegramService: TelegramServiceProtocol {
    func getChats(limit: Int) async throws -> [ChatItem] {
        return [
            ChatItem(id: 1, title: "iOS Developers", lastMessage: "Кто уже щупал iOS 18?"),
            ChatItem(id: 2, title: "Design Team", lastMessage: "Скинул новые спеки MD3 в фигму"),
            ChatItem(id: 3, title: "Pavel Durov", lastMessage: "Great job on the new app!")
        ]
    }
    func sendMessage(chatId: Int64, text: String) async throws {}
}

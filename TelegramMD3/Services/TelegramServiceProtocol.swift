import Foundation

// Интерфейс сервиса (Dependency Inversion)
protocol TelegramServiceProtocol {
    func getChats(limit: Int) async throws -> [ChatPreview]
    func sendMessage(chatId: Int64, text: String) async throws
}

// Заглушка для Preview и тестов
class MockTelegramService: TelegramServiceProtocol {
    func getChats(limit: Int) async throws -> [ChatPreview] {
        return [
            ChatPreview(id: 1, title: "iOS Developers", lastMessage: "Кто уже щупал iOS 18?"),
            ChatPreview(id: 2, title: "Design Team", lastMessage: "Скинул новые спеки MD3 в фигму"),
            ChatPreview(id: 3, title: "Pavel Durov", lastMessage: "Great job on the new app!")
        ]
    }
    func sendMessage(chatId: Int64, text: String) async throws {}
}

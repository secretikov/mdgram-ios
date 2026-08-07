import Foundation
import Observation

// ViewModel
@Observable
class ChatsViewModel {
    var chats: [ChatPreview] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil

    private let telegramService: TelegramServiceProtocol

    init(telegramService: TelegramServiceProtocol = MockTelegramService()) {
        self.telegramService = telegramService
    }

    @MainActor
    func loadChats() async {
        isLoading = true
        do {
            let fetchedChats = try await telegramService.getChats(limit: 20)
            self.chats = fetchedChats
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    func sendMessage(to chatId: Int64, text: String) async {
        do {
            try await telegramService.sendMessage(chatId: chatId, text: text)
        } catch {
            self.errorMessage = "Failed to send message: \(error.localizedDescription)"
        }
    }
}

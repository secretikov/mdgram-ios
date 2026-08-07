import Foundation
import TDLibKit

class TDLibService: TelegramServiceProtocol {
    static let shared = TDLibService()

    private var client: TDLibClient
    private var api: TDLibApi

    private init() {
        // Initialize TDLibClient and TDLibApi wrapper
        self.client = TDLibClient()
        self.api = TDLibApi(client: client)

        initializeClient()
    }

    private func initializeClient() {
        // Setup TDLib parameters
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path

        Task {
            // Wait for the initial updateAuthorizationState from the update stream
            // Below we configure basic TDLib parameters needed to bootstrap the client.
            _ = try? await api.setTdlibParameters(
                apiHash: "YOUR_API_HASH", // Placeholder
                apiId: 1234567, // Placeholder
                applicationVersion: "1.0",
                databaseDirectory: documentsPath + "/tdlib",
                deviceModel: "iOS",
                enableStorageOptimizer: true,
                filesDirectory: documentsPath + "/tdlib_files",
                systemLanguageCode: "en",
                systemVersion: "iOS 17",
                useChatInfoDatabase: true,
                useFileDatabase: true,
                useMessageDatabase: true,
                useSecretChats: false,
                useTestDc: false
            )
        }

        // Start listening to the update stream
        Task {
            await startUpdateStream()
        }
    }

    private func startUpdateStream() async {
        // Real AsyncStream of TDLib updates using TDLibKit's streaming capability
        // This listens to all incoming events from the TDLib core
        for await update in api.updates {
            // handle(update) - parse authorization states, incoming messages, etc.
            switch update {
            case .updateAuthorizationState(let authState):
                print("Auth state changed: \(authState)")
            case .updateNewMessage(let messageUpdate):
                print("New message received in chat \(messageUpdate.message.chatId)")
            default:
                break
            }
        }
    }

    func getChats(limit: Int) async throws -> [ChatItem] {
        // Send actual GetChats request to TDLib
        let chatListResponse = try await api.getChats(chatList: nil, limit: limit)

        var chats: [ChatItem] = []
        for chatId in chatListResponse.chatIds {
            // Fetch the specific chat details for each ID
            if let chat = try? await api.getChat(chatId: chatId) {
                // Fetch the last message text if it exists
                var lastMessageText = ""
                if let lastMessage = chat.lastMessage,
                   case let .messageText(textData) = lastMessage.content {
                    lastMessageText = textData.text.text
                }

                chats.append(ChatItem(id: chat.id, title: chat.title, lastMessage: lastMessageText))
            }
        }
        return chats
    }

    func sendMessage(chatId: Int64, text: String) async throws {
        // Construct and send a real SendMessage request to TDLib
        let messageContent = InputMessageText(
            clearDraft: true,
            disableWebPagePreview: false,
            text: FormattedText(entities: [], text: text)
        )

        let _ = try await api.sendMessage(
            chatId: chatId,
            inputMessageContent: .inputMessageText(messageContent),
            messageThreadId: 0,
            options: nil,
            replyToMessageId: 0
        )
    }
}

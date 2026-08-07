import SwiftUI

struct MD3ChatListView: View {
    @State private var viewModel = ChatsViewModel()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                // Основной контент со списком чатов
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.chats) { chat in
                            MD3ChatRow(chat: chat)
                            Divider().background(MD3Theme.surfaceVariant)
                        }
                    }
                    .padding(.bottom, 100) // Отступ под NavigationBar и FAB
                }
                .background(MD3Theme.surface.ignoresSafeArea())

                // Floating Action Button (FAB)
                Button(action: {
                    // Создать новый чат
                }) {
                    Image(systemName: "square.and.pencil")
                        .font(.title2)
                        .foregroundColor(MD3Theme.onPrimaryContainer)
                        .padding(16)
                        .background(MD3Theme.primaryContainer)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 96) // Выше Bottom Navigation

                // MD3 Bottom Navigation Bar
                VStack {
                    Spacer()
                    MD3NavigationBar()
                }
            }
            .navigationTitle("Telegram")
            .navigationBarTitleDisplayMode(.inline)
            // MD3 Top App Bar Styling
            .toolbarBackground(MD3Theme.surface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { /* Открыть меню/настройки */ }) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(MD3Theme.onSurface)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { /* Поиск */ }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(MD3Theme.onSurface)
                    }
                }
            }
        }
        .task {
            await viewModel.loadChats()
        }
    }
}

// Заглушка строки чата
struct MD3ChatRow: View {
    let chat: ChatPreview

    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(MD3Theme.secondaryContainer)
                .frame(width: 50, height: 50)
                .overlay(Text(String(chat.title.prefix(1))).foregroundColor(MD3Theme.onSecondaryContainer))

            VStack(alignment: .leading, spacing: 4) {
                Text(chat.title)
                    .font(.headline)
                    .foregroundColor(MD3Theme.onSurface)
                Text(chat.lastMessage)
                    .font(.subheadline)
                    .foregroundColor(MD3Theme.outline)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(16)
        .background(MD3Theme.surface)
    }
}

// MD3 Navigation Bar
struct MD3NavigationBar: View {
    var body: some View {
        HStack {
            MD3NavItem(icon: "message.fill", title: "Чаты", isSelected: true)
            Spacer()
            MD3NavItem(icon: "phone", title: "Звонки", isSelected: false)
            Spacer()
            MD3NavItem(icon: "gearshape", title: "Настройки", isSelected: false)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 12)
        .background(MD3Theme.surfaceVariant.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

struct MD3NavItem: View {
    let icon: String
    let title: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
                .background(isSelected ? MD3Theme.secondaryContainer : Color.clear)
                .clipShape(Capsule())
                .foregroundColor(isSelected ? MD3Theme.onSecondaryContainer : MD3Theme.onSurfaceVariant)

            Text(title)
                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? MD3Theme.onSurface : MD3Theme.onSurfaceVariant)
        }
    }
}

import SwiftUI

struct MD3MessageBubbleView: View {
    let message: Message

    var body: some View {
        HStack {
            if message.isMine { Spacer(minLength: 40) }

            Text(message.text)
                .font(.system(size: 16, weight: .regular, design: .default))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .foregroundColor(message.isMine ? MD3ColorScheme.onPrimaryContainer : MD3ColorScheme.onSecondaryContainer)
                .background(message.isMine ? MD3ColorScheme.primaryContainer : MD3ColorScheme.secondaryContainer)
                // Асимметричные углы (хвостик сообщения)
                .clipShape(
                    .rect(
                        topLeadingRadius: 20,
                        bottomLeadingRadius: message.isMine ? 20 : 4,
                        bottomTrailingRadius: message.isMine ? 4 : 20,
                        topTrailingRadius: 20
                    )
                )

            if !message.isMine { Spacer(minLength: 40) }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

import SwiftUI

struct MD3FloatingTextField: View {
    let title: String
    @Binding var text: String
    var isSecure: Bool = false

    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            // Floating Label
            Text(title)
                .font(.system(size: (isFocused || !text.isEmpty) ? 12 : 16))
                .foregroundColor(isFocused ? MD3ColorScheme.primary : MD3ColorScheme.onSurfaceVariant)
                .offset(y: (isFocused || !text.isEmpty) ? -24 : 0)
                .animation(.easeInOut(duration: 0.2), value: isFocused || !text.isEmpty)

            // Text Field
            Group {
                if isSecure {
                    SecureField("", text: $text)
                } else {
                    TextField("", text: $text)
                }
            }
            .focused($isFocused)
            .padding(.top, (isFocused || !text.isEmpty) ? 12 : 0)
            .foregroundColor(MD3ColorScheme.onSurface)
            .tint(MD3ColorScheme.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(MD3ColorScheme.surfaceVariant)
        .clipShape(
            .rect(
                topLeadingRadius: 4,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 4
            )
        )
        .overlay(
            Rectangle()
                .frame(height: isFocused ? 2 : 1)
                .foregroundColor(isFocused ? MD3ColorScheme.primary : MD3ColorScheme.outline),
            alignment: .bottom
        )
    }
}

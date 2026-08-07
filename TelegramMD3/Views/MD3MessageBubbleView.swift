import SwiftUI

struct MD3MessageBubbleView: View {
    let message: MessageItem

    var body: some View {
        HStack {
            if message.isMine { Spacer(minLength: 40) }

            MD3FormattedTextView(text: message.text, entities: message.entities, isMine: message.isMine)
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

struct MD3FormattedTextView: View {
    let text: String
    let entities: [TextEntity]
    let isMine: Bool

    var body: some View {
        // A full parser for nested components (like expandable blockquote enclosing other styled text)
        // is complex for a simple SwiftUI Text view, but we can separate block entities
        // from inline entities.

        let blockQuotes = entities.filter { $0.type == .expandableBlockQuote }

        if blockQuotes.isEmpty {
            parseInline(text: text, entities: entities)
                .font(.system(size: 16, weight: .regular, design: .default))
                .tint(MD3ColorScheme.primary)
        } else {
            // For simplicity in this skeleton, if there's an expandable block quote, we split the text
            VStack(alignment: .leading, spacing: 8) {
                ForEach(splitIntoBlocks(text: text, entities: entities), id: \.id) { block in
                    if block.isBlockQuote {
                        MD3ExpandableQuoteView(isMine: isMine) {
                            parseInline(text: block.text, entities: block.inlineEntities)
                                .font(.system(size: 16, weight: .regular, design: .default))
                        }
                    } else {
                        parseInline(text: block.text, entities: block.inlineEntities)
                            .font(.system(size: 16, weight: .regular, design: .default))
                    }
                }
            }
            .tint(MD3ColorScheme.primary)
        }
    }

    // Parses string applying inline styles and custom views
    @ViewBuilder
    private func parseInline(text: String, entities: [TextEntity]) -> some View {
        // Create an array of inline components
        let components = buildInlineComponents(text: text, entities: entities)

        MD3FlowLayout(spacing: 4) {
            ForEach(0..<components.count, id: \.self) { index in
                components[index]
            }
        }
    }

    // Helper to slice text into components
    private func buildInlineComponents(text: String, entities: [TextEntity]) -> [AnyView] {
        var views: [AnyView] = []
        let nsString = text as NSString
        var currentIndex = 0

        // Sort entities by offset
        let sortedEntities = entities.sorted { $0.offset < $1.offset }

        for entity in sortedEntities {
            var isCustomEmoji = false
            if case .customEmoji = entity.type { isCustomEmoji = true }

            guard entity.type == .spoiler || isCustomEmoji else {
                continue // Skip simple text attributes here, we handle them in the Text blocks
            }

            if entity.offset > currentIndex {
                // Add plain text up to the entity
                let range = NSRange(location: currentIndex, length: entity.offset - currentIndex)
                if range.upperBound <= nsString.length {
                    let subtext = nsString.substring(with: range)
                    views.append(AnyView(buildText(subtext, entities: entities, baseOffset: currentIndex)))
                }
            }

            let entityRange = NSRange(location: entity.offset, length: entity.length)
            if entityRange.upperBound <= nsString.length {
                let entityText = nsString.substring(with: entityRange)
                if entity.type == .spoiler {
                    views.append(AnyView(MD3SpoilerView(text: entityText)))
                } else if case .customEmoji = entity.type {
                    // Custom emoji placeholder
                    views.append(AnyView(Image(systemName: "face.smiling").foregroundColor(.yellow)))
                }
            }
            currentIndex = entity.offset + entity.length
        }

        if currentIndex < nsString.length {
            let remainingRange = NSRange(location: currentIndex, length: nsString.length - currentIndex)
            let subtext = nsString.substring(with: remainingRange)
            views.append(AnyView(buildText(subtext, entities: entities, baseOffset: currentIndex)))
        }

        if views.isEmpty {
             views.append(AnyView(buildText(text, entities: entities, baseOffset: 0)))
        }

        return views
    }

    // Helper to build a Text view with standard inline attributes
    private func buildText(_ substring: String, entities: [TextEntity], baseOffset: Int) -> Text {
        let nsAttrString = NSMutableAttributedString(string: substring)
        let substringLength = (substring as NSString).length

        for entity in entities {
            // Check if entity overlaps with substring
            let entityStart = max(0, entity.offset - baseOffset)
            let entityEnd = min(substringLength, (entity.offset + entity.length) - baseOffset)

            if entityStart < entityEnd {
                let range = NSRange(location: entityStart, length: entityEnd - entityStart)

                switch entity.type {
                case .bold:
                    nsAttrString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16), range: range)
                case .italic:
                    nsAttrString.addAttribute(.font, value: UIFont.italicSystemFont(ofSize: 16), range: range)
                case .strikethrough:
                    nsAttrString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
                case .underline:
                    nsAttrString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
                case .code:
                    nsAttrString.addAttribute(.font, value: UIFont.monospacedSystemFont(ofSize: 15, weight: .regular), range: range)
                    nsAttrString.addAttribute(.backgroundColor, value: UIColor(MD3ColorScheme.surfaceVariant), range: range)
                case .url:
                    if let urlString = (substring as NSString).substring(with: range) as String?, let url = URL(string: urlString) {
                        nsAttrString.addAttribute(.link, value: url, range: range)
                    }
                case .textUrl(let urlString):
                    if let url = URL(string: urlString) {
                        nsAttrString.addAttribute(.link, value: url, range: range)
                    }
                default:
                    break
                }
            }
        }

        let attrStr = try! AttributedString(nsAttrString, including: \.uiKit)
        return Text(attrStr)
    }

    struct Block: Identifiable {
        let id = UUID()
        let text: String
        let isBlockQuote: Bool
        let inlineEntities: [TextEntity]
    }

    private func splitIntoBlocks(text: String, entities: [TextEntity]) -> [Block] {
        var blocks: [Block] = []
        let nsText = text as NSString
        let quoteEntities = entities.filter { $0.type == .expandableBlockQuote }.sorted { $0.offset < $1.offset }

        var currentIndex = 0

        for quote in quoteEntities {
            if quote.offset > currentIndex {
                let range = NSRange(location: currentIndex, length: quote.offset - currentIndex)
                if range.upperBound <= nsText.length {
                    let before = nsText.substring(with: range)
                    blocks.append(Block(text: before, isBlockQuote: false, inlineEntities: entities.filter { $0.type != .expandableBlockQuote }))
                }
            }

            let quoteRange = NSRange(location: quote.offset, length: quote.length)
            if quoteRange.upperBound <= nsText.length {
                let quoteText = nsText.substring(with: quoteRange)
                blocks.append(Block(text: quoteText, isBlockQuote: true, inlineEntities: entities.filter { $0.type != .expandableBlockQuote }))
            }
            currentIndex = quote.offset + quote.length
        }

        if currentIndex < nsText.length {
            let remainingRange = NSRange(location: currentIndex, length: nsText.length - currentIndex)
            let after = nsText.substring(with: remainingRange)
            blocks.append(Block(text: after, isBlockQuote: false, inlineEntities: entities.filter { $0.type != .expandableBlockQuote }))
        }

        return blocks
    }
}

// Simple FlowLayout for iOS 16+
struct MD3FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.bounds
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: ProposedViewSize(result.frames[index].size))
        }
    }

    struct FlowResult {
        var bounds: CGSize = .zero
        var frames: [CGRect] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var rowHeight: CGFloat = 0
            var maxRowWidth: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if currentX + size.width > maxWidth, currentX > 0 {
                    // Move to next row
                    currentX = 0
                    currentY += rowHeight + spacing
                    rowHeight = 0
                }

                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                currentX += size.width + spacing
                rowHeight = max(rowHeight, size.height)
                maxRowWidth = max(maxRowWidth, currentX - spacing)
            }
            bounds = CGSize(width: maxRowWidth, height: currentY + rowHeight)
        }
    }
}

// Custom view for Spoilers
struct MD3SpoilerView: View {
    let text: String
    @State private var isRevealed = false

    var body: some View {
        Text(text)
            .blur(radius: isRevealed ? 0 : 4)
            .onTapGesture {
                withAnimation {
                    isRevealed = true
                }
            }
    }
}

// Custom view for Expandable Block Quotes
struct MD3ExpandableQuoteView<Content: View>: View {
    let isMine: Bool
    @ViewBuilder let content: Content

    @State private var isExpanded = false

    var body: some View {
        HStack(spacing: 8) {
            // Vertical accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(MD3ColorScheme.primary)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 4) {
                content
                    .lineLimit(isExpanded ? nil : 3) // Collapsed state shows 3 lines

                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(MD3ColorScheme.primary)
                        .padding(4)
                        .background(MD3ColorScheme.primary.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding(8)
        .background(MD3ColorScheme.surfaceVariant)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

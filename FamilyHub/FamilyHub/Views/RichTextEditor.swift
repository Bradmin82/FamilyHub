import SwiftUI

struct RichTextEditor: View {
    @Binding var text: String
    @State private var isBold = false
    @State private var isItalic = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Formatting toolbar
            HStack(spacing: 15) {
                Button(action: { insertMarkdown("**", "**") }) {
                    Image(systemName: "bold")
                        .foregroundColor(isBold ? .blue : .gray)
                }

                Button(action: { insertMarkdown("*", "*") }) {
                    Image(systemName: "italic")
                        .foregroundColor(isItalic ? .blue : .gray)
                }

                Button(action: { insertMarkdown("- ", "") }) {
                    Image(systemName: "list.bullet")
                        .foregroundColor(.gray)
                }

                Button(action: { insertMarkdown("1. ", "") }) {
                    Image(systemName: "list.number")
                        .foregroundColor(.gray)
                }

                Button(action: { insertMarkdown("[ ] ", "") }) {
                    Image(systemName: "checkmark.square")
                        .foregroundColor(.gray)
                }

                Spacer()

                Text("\(text.count) characters")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(8)

            // Text editor
            TextEditor(text: $text)
                .focused($isFocused)
                .frame(minHeight: 150)
                .padding(8)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

            // Markdown preview hint
            if !text.isEmpty && containsMarkdown() {
                Text("Markdown formatting will be displayed when viewing the task")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
        }
    }

    private func insertMarkdown(_ prefix: String, _ suffix: String) {
        let newText = prefix + suffix
        text += newText
        isFocused = true
    }

    private func containsMarkdown() -> Bool {
        text.contains("**") || text.contains("*") || text.contains("- ") || text.contains("[ ]")
    }
}

// Markdown text renderer for displaying formatted text
struct MarkdownText: View {
    let text: String

    var body: some View {
        Text(formatMarkdown(text))
    }

    private func formatMarkdown(_ text: String) -> AttributedString {
        var attributedString = AttributedString(text)

        // Bold text **text**
        if let range = attributedString.range(of: #/\*\*([^\*]+)\*\*/#) {
            attributedString[range].font = .boldSystemFont(ofSize: 16)
        }

        // Italic text *text*
        if let range = attributedString.range(of: #/\*([^\*]+)\*/#) {
            attributedString[range].font = .italicSystemFont(ofSize: 16)
        }

        return attributedString
    }
}

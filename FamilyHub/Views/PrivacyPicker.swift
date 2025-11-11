import SwiftUI

struct PrivacyPicker: View {
    @Binding var selectedPrivacy: Privacy
    let title: String
    let showDescription: Bool

    init(selectedPrivacy: Binding<Privacy>, title: String = "Who can see this?", showDescription: Bool = true) {
        self._selectedPrivacy = selectedPrivacy
        self.title = title
        self.showDescription = showDescription
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            ForEach(Privacy.allCases, id: \.self) { privacy in
                Button(action: {
                    selectedPrivacy = privacy
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: privacy.icon)
                            .foregroundColor(selectedPrivacy == privacy ? .blue : .gray)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(privacy.displayName)
                                .font(.body)
                                .fontWeight(selectedPrivacy == privacy ? .semibold : .regular)
                                .foregroundColor(.primary)

                            if showDescription {
                                Text(privacy.description)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }

                        Spacer()

                        if selectedPrivacy == privacy {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.gray.opacity(0.3))
                        }
                    }
                    .padding()
                    .background(
                        selectedPrivacy == privacy ?
                        Color.blue.opacity(0.1) :
                        Color(.systemGray6)
                    )
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// Compact version for inline use
struct CompactPrivacyPicker: View {
    @Binding var selectedPrivacy: Privacy

    var body: some View {
        Menu {
            ForEach(Privacy.allCases, id: \.self) { privacy in
                Button(action: {
                    selectedPrivacy = privacy
                }) {
                    Label(privacy.displayName, systemImage: privacy.icon)
                }
            }
        } label: {
            HStack {
                Image(systemName: selectedPrivacy.icon)
                Text(selectedPrivacy.displayName)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(8)
        }
    }
}

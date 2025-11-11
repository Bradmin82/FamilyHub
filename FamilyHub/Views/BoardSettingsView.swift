import SwiftUI

struct BoardSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var kanbanViewModel: KanbanViewModel
    let board: KanbanBoard

    @State private var selectedPrivacy: Privacy
    @State private var shareURL: String?
    @State private var isGeneratingLink = false
    @State private var showingCopiedAlert = false
    @State private var showingShareSheet = false

    init(kanbanViewModel: KanbanViewModel, board: KanbanBoard) {
        self.kanbanViewModel = kanbanViewModel
        self.board = board
        _selectedPrivacy = State(initialValue: board.privacy)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Privacy")) {
                    Picker("Who can see this board?", selection: $selectedPrivacy) {
                        Text("Private").tag(Privacy.private)
                        Text("Family").tag(Privacy.family)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedPrivacy) { oldValue, newValue in
                        if oldValue != newValue {
                            kanbanViewModel.updateBoardPrivacy(boardId: board.id, privacy: newValue)
                        }
                    }

                    if selectedPrivacy == .private {
                        Text("Only you can see this board")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        Text("All family members can see this board")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Section(header: Text("Share Publicly")) {
                    if let shareURL = shareURL {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your board is ready to share!")
                                .font(.headline)
                                .foregroundColor(.green)

                            HStack {
                                Text(shareURL)
                                    .font(.caption)
                                    .lineLimit(1)
                                    .foregroundColor(.blue)

                                Spacer()

                                Button(action: {
                                    UIPasteboard.general.string = shareURL
                                    showingCopiedAlert = true
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .foregroundColor(.blue)
                                }
                            }

                            Button(action: { showingShareSheet = true }) {
                                HStack {
                                    Spacer()
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share Link")
                                    Spacer()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Generate a public link to share this board on social media or with anyone outside your family.")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Button(action: generateShareLink) {
                                HStack {
                                    Spacer()
                                    if isGeneratingLink {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                    } else {
                                        Image(systemName: "link")
                                        Text("Generate Public Link")
                                    }
                                    Spacer()
                                }
                            }
                            .disabled(isGeneratingLink)
                        }
                    }
                }

                Section(header: Text("Board Information")) {
                    HStack {
                        Text("Board Name")
                        Spacer()
                        Text(board.name)
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Text("Created")
                        Spacer()
                        Text(board.createdDate, style: .date)
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Text("Columns")
                        Spacer()
                        Text("\(board.columns.count)")
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Text("Total Tasks")
                        Spacer()
                        Text("\(board.columns.reduce(0) { $0 + $1.tasks.count })")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Board Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Link Copied!", isPresented: $showingCopiedAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("The share link has been copied to your clipboard")
            }
            .sheet(isPresented: $showingShareSheet) {
                if let shareURL = shareURL {
                    ShareSheet(items: [shareURL])
                }
            }
            .onAppear {
                // Check if board already has a share token
                if board.shareToken != nil {
                    shareURL = "familyhub://board/\(board.shareToken!)"
                }
            }
        }
    }

    private func generateShareLink() {
        isGeneratingLink = true
        kanbanViewModel.generateShareLink(boardId: board.id) { url in
            DispatchQueue.main.async {
                isGeneratingLink = false
                shareURL = url
            }
        }
    }
}

// Share sheet for iOS
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

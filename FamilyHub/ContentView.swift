import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showFamilySetup = false

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .onAppear {
                        // Show family setup if user doesn't have a family
                        let hasFamilyId = authViewModel.currentUser?.familyId != nil
                        print("👤 User familyId: \(authViewModel.currentUser?.familyId ?? "nil"), showFamilySetup: \(!hasFamilyId)")
                        if !hasFamilyId {
                            showFamilySetup = true
                        }
                    }
                    .onChange(of: authViewModel.currentUser?.familyId) { oldValue, newValue in
                        print("🔄 FamilyId changed from \(oldValue ?? "nil") to \(newValue ?? "nil")")
                        if newValue != nil {
                            showFamilySetup = false
                        }
                    }
                    .sheet(isPresented: $showFamilySetup) {
                        FamilySetupView()
                    }
            } else {
                LoginView()
            }
        }
    }
}

struct MainTabView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        if horizontalSizeClass == .regular {
            // iPad layout with sidebar
            NavigationSplitView {
                List {
                    NavigationLink(destination: FeedView()) {
                        Label("Feed", systemImage: "house.fill")
                    }
                    NavigationLink(destination: KanbanBoardListView()) {
                        Label("Boards", systemImage: "square.grid.2x2.fill")
                    }
                    NavigationLink(destination: PhotoSharingView()) {
                        Label("Photos", systemImage: "photo.fill")
                    }
                    NavigationLink(destination: ProfileView()) {
                        Label("Profile", systemImage: "person.fill")
                    }
                }
                .navigationTitle("FamilyConnection")
            } detail: {
                FeedView()
            }
        } else {
            // iPhone layout with tabs
            TabView {
                NavigationStack {
                    FeedView()
                }
                .tabItem {
                    Label("Feed", systemImage: "house.fill")
                }

                NavigationStack {
                    KanbanBoardListView()
                }
                .tabItem {
                    Label("Boards", systemImage: "square.grid.2x2.fill")
                }

                NavigationStack {
                    PhotoSharingView()
                }
                .tabItem {
                    Label("Photos", systemImage: "photo.fill")
                }

                NavigationStack {
                    ProfileView()
                }
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
            }
        }
    }
}

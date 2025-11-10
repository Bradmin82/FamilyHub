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
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "house.fill")
                }

            KanbanBoardListView()
                .tabItem {
                    Label("Boards", systemImage: "square.grid.2x2.fill")
                }

            PhotoSharingView()
                .tabItem {
                    Label("Photos", systemImage: "photo.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

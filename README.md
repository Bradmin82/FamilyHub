# FamilyHub iOS App

A comprehensive iOS app for family and community management with authentication, photo sharing, kanban boards, and social features.

## Features

- User Authentication (Sign up, Login, Logout)
- User Profile Dashboard
- Community Feed / User Wall
- Photo Sharing and Gallery
- Community Kanban Boards for task management
- Push Notifications and Banner Notifications
- Real-time updates with Firebase

## Tech Stack

- SwiftUI for modern iOS development
- Firebase Authentication
- Firebase Firestore (database)
- Firebase Storage (photo storage)
- Firebase Cloud Messaging (notifications)
- iOS 16+

## Project Structure

```
FamilyHub/
├── FamilyHub/
│   ├── FamilyHubApp.swift          # Main app entry point
│   ├── ContentView.swift            # Main content view with tab navigation
│   ├── Models/
│   │   ├── User.swift               # User data model
│   │   ├── Post.swift               # Post and Comment models
│   │   └── KanbanBoard.swift        # Kanban board, column, and task models
│   ├── ViewModels/
│   │   ├── AuthViewModel.swift      # Authentication logic
│   │   ├── PostViewModel.swift      # Post management logic
│   │   └── KanbanViewModel.swift    # Kanban board logic
│   ├── Views/
│   │   ├── LoginView.swift          # Login and signup screen
│   │   ├── FeedView.swift           # Social feed
│   │   ├── CreatePostView.swift     # Create new posts
│   │   ├── CommentsView.swift       # Comments on posts
│   │   ├── ProfileView.swift        # User profile dashboard
│   │   ├── PhotoSharingView.swift   # Photo gallery
│   │   ├── KanbanBoardListView.swift      # List of boards
│   │   └── KanbanBoardDetailView.swift    # Board details with tasks
│   ├── Services/
│   │   └── NotificationService.swift # Push notification handling
│   ├── Assets.xcassets/             # App icons and images
│   ├── Info.plist                   # App permissions
│   └── GoogleService-Info.plist     # Firebase configuration (YOU MUST REPLACE THIS)
├── Package.swift                    # Swift Package Manager dependencies
├── setup.sh                         # Setup instructions script
└── README.md                        # This file
```

## Setup Instructions

### Step 1: Open in Xcode

**Option A: Create New Project**
1. Open Xcode
2. Select "Create a new Xcode project"
3. Choose "iOS" > "App" template
4. Project settings:
   - Product Name: `FamilyHub`
   - Organization Identifier: `com.familyhub`
   - Interface: `SwiftUI`
   - Language: `Swift`
5. Save location: Choose `/Users/clarashlaimon/Sites/iOS/FamilyHub`
6. When prompted about existing files, choose "Merge"

**Option B: Open Package (Recommended)**
1. Open Xcode
2. File > Open
3. Navigate to `/Users/clarashlaimon/Sites/iOS/FamilyHub`
4. Select the folder and click "Open"
5. Xcode will recognize the Package.swift file

### Step 2: Add Firebase Dependencies

1. In Xcode, go to File > Add Package Dependencies
2. Enter package URL: `https://github.com/firebase/firebase-ios-sdk.git`
3. Click "Add Package"
4. Select these products:
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseStorage
   - FirebaseMessaging
5. Click "Add Package"

### Step 3: Set Up Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select existing project
3. Follow the setup wizard
4. Once project is created, click "Add app" and choose iOS
5. Register app:
   - Bundle ID: `com.familyhub.app`
   - App nickname: `FamilyHub`
6. Download the `GoogleService-Info.plist` file
7. **IMPORTANT**: Replace the placeholder `GoogleService-Info.plist` in the project with your downloaded file
8. Drag and drop it into Xcode's FamilyHub folder (ensure "Copy items if needed" is checked)

### Step 4: Enable Firebase Services

In Firebase Console:

**Authentication:**
1. Go to "Authentication" in left sidebar
2. Click "Get started"
3. Select "Sign-in method" tab
4. Enable "Email/Password"
5. Click "Save"

**Firestore Database:**
1. Go to "Firestore Database" in left sidebar
2. Click "Create database"
3. Start in **test mode** (for development)
4. Choose a location closest to you
5. Click "Enable"

**Storage:**
1. Go to "Storage" in left sidebar
2. Click "Get started"
3. Start in **test mode** (for development)
4. Click "Done"

**Cloud Messaging:**
1. Go to "Cloud Messaging" in left sidebar
2. If needed, click "Get started"
3. Note: Push notifications require Apple Developer Program membership

### Step 5: Configure Xcode Project

1. In Xcode, select the FamilyHub project in the navigator
2. Select the FamilyHub target
3. Under "Signing & Capabilities":
   - Select your development team
   - Ensure bundle identifier is `com.familyhub.app`
4. Click "+ Capability" and add:
   - Push Notifications
   - Background Modes (check "Remote notifications")

### Step 6: Build and Run

1. Select a simulator (iPhone 14 Pro or newer recommended)
2. Click the Play button or press Cmd+R
3. The app should build and launch in the simulator

## Usage

### Creating an Account

1. Launch the app
2. Tap "Don't have an account? Sign Up"
3. Enter display name, email, and password
4. Tap "Sign Up"

### Main Features

**Feed Tab:**
- View all posts from family members
- Like and comment on posts
- Create new posts with text and photos

**Boards Tab:**
- View community kanban boards
- Create new boards for family projects
- Add tasks and move them between columns (To Do, In Progress, Done)

**Photos Tab:**
- Browse all shared photos in a grid layout
- Tap to view full size

**Profile Tab:**
- View your profile information
- See your posts and statistics
- Sign out

## Firebase Security Rules

For production, update your Firebase security rules:

**Firestore Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }

    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }

    match /kanbanBoards/{boardId} {
      allow read: if request.auth != null && request.auth.uid in resource.data.members;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.createdBy;
    }
  }
}
```

**Storage Rules:**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /posts/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

## Troubleshooting

**Build Errors:**
- Make sure all Firebase packages are properly added
- Clean build folder: Product > Clean Build Folder (Shift+Cmd+K)
- Ensure GoogleService-Info.plist is properly added to the project

**Firebase Connection Issues:**
- Verify GoogleService-Info.plist is the correct file from your project
- Check that bundle identifier matches Firebase console
- Ensure Firebase services are enabled in console

**Photo Picker Not Working:**
- Check Info.plist has `NSPhotoLibraryUsageDescription`
- Verify permissions in simulator: Settings > Privacy > Photos

## Development Notes

- Minimum iOS version: 16.0
- Built with Xcode 15+
- Uses Swift 5.9+
- SwiftUI lifecycle

## Next Steps

- Add profile editing functionality
- Implement image caching for better performance
- Add search functionality for posts and users
- Implement user following/friends system
- Add analytics for app usage
- Submit to App Store

## Support

For issues or questions, refer to:
- [Firebase iOS Documentation](https://firebase.google.com/docs/ios/setup)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)

---

Built with SwiftUI and Firebase

# FamilyHub - App Store Submission Guide

## Current Status: ✅ Ready for Submission

### What's Already Configured
- ✅ **App Icon**: 1024x1024 PNG configured in Assets.xcassets
- ✅ **Version**: 1.0 (Marketing Version)
- ✅ **Build Number**: 1 (Current Project Version)
- ✅ **Bundle ID**: com.FamilyHub
- ✅ **Development Team**: AK3UX4R84K (Brad Weldy)
- ✅ **Development Certificate**: Apple Development certificate installed
- ✅ **Privacy Descriptions**: NSUserNotificationsUsageDescription added to Info.plist
- ✅ **Google Sign-In**: Configured with URL schemes

---

## Step 1: Create App in App Store Connect

1. Go to https://appstoreconnect.apple.com
2. Sign in with your Apple ID (bweldy82@gmail.com)
3. Click **"My Apps"** → **"+"** → **"New App"**
4. Fill in the form:
   - **Platform**: iOS
   - **Name**: FamilyHub (or your preferred name)
   - **Primary Language**: English (U.S.)
   - **Bundle ID**: Select **com.FamilyHub** from dropdown
   - **SKU**: familyhub-2025 (can be any unique identifier)
   - **User Access**: Full Access
5. Click **"Create"**

---

## Step 2: Prepare App Store Assets

### Required Screenshots
You need screenshots for the following device sizes:
- **6.7" Display** (iPhone 17 Pro Max, 15 Pro Max, 14 Pro Max)
  - Size: 1290 x 2796 pixels
  - Required: 3-10 screenshots
- **6.5" Display** (iPhone 11 Pro Max, XS Max)
  - Size: 1242 x 2688 pixels
  - Required: 3-10 screenshots

#### How to Take Screenshots:
1. In Xcode, run the app on **iPhone 17 Pro Max** simulator
2. Navigate to key screens:
   - Login/Welcome screen
   - Feed view with posts
   - Kanban board view
   - Family management
   - Post creation with privacy settings
   - Board with tasks and drag-drop
3. Press **⌘+S** in the simulator to save screenshots
4. Screenshots save to Desktop
5. Repeat for **iPhone 11 Pro Max** simulator

### App Description
Write a compelling description (max 4000 characters). Example:

```
FamilyHub brings your family together with powerful organization and sharing tools.

KEY FEATURES:
• Family Feed - Share posts, photos, and updates with your family
• 5-Tier Privacy Controls - Share with immediate family, extended family, or keep private
• Kanban Boards - Organize family tasks, chores, and projects
• Rich Text Editor - Format task descriptions with markdown
• Google Sign-In - Quick and secure authentication
• Real-time Updates - Stay connected with instant notifications

PERFECT FOR:
• Coordinating family activities and events
• Managing household chores and responsibilities
• Sharing family photos and memories
• Organizing family projects
• Staying connected with extended family

FamilyHub makes family organization simple and enjoyable!
```

### Keywords
Choose up to 100 characters of comma-separated keywords:
```
family,organize,tasks,boards,kanban,collaboration,sharing,photos,posts,family tree,chores,household
```

### App Category
- **Primary Category**: Productivity
- **Secondary Category**: Lifestyle (optional)

### Privacy Policy URL
If you collect user data (you do - email, photos, posts), you need a privacy policy.

**Quick Option**: Use a privacy policy generator:
- https://www.privacypolicies.com/
- https://app-privacy-policy-generator.firebaseapp.com/

**What to Include**:
- Data collected: Email, name, family information, photos, posts
- How it's used: Authentication, family sharing
- Third-party services: Firebase, Google Sign-In
- Data storage: Firebase Firestore and Storage
- User rights: Access, deletion, modification

Host the privacy policy on:
- GitHub Pages (free)
- Firebase Hosting (free)
- Your own website

### Support URL
You'll need a support URL (can be same as privacy policy or a GitHub issues page):
```
https://github.com/yourusername/FamilyHub/issues
```

---

## Step 3: Archive the App in Xcode

### Before Archiving:
1. **Open Xcode**:
   ```bash
   open FamilyHub.xcodeproj
   ```

2. **Select Device Destination**:
   - In the toolbar, select **"Any iOS Device (arm64)"**
   - Do NOT use a simulator

3. **Verify Signing**:
   - Click project name in navigator → Select FamilyHub target
   - Go to **"Signing & Capabilities"** tab
   - Ensure:
     - ☑ Automatically manage signing
     - Team: Your Apple Developer team
     - Signing Certificate: Apple Distribution (will be created automatically)

### Archive Steps:
1. In Xcode menu: **Product → Archive**
2. Wait for build to complete (may take 2-5 minutes)
3. Xcode Organizer window will open automatically
4. You should see your archive listed

**If Archive Fails**:
- Check for build errors in the issue navigator
- Ensure all code signing is correct
- Make sure you selected "Any iOS Device" not a simulator

---

## Step 4: Upload to App Store Connect

1. In Xcode Organizer (appears after successful archive):
2. Select your archive
3. Click **"Distribute App"**
4. Select **"App Store Connect"**
5. Click **"Upload"**
6. Select distribution options:
   - ☑ Upload your app's symbols (recommended)
   - ☑ Manage Version and Build Number (Xcode will auto-increment)
7. Review signing certificates (Xcode handles this)
8. Click **"Upload"**
9. Wait for upload to complete (may take 5-10 minutes)

### After Upload:
- You'll receive an email from Apple when processing completes
- Processing typically takes 10-30 minutes
- Check App Store Connect for the build to appear

---

## Step 5: Complete App Store Listing

1. Go back to **App Store Connect** → **My Apps** → **FamilyHub**
2. Fill in all required metadata:
   - **App Name**: FamilyHub
   - **Subtitle**: Organize and share with family (max 30 characters)
   - **Description**: (use the description from Step 2)
   - **Keywords**: (use keywords from Step 2)
   - **Support URL**: Your support URL
   - **Marketing URL**: (optional)
   - **Promotional Text**: (optional, 170 characters)

3. **App Privacy**:
   - Click **"App Privacy"** in sidebar
   - Answer questions about data collection
   - Link your privacy policy

4. **Screenshots**:
   - Upload screenshots for each device size
   - Add captions if desired

5. **Build**:
   - Under **"Build"** section, click **"+ "**
   - Select the build you uploaded
   - Click **"Done"**

6. **Age Rating**:
   - Click **"Edit"** next to Age Rating
   - Answer the questionnaire (likely 4+ for FamilyHub)

7. **App Review Information**:
   - Contact information (your email and phone)
   - Demo account (if login required)
     - Create a test family account for Apple reviewers
     - Username/email and password
   - Notes: Add any testing instructions

8. **Version Release**:
   - Choose automatic or manual release after approval

---

## Step 6: Submit for Review

1. Review all information is complete
2. Click **"Add for Review"** (or "Submit for Review")
3. Answer export compliance questions:
   - Does your app use encryption? **YES**
   - Does it use standard encryption from iOS? **YES** (HTTPS)
   - You may be exempt from export documentation
4. Click **"Submit"**

### Review Timeline:
- **Status**: "Waiting for Review"
- **Typical review time**: 24-48 hours
- **You'll receive emails** about status changes

### Possible Review Outcomes:
- ✅ **Approved**: App goes live (automatic) or ready for manual release
- ⚠️ **Metadata Rejected**: Fix description/screenshots, resubmit (no new build needed)
- ❌ **Rejected**: Address issues, upload new build if needed, resubmit

---

## Common Review Rejection Reasons (and How to Avoid)

1. **Missing Demo Account**: Always provide test credentials
2. **Crashes**: Test thoroughly before submitting
3. **Missing Privacy Policy**: Required if you collect any user data
4. **Incomplete Features**: Don't submit placeholder features
5. **Misleading Description**: Ensure description matches actual features
6. **Google Sign-In**: Ensure "Sign in with Apple" is offered if using third-party sign-in
   - ⚠️ **ACTION NEEDED**: You may need to add "Sign in with Apple" alongside Google Sign-In

---

## Post-Approval Checklist

After your app is approved:
- [ ] Verify app appears in App Store
- [ ] Test downloading and installing from App Store
- [ ] Monitor crash reports in App Store Connect
- [ ] Respond to user reviews
- [ ] Plan for future updates (bug fixes, new features)

---

## Quick Command Reference

```bash
# Open project in Xcode
open FamilyHub.xcodeproj

# Check code signing identities
security find-identity -v -p codesigning

# View project settings
xcodebuild -project FamilyHub.xcodeproj -showBuildSettings | grep -i "bundle\|version\|team"
```

---

## Need Help?

- **App Store Connect**: https://appstoreconnect.apple.com
- **Apple Developer**: https://developer.apple.com
- **Review Guidelines**: https://developer.apple.com/app-store/review/guidelines/
- **Common Rejection Reasons**: https://developer.apple.com/app-store/review/#common-app-rejections

---

## Important Notes

1. **Sign in with Apple Requirement**:
   - If your app uses Google Sign-In as a login method, Apple requires you to also offer "Sign in with Apple" as an option
   - This is a common rejection reason
   - Consider adding Sign in with Apple support before submitting

2. **Privacy Policy Required**:
   - Since FamilyHub collects email, names, photos, and posts, a privacy policy is mandatory
   - Must be hosted at a publicly accessible URL

3. **Test Account**:
   - Create a demo family account with sample data
   - Provide clear instructions for reviewers
   - Ensure it doesn't require special access or setup

4. **Export Compliance**:
   - Since you use HTTPS (standard iOS encryption), you're likely exempt
   - Answer questions honestly about encryption use

---

**Last Updated**: November 10, 2025
**App Version**: 1.0 (Build 1)
**Bundle ID**: com.FamilyHub

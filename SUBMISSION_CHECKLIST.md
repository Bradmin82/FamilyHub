# FamilyHub App Store Submission Checklist

Use this checklist to ensure you have everything ready before submitting to the App Store.

---

## ✅ Pre-Submission Checklist

### Code and Build

- [x] App builds successfully without errors
- [x] All features implemented and working
- [x] Code committed to git
- [x] Sign in with Apple code implemented
- [ ] Sign in with Apple capability added in Xcode (can be done later)
- [x] Privacy descriptions in Info.plist
- [x] App icon (1024x1024) configured
- [x] Bundle ID: com.FamilyHub
- [x] Version: 1.0, Build: 1

### Required Assets

- [ ] **Privacy Policy** - Hosted at public URL
  - File created: ✅ PRIVACY_POLICY.md
  - Hosting: Choose GitHub Pages, Firebase, or other
  - URL obtained: _________________

- [ ] **Screenshots** - 6.7" display (required)
  - Total needed: 5-8 screenshots
  - [ ] Screenshot 1: Login/Welcome
  - [ ] Screenshot 2: Feed View
  - [ ] Screenshot 3: Create Post
  - [ ] Screenshot 4: Board Detail
  - [ ] Screenshot 5: Board Settings

- [ ] **Screenshots** - 6.5" display (required)
  - Same 5-8 screenshots on different device

- [ ] **Support URL** (optional but recommended)
  - Can be same as Privacy Policy URL
  - Or GitHub issues page: https://github.com/USERNAME/FamilyHub/issues

### App Information

- [ ] **App Name**: FamilyHub (or your choice)
- [ ] **Subtitle**: (30 characters max)
  - Suggestion: "Organize and share with family"

- [ ] **Description** (up to 4000 characters):
  ```
  FamilyHub brings your family together with powerful
  organization and sharing tools.

  KEY FEATURES:
  • Family Feed - Share posts, photos, and updates
  • 5-Tier Privacy Controls - Control who sees what
  • Kanban Boards - Organize tasks and projects
  • Rich Text Editor - Format task descriptions
  • Google Sign-In - Quick and secure authentication
  • Real-time Updates - Stay connected instantly

  PERFECT FOR:
  • Coordinating family activities
  • Managing household chores
  • Sharing family photos
  • Organizing projects
  • Staying connected with family

  FamilyHub makes family organization simple!
  ```

- [ ] **Keywords** (100 characters max, comma-separated):
  ```
  family,organize,tasks,boards,kanban,sharing,photos,posts,chores,household,collaboration
  ```

- [ ] **Category**:
  - Primary: Productivity
  - Secondary: Lifestyle (optional)

### App Review Information

- [ ] **Demo Account** for Apple reviewers:
  - Create a test account with sample data
  - Email/Username: _________________
  - Password: _________________

- [ ] **Contact Information**:
  - First Name: Brad
  - Last Name: Weldy
  - Phone: _________________
  - Email: bweldy82@gmail.com

- [ ] **Notes for Reviewer**:
  ```
  FamilyHub is a family organization and sharing app.

  Test Account:
  - Use the provided demo account to sign in
  - The account has sample family posts and boards
  - You can create posts, boards, and tasks

  Key Features to Test:
  1. Sign in with the demo account
  2. View the family feed with posts
  3. Create a new post with privacy settings
  4. View and interact with Kanban boards
  5. Create tasks with rich text formatting

  Note: Sign in with Apple and Google Sign-In are
  available but the demo account uses email/password.

  Thank you for reviewing FamilyHub!
  ```

### Age Rating

- [ ] Complete the Age Rating questionnaire
  - Expected rating: **4+** (suitable for all ages)
  - Questions about:
    - Violence: None
    - Sexual content: None
    - Profanity: None
    - Gambling: None
    - Contests: No
    - Unrestricted web access: No
    - User-generated content: Yes (family posts/photos)

### App Privacy

- [ ] Complete App Privacy questions:
  - **Do you collect data from this app?** Yes

  - **Data Types Collected**:
    - ☑ Contact Info (Email, Name)
    - ☑ User Content (Photos, Posts, Messages)
    - ☑ Identifiers (User ID)

  - **Data Use**:
    - ☑ App Functionality
    - ☑ Product Personalization

  - **Data Linked to User**: Yes
  - **Data Used to Track User**: No
  - **Privacy Policy URL**: [Your URL]

---

## 📱 App Store Connect Setup

### Step 1: Create App

1. Go to https://appstoreconnect.apple.com
2. Sign in with bweldy82@gmail.com
3. Click "My Apps" → "+" → "New App"
4. Fill in:
   - Platform: iOS
   - Name: FamilyHub
   - Primary Language: English (U.S.)
   - Bundle ID: com.FamilyHub
   - SKU: familyhub-2025 (unique identifier)
   - User Access: Full Access
5. Click "Create"

### Step 2: Complete App Information

In App Store Connect → Your App:

1. **App Information** (left sidebar):
   - [ ] Add Privacy Policy URL
   - [ ] Add Support URL (optional)
   - [ ] Select Category (Productivity)
   - [ ] Select Secondary Category (Lifestyle - optional)
   - [ ] Add Subtitle
   - [ ] Complete App Privacy section

2. **Pricing and Availability**:
   - [ ] Price: Free
   - [ ] Availability: All countries (or select specific countries)
   - [ ] Pre-order: No

3. **App Privacy**:
   - [ ] Click "Get Started"
   - [ ] Answer all privacy questions
   - [ ] Link privacy policy
   - [ ] Publish privacy responses

### Step 3: Prepare for Submission

In "App Store" tab (1.0 Prepare for Submission):

1. **Screenshots**:
   - [ ] Upload 5-8 screenshots for 6.7" display
   - [ ] Upload 5-8 screenshots for 6.5" display
   - [ ] Add captions (optional, 170 chars each)
   - [ ] Order them (drag to reorder)

2. **Promotional Text** (optional, 170 characters):
   ```
   Organize your family life with posts, boards, and tasks.
   5-tier privacy controls keep your family content secure.
   ```

3. **Description**:
   - [ ] Paste your app description (see above)

4. **Keywords**:
   - [ ] Enter keywords (see above)

5. **Support URL**:
   - [ ] Add URL

6. **Marketing URL** (optional):
   - [ ] Add URL if you have a website

7. **Version**:
   - [ ] What's New in This Version:
   ```
   Welcome to FamilyHub 1.0!

   • Share posts and photos with your family
   • Organize tasks with Kanban boards
   • Control privacy with 5-tier settings
   • Format tasks with rich text editor
   • Sign in with Apple or Google
   • Real-time updates and notifications
   ```

8. **Build**:
   - [ ] Click "+" to add build
   - [ ] Select your uploaded build
   - [ ] Answer Export Compliance questions:
     - Uses encryption? Yes
     - Uses standard iOS encryption? Yes
     - Exempt from export documentation

9. **General App Information**:
   - [ ] App Icon: (should auto-populate from build)
   - [ ] Age Rating: Click "Edit" and complete questionnaire
   - [ ] Copyright: 2025 Brad Weldy (or your name)

10. **App Review Information**:
    - [ ] Add contact info (name, phone, email)
    - [ ] Add demo account credentials
    - [ ] Add notes for reviewer (see template above)

11. **Version Release**:
    - [ ] Automatic release after approval (recommended)
    - Or: Manual release

---

## 🏗️ Building and Uploading

### Archive the App

1. **Open Xcode**:
   ```bash
   open FamilyHub.xcodeproj
   ```

2. **Select "Any iOS Device (arm64)"**:
   - Click device selector in toolbar
   - Choose "Any iOS Device (arm64)"
   - Do NOT use a simulator

3. **Verify Signing**:
   - Project → Target → Signing & Capabilities
   - ☑ Automatically manage signing
   - Team selected
   - No errors shown

4. **Archive**:
   - Menu: Product → Archive
   - Wait 2-5 minutes for build
   - Xcode Organizer opens automatically

5. **Distribute**:
   - Select your archive
   - Click "Distribute App"
   - Select "App Store Connect"
   - Click "Upload"
   - Select options:
     - ☑ Upload your app's symbols
     - ☑ Manage Version and Build Number
   - Click "Next"
   - Review and click "Upload"

6. **Wait for Processing**:
   - Email notification when ready (10-30 minutes)
   - Check App Store Connect for build to appear

---

## 🚀 Final Submission

After build appears in App Store Connect:

1. **Select Build**:
   - Go to "1.0 Prepare for Submission"
   - Under "Build" section, click "+"
   - Select your uploaded build
   - Click "Done"

2. **Review Everything**:
   - [ ] All required fields filled
   - [ ] Screenshots uploaded
   - [ ] Privacy policy URL working
   - [ ] Demo account credentials correct
   - [ ] Description and keywords finalized

3. **Submit for Review**:
   - Click "Add for Review" (or "Submit for Review")
   - Review App Store Guidelines acknowledgment
   - Check "Yes" for Export Compliance exemption (standard encryption only)
   - Click "Submit"

4. **Status Changes**:
   - **Waiting for Review**: Submitted, in queue
   - **In Review**: Apple is testing your app (1-2 days)
   - **Pending Developer Release**: Approved! (if manual release)
   - **Ready for Sale**: Live on App Store!

---

## ⚠️ Common Rejection Reasons to Avoid

- [ ] **Missing Demo Account**: Always provide test credentials ✅
- [ ] **App Crashes**: Test thoroughly before submitting ✅
- [ ] **Missing Privacy Policy**: URL must be publicly accessible
- [ ] **Incomplete Features**: Don't submit placeholder features ✅
- [ ] **Misleading Description**: Ensure description matches features ✅
- [ ] **Missing Sign in with Apple**: Required when using Google Sign-In
  - Code implemented ✅
  - Capability to be added before submission

---

## 📊 Timeline Estimates

| Task | Time Required |
|------|---------------|
| Host privacy policy | 10-30 minutes |
| Take screenshots | 40-70 minutes |
| Create demo account | 10 minutes |
| Fill in App Store Connect | 30-45 minutes |
| Archive and upload | 30-45 minutes |
| **Total** | **2-3 hours** |

Add 1-2 days for Apple's review process.

---

## 🎯 Quick Start: Minimum Required Steps

If you want to submit ASAP, focus on:

1. ✅ Host privacy policy (30 min)
2. ✅ Take 5 screenshots for 6.7" display (30 min)
3. ✅ Take 5 screenshots for 6.5" display (15 min)
4. ✅ Create demo account with sample data (10 min)
5. ✅ Create app in App Store Connect (10 min)
6. ✅ Fill in all required fields (30 min)
7. ✅ Archive and upload build (30 min)
8. ✅ Submit for review (5 min)

**Minimum time**: ~2.5 hours

---

## 📞 Help Resources

- **App Store Connect**: https://appstoreconnect.apple.com
- **Review Guidelines**: https://developer.apple.com/app-store/review/guidelines/
- **Support**: https://developer.apple.com/contact/
- **Common Rejections**: https://developer.apple.com/app-store/review/#common-app-rejections

---

## 📝 Notes

- Save demo account credentials securely
- Keep privacy policy URL accessible
- Screenshots can be updated without new build
- You can update description/keywords anytime

---

**Ready to submit?** Go through this checklist step by step!

**Questions?** Refer to APP_STORE_SUBMISSION_GUIDE.md for detailed instructions.

---

**Last Updated**: November 10, 2025
**App Version**: 1.0 (Build 1)
**Bundle ID**: com.FamilyHub

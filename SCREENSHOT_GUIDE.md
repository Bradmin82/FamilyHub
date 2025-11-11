# App Store Screenshot Guide for FamilyHub

## Requirements

Apple requires screenshots for these device sizes:

### Required:
- **6.7" Display** (iPhone 17 Pro Max, 15 Pro Max, 14 Pro Max)
  - Resolution: **1290 x 2796 pixels**
  - Minimum: 3 screenshots
  - Maximum: 10 screenshots

- **6.5" Display** (iPhone 11 Pro Max, XS Max)
  - Resolution: **1242 x 2688 pixels**
  - Minimum: 3 screenshots
  - Maximum: 10 screenshots

### Optional (but recommended):
- 6.1" Display (iPhone 14 Pro, 13 Pro)
- 5.5" Display (iPhone 8 Plus) - for older users

**Note**: If you provide screenshots for 6.7", Apple will scale them for other sizes. Start with just 6.7" if short on time.

---

## Recommended Screenshots to Take (5-8 total)

### 1. Login/Welcome Screen ⭐
**Shows**: First impression, Sign in with Apple + Google options
**Why**: Demonstrates ease of getting started

### 2. Feed View with Posts ⭐
**Shows**: Family feed with posts, photos, privacy icons
**Why**: Core feature - family sharing

### 3. Create Post with Privacy Picker ⭐
**Shows**: Creating a post with 5-tier privacy controls
**Why**: Unique selling point - privacy features

### 4. Kanban Board Detail View ⭐
**Shows**: Board with columns, tasks, drag-and-drop interface
**Why**: Core feature - task organization

### 5. Board Settings with Privacy
**Shows**: Board settings, share link, privacy controls
**Why**: Collaboration features

### 6. Rich Text Editor in Task
**Shows**: Task with formatting toolbar, markdown
**Why**: Advanced features

### 7. Family Management
**Shows**: Family hierarchy, related families
**Why**: Shows family connection features

### 8. Profile/Settings
**Shows**: Profile view with settings, default privacy
**Why**: User control and customization

---

## How to Take Screenshots in Xcode

### Setup (One-time):

1. **Open Xcode**:
   ```bash
   open FamilyHub.xcodeproj
   ```

2. **Select the right simulator**:
   - Click on the device selector in toolbar
   - Choose: **iPhone 17 Pro Max** (for 6.7" screenshots)

3. **Run the app**:
   - Press ⌘+R or click the Play button
   - Wait for simulator to launch and app to load

### Taking Screenshots:

1. **Sign in or create test account**:
   - Use a test email account
   - Add some sample content (posts, boards, tasks)

2. **Navigate to each screen**:
   - Go to the screen you want to capture
   - Make sure it looks good (no empty states if possible)

3. **Capture screenshot**:
   - Press **⌘+S** in the Simulator
   - OR: File → Save Screen
   - Screenshot saves to **Desktop**

4. **Repeat for each of the 5-8 screens**

5. **Repeat for second device size**:
   - Switch simulator to **iPhone 11 Pro Max**
   - Take the same screenshots again

### Screenshot Tips:

- **Use realistic data**: Don't use "Test 1", "Test 2" - use realistic family content
- **Show functionality**: Make sure key features are visible
- **Good timing**: Capture when UI looks polished (no loading states)
- **Status bar**: Clean status bar looks more professional
  - Full battery, good signal, 9:41 AM (Apple's default time)
  - Simulator usually has these by default

---

## Creating Sample Data for Screenshots

Before taking screenshots, add some test content:

### Sample Posts:
```
"Pizza night tonight! 🍕 Who's in?"
- With a photo

"Doctor's appointment for Mom - Tuesday 3pm"
- Privacy: Family only

"Beach trip this weekend! 🏖️"
- With a family photo
```

### Sample Board: "Household Chores"
```
Columns: To Do | In Progress | Done

Tasks:
To Do:
- Clean garage
- Grocery shopping
- Pay bills

In Progress:
- Mow lawn
- Do laundry

Done:
- Wash dishes
- Vacuum living room
```

### Sample Board: "Thanksgiving Dinner"
```
Columns: Need to Buy | Prep | Cooking | Done

Tasks:
- Turkey (Need to Buy)
- Cranberry sauce (Prep)
- Mashed potatoes (Cooking)
- Rolls (Done)
```

This makes the app look functional and useful!

---

## Screenshot Locations

After taking screenshots, they'll be on your **Desktop** with names like:
```
Simulator Screen Shot - iPhone 17 Pro Max - 2025-11-10 at 19.30.45.png
```

### Organize them:
```bash
mkdir ~/Desktop/FamilyHub-Screenshots
mkdir ~/Desktop/FamilyHub-Screenshots/6.7-inch
mkdir ~/Desktop/FamilyHub-Screenshots/6.5-inch

# Move screenshots to appropriate folders
mv ~/Desktop/Simulator\ Screen\ Shot*.png ~/Desktop/FamilyHub-Screenshots/6.7-inch/
```

### Rename for clarity:
```
01-login.png
02-feed.png
03-create-post.png
04-board-detail.png
05-board-settings.png
```

---

## Optional: Add Text Overlays

You can add text overlays to make screenshots more appealing:

### Free Tools:
- **Figma** (free) - https://figma.com
- **Canva** (free) - https://canva.com
- **Apple Keynote** (free on Mac)
- **Preview** (built into Mac)

### Example Text Overlays:
- "Share with your family" (on feed screen)
- "Organize together" (on board screen)
- "Your privacy, your control" (on privacy picker)

**Note**: This is optional! Plain screenshots work fine.

---

## Screenshot Order in App Store

The order matters - first screenshot is most important:

### Recommended Order:
1. **Feed View** - Shows the main feature immediately
2. **Board Detail** - Shows organization capabilities
3. **Create Post** - Shows how easy it is to share
4. **Privacy Controls** - Shows unique privacy features
5. **Rich Text Editor** - Shows advanced features

First 2-3 screenshots are most important - most users only see these!

---

## Quick Checklist

Before taking screenshots:

- [ ] App builds and runs successfully
- [ ] Simulator is set to correct device (iPhone 17 Pro Max)
- [ ] Test account created with sample data
- [ ] Sample posts created (3-5 posts with photos)
- [ ] Sample board created (Household Chores or similar)
- [ ] Sample tasks added to board
- [ ] Status bar looks clean (9:41 AM, full battery)
- [ ] No error messages or empty states visible

During screenshot capture:

- [ ] Navigate to each key screen
- [ ] Press ⌘+S to save screenshot
- [ ] Check screenshot saved to Desktop
- [ ] Verify screenshot looks good (no cutoff text, clear visuals)

After screenshots:

- [ ] 5-8 screenshots taken for 6.7" display
- [ ] 5-8 screenshots taken for 6.5" display (same screens)
- [ ] Screenshots organized in folders
- [ ] Screenshots renamed with clear names
- [ ] Ready to upload to App Store Connect

---

## Alternative: Use App Store Screenshots Template

There are free templates available:

- **Apple's Screenshot Templates**: https://developer.apple.com/app-store/marketing/guidelines/
- **Figma Templates**: Search for "App Store screenshot template"
- **MockUPhone**: https://mockuphone.com/ (generates device frames)

These let you drop your screenshots into professional device frames.

---

## App Store Connect Upload

When you're ready to upload:

1. Go to App Store Connect → Your App → iOS App → Screenshots
2. Drag and drop screenshots for each device size
3. Add optional captions (up to 170 characters each)
4. Order them by dragging

---

## Time Estimate

- **Creating sample data**: 10 minutes
- **Taking screenshots (6.7")**: 15 minutes
- **Taking screenshots (6.5")**: 10 minutes
- **Organizing/renaming**: 5 minutes
- **Optional text overlays**: 30 minutes

**Total**: 40-70 minutes

---

## Pro Tips

1. **Light mode vs Dark mode**: Take screenshots in Light mode (more familiar to users)
2. **Portrait only**: FamilyHub is portrait-only, so no landscape needed
3. **Real content**: Better to show realistic family content than "Lorem ipsum"
4. **Consistency**: Use the same test account across all screenshots
5. **No personal info**: Don't use real family member names or photos in screenshots

---

## Need Help?

If you need me to:
- Walk through taking specific screenshots
- Help create better sample data
- Suggest different screenshot compositions

Just let me know!

---

**Next**: After screenshots are ready, complete your App Store Connect listing!

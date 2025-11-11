# Xcode Setup and Provisioning Profile Fix

## Issue: Provisioning Profile Errors

You're seeing:
- "Communication with Apple failed"
- "No profiles for 'com.FamilyHub' were found"
- "Sign in with Apple" capability not showing up

This means the App ID hasn't been registered in your Apple Developer account yet.

---

## Fix: Register Bundle ID in Apple Developer Portal

### Step 1: Verify Apple ID in Xcode

1. Open Xcode
2. Go to **Xcode** menu → **Settings** (or **Preferences** on older versions)
3. Click **Accounts** tab
4. Check if your Apple ID (bweldy82@gmail.com) is listed
5. If YES: Click on it and verify "Team: AK3UX4R84K" is shown
6. If NO: Click **"+"** → **Add Apple ID** → Sign in with bweldy82@gmail.com

**Important**: Make sure you see:
```
Apple ID: bweldy82@gmail.com
Team: [Your Name] (AK3UX4R84K)
Role: Agent or Admin
```

---

### Step 2: Register Bundle ID in Apple Developer Portal

**Option A: Automatic (Recommended - Let Xcode do it)**

1. In Xcode, open **FamilyHub.xcodeproj**
2. Click on **FamilyHub** project (blue icon) in navigator
3. Select **FamilyHub** target
4. Go to **Signing & Capabilities** tab
5. Make sure:
   - ☑ **Automatically manage signing** is CHECKED
   - **Team**: Select your team (AK3UX4R84K)
   - **Bundle Identifier**: com.FamilyHub
6. Xcode will show a warning or error initially
7. Click **"Try Again"** or wait a few seconds
8. Xcode will automatically:
   - Register the bundle ID with Apple
   - Create provisioning profiles
   - Download certificates

**If it works**: You'll see "FamilyHub.app signed with Apple Development" ✅

**If it still fails**: Use Option B below

---

**Option B: Manual Registration in Developer Portal**

If automatic signing fails, register the bundle ID manually:

1. Go to https://developer.apple.com/account
2. Sign in with bweldy82@gmail.com
3. Click **Certificates, Identifiers & Profiles**
4. Click **Identifiers** in the left sidebar
5. Click the **"+"** button to add a new identifier
6. Select **App IDs** → Click **Continue**
7. Select **App** → Click **Continue**
8. Fill in the form:
   - **Description**: FamilyHub
   - **Bundle ID**: Select "Explicit"
   - **Bundle ID**: com.FamilyHub
   - Scroll down to **Capabilities**
   - Check these boxes:
     - ☑ **Sign in with Apple**
     - ☑ **Push Notifications** (if needed)
9. Click **Continue**
10. Review and click **Register**

Now go back to Xcode and try Step 1 (Option A) again.

---

### Step 3: Add Sign in with Apple Capability

After provisioning profiles are working:

1. In Xcode: **FamilyHub** project → **FamilyHub** target → **Signing & Capabilities**
2. Click **"+ Capability"** button
3. In the search box, type: **apple**
4. You should see **"Sign in with Apple"** in the list
5. Double-click it to add

**If you still don't see it**:
- Make sure the bundle ID is registered (Step 2)
- Try quitting and reopening Xcode
- Make sure automatic signing is enabled

---

## Common Issues and Solutions

### Issue 1: "No matching provisioning profiles found"
**Solution**:
- Xcode Settings → Accounts → Select your Apple ID → Click "Download Manual Profiles"
- Or: Use Option B above to manually register the bundle ID

### Issue 2: "Communication with Apple failed"
**Solution**:
- Check internet connection
- Sign out and sign back in: Xcode Settings → Accounts → Select Apple ID → Click "-" → Re-add it
- Sometimes Apple's servers are slow - wait 5 minutes and try again

### Issue 3: "Team has no devices"
**Solution**: This is OK for now! You can still:
- Build for simulator (no device needed)
- Submit to App Store (no device needed)
- To test on device later: Just connect your iPhone and Xcode will register it automatically

### Issue 4: Still can't find "Sign in with Apple" capability
**Solution**:
- The bundle ID MUST be registered first
- Quit Xcode completely
- Open Xcode again
- Try adding the capability again

### Issue 5: "Invalid code signing entitlements"
**Solution**:
- This happens if you add the capability before registering the bundle ID
- Remove the capability (click the "X" next to it)
- Register bundle ID in developer portal (Step 2, Option B)
- Add capability again

---

## Alternative: Test Without Sign in with Apple Capability First

If you're having trouble, you can:

1. **Skip the capability for now**
2. Build and test locally (will work in simulator!)
3. The Sign in with Apple button will appear but won't work until:
   - Capability is added in Xcode
   - Bundle ID is registered
   - Firebase Apple provider is enabled

But the app will still build and run! You can add the capability later.

---

## Verification Checklist

After completing the steps, verify:

- [ ] Apple ID is signed in to Xcode (Xcode → Settings → Accounts)
- [ ] Bundle ID is registered at https://developer.apple.com/account
- [ ] "Sign in with Apple" is checked in the bundle ID capabilities
- [ ] Xcode shows "✓ FamilyHub.app signed" in Signing & Capabilities
- [ ] No red errors in Signing & Capabilities tab
- [ ] You can add the "Sign in with Apple" capability successfully

---

## Quick Test

To test if everything is working:

1. In Xcode, change the bundle identifier to something temporary:
   - Change from: `com.FamilyHub`
   - Change to: `com.FamilyHub.test`
2. See if Xcode can create profiles for the new ID
3. If YES: The issue is that `com.FamilyHub` needs to be registered
4. Change it back to `com.FamilyHub`
5. Register it properly using Step 2, Option B

---

## Need More Help?

If you're still stuck:

1. Take a screenshot of:
   - The Signing & Capabilities tab in Xcode
   - The error messages you're seeing

2. Check your Apple Developer account status:
   - Go to https://developer.apple.com/account
   - Make sure your membership is active
   - Verify you have the role of "Account Holder" or "Admin"

---

**Last Updated**: November 10, 2025

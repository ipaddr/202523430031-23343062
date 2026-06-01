/// iOS APP TO APP STORE CONNECT SUBMISSION GUIDE
/// ==============================================
///
/// Panduan lengkap submit iOS app ke App Store Connect

/*

════════════════════════════════════════════════════════════════════════════════
OVERVIEW - iOS APP SUBMISSION PROCESS
════════════════════════════════════════════════════════════════════════════════

iOS app submission consists of:

1. Preparation
   - Apple Developer Account ($99/year)
   - Certificates & Provisioning Profiles
   - App ID registration
   - Signing configuration

2. Build
   - Create release build
   - Archive app
   - Sign with certificates

3. Upload
   - TestFlight internal testing (optional)
   - Submit to App Store Connect
   - Fill app details & metadata

4. Review
   - Apple review process (1-3 days typical)
   - Address any rejection feedback
   - Resubmit if needed

5. Publish
   - Approve release
   - Monitor app performance


Duration: 2-4 weeks total (first submission usually longer)


════════════════════════════════════════════════════════════════════════════════
STEP 1 - APPLE DEVELOPER ACCOUNT & CERTIFICATES
════════════════════════════════════════════════════════════════════════════════

1.1 Create Apple Developer Account

Website: https://developer.apple.com/account/

Cost: $99 USD per year
Requirements:
  - Apple ID
  - Valid payment method
  - Accept agreements


1.2 Create signing certificates

Buka Apple Developer -> Certificates, Identifiers & Profiles

Create Certificate (iOS App Distribution):
  1. Go to Certificates
  2. Click "+" Create new certificate
  3. Choose "Apple Distribution"
  4. Follow guided process
  5. Download certificate (.cer file)
  6. Double-click to install (Keychain akan auto-import)

Verify:
  1. Open Keychain Access
  2. Search "Apple Distribution"
  3. Should see certificate + private key


1.3 Create App ID

Di Apple Developer -> Certificates, Identifiers & Profiles

Register App ID:
  1. Go to Identifiers
  2. Click "+" to register
  3. Choose "App IDs"
  4. Bundle ID format: com.yourcompany.appname
     Example: com.example.notesapp
  5. Select capabilities needed (push notifications, etc)
  6. Complete registration


Bundle ID rules:
  - Must be unique globally
  - Can't be changed after app published
  - Reverse domain format: com.company.appname
  - Use lowercase + dots only


1.4 Create provisioning profile

Di Apple Developer -> Certificates, Identifiers & Profiles

Create Provisioning Profile:
  1. Go to Profiles
  2. Click "+" Create new profile
  3. Choose "App Store Connect"
  4. Select App ID created above
  5. Select distribution certificate
  6. Give profile a name (e.g., "Notes App Production")
  7. Download profile (.mobileprovision file)
  8. Double-click to install (Xcode auto-imports)

Verify:
  1. In Xcode -> Preferences -> Accounts
  2. Select your Apple ID
  3. Click "Manage Certificates"
  4. Should see distribution profile


════════════════════════════════════════════════════════════════════════════════
STEP 2 - XCODE CONFIGURATION FOR RELEASE
════════════════════════════════════════════════════════════════════════════════

2.1 Open Xcode project

Command (di app1 directory):
  open ios/Runner.xcworkspace

NOT: .xcodeproj (buka workspace untuk pods)


2.2 Configure signing

Di Xcode:
  1. Select Runner project (left sidebar)
  2. Select Runner app (Targets)
  3. Tab: Signing & Capabilities
  4. Team: Select your Apple ID
  5. Bundle Identifier: com.example.notesapp
     (harus match App ID di Apple Developer)
  6. Ensure "Automatically manage signing" checked


2.3 Verify version & build number

Di Xcode:
  1. Select Runner app (Targets)
  2. Tab: General
  3. Version: e.g., "1.0.0" (user-facing)
  4. Build: e.g., "1" (internal build number)

Increment setiap submission!

Version format:
  - Version: MAJOR.MINOR.PATCH (1.0.0, 1.0.1, 1.1.0)
  - Build: Sequential number (1, 2, 3...)


2.4 Add app icon

Icon configuration important untuk iOS.

Di Xcode:
  1. Select Runner project
  2. Click Assets.xcassets
  3. Click AppIcon
  4. Drag app icon image ke required slots
  5. Xcode auto-resize ke correct dimensions


2.5 Configure app capabilities (jika perlu)

Di Xcode -> Signing & Capabilities tab:
  1. Click "+ Capability" button
  2. Search & add any needed (Push Notifications, iCloud, etc)

For Notes App: Umumnya tidak perlu capabilities tambahan
  (Firestore, Auth handled di Flutter level)


════════════════════════════════════════════════════════════════════════════════
STEP 3 - FLUTTER CONFIGURATION
════════════════════════════════════════════════════════════════════════════════

3.1 Update pubspec.yaml version

Di pubspec.yaml:

version: 1.0.0+1

Format:
  - Version BEFORE plus: User-facing (1.0.0)
  - Version AFTER plus: Internal build number (1)

Example progression:
  1.0.0+1  -> first release
  1.0.0+2  -> fix release
  1.0.1+3  -> minor update
  1.1.0+4  -> feature release


3.2 Verify platform config

Di ios/Podfile:

Uncomment/check:
  platform :ios, '11.0'  (atau higher)

iOS minimum version harus >= 11.0


3.3 Clean & build

Commands:
  flutter clean
  flutter pub get
  flutter pub global run flutter_launcher_icons
  flutter pub global run flutter_native_splash:create

Pastikan semua generate commands sudah run.


════════════════════════════════════════════════════════════════════════════════
STEP 4 - CREATE RELEASE BUILD / ARCHIVE
════════════════════════════════════════════════════════════════════════════════

4.1 Build Flutter for iOS

Command:
  flutter build ios --release

Output:
  - Xcode project compiled
  - Ready untuk archiving

Wait untuk completion (bisa 5-10 menit).


4.2 Archive di Xcode

Method 1: Command line

  xcodebuild -workspace ios/Runner.xcworkspace \
    -scheme Runner \
    -configuration Release \
    -archivePath build/ios/Runner.xcarchive \
    archive

Method 2: Xcode GUI

  1. Open Xcode
  2. Product menu -> Scheme -> Select "Runner"
  3. Product -> Destination -> Choose "Generic iOS Device"
     (bukan simulator!)
  4. Product -> Archive
  5. Wait untuk completion

Verify archive successful:
  - Window akan appear "Organizer"
  - Archive listed dengan date & version


4.3 Export for App Store

Di Xcode Organizer:
  1. Select archive
  2. Click "Distribute App"
  3. Choose "App Store Connect"
  4. Choose "Upload"
  5. Select team
  6. Configure options:
     - Strip Swift symbols: checked
     - Upload bitcode: checked
     - Manage version locally: unchecked
  7. Click "Next"
  8. Review distribution options
  9. Click "Upload"

Wait untuk upload completion (5-15 menit).

Monitor upload progress di "Xcode -> Window -> Organizer"


════════════════════════════════════════════════════════════════════════════════
STEP 5 - APP STORE CONNECT SETUP
════════════════════════════════════════════════════════════════════════════════

5.1 Create app di App Store Connect

Website: https://appstoreconnect.apple.com/

Login dengan Apple ID.

Create new app:
  1. Click "My Apps"
  2. Click "+" Create new app
  3. Choose "iOS" platform
  4. Fill form:
     - Name: "Notes App" (display name)
     - Primary Language: English
     - Bundle ID: Select from registered IDs
     - SKU: Unique identifier (e.g., notesapp001)
     - User access: Full Access or Limited


5.2 Fill app information

Di App Store Connect:

Tab: App Information
  - App Name
  - Subtitle
  - Category
  - Primary Category: Productivity
  - Secondary Category: (optional)
  - Small icon
  - Description


5.3 Fill app description

Tab: Description

Content needed:
  - Description: What app does (max 4000 chars)
  - Keywords: Comma-separated (e.g., notes, notepad, organizer)
  - Support URL: Your website atau contact
  - Privacy Policy URL: Must have for app store
  - Promotional text: Latest features (optional)


5.4 Add screenshots

Tab: Screenshots

Required:
  - iPhone 6.5" (Pro Max)
  - iPhone 5.5" atau 5.8" (regular)
  - iPad 7-inch (jika iPad supported)

Per device need min 2, max 10 screenshots.

Screenshot specs:
  - PNG or JPEG format
  - Actual resolution (no scaling)
  - Landscape atau portrait as needed
  - Include text describing features


5.5 Setup pricing & availability

Tab: Pricing and Availability

Required decisions:
  - Price: Free atau paid ($0.99 - $999.99)
  - For Free app: Still need to set
  - Availability: Select countries/regions
  - Release Date: Immediate atau scheduled


5.6 Setup app review information

Tab: Age Rating

Complete questionnaire:
  - Violence, scary content
  - Alcohol, tobacco, drugs
  - Gambling
  - Contest, promotion
  - etc

Based on answers, system assign age rating.


Tab: App Review Information

Provide:
  - Contact email
  - Contact phone
  - Demo account (jika needed for testing)
  - Notes for reviewer (optional)

Example note:
  "Notes app allows users to create, edit, delete notes using Firebase.
   App requires internet for cloud sync.
   Demo account not needed - all features accessible."

Notes important untuk reviewer understanding!


════════════════════════════════════════════════════════════════════════════════
STEP 6 - SUBMIT FOR APP STORE REVIEW
════════════════════════════════════════════════════════════════════════════════

6.1 Verify all required info complete

Checklist:
  □ App metadata filled
  □ Description complete
  □ Keywords added
  □ Screenshots uploaded (all required device sizes)
  □ Privacy policy provided
  □ Age rating completed
  □ Contact info provided
  □ Version notes added
  □ Build uploaded

Go through each tab to verify.


6.2 Add version notes

Tab: Version Information OR Build tab

Add notes:
  "Initial release of Notes application.
   Features: Create, edit, delete notes with cloud sync.
   Built with Flutter and Firebase."

Reviewer akan read untuk context.


6.3 Add build to version

Tab: Build

Click "+" to add build:
  1. Select build (recently uploaded)
  2. Review checkboxes:
     - Export Compliance: Usually No untuk consumer app
     - Advertising ID: No (unless using ads)
  3. Click "Done"


6.4 Submit for review

Click "Submit for Review" button

Confirm submission dialog appears.

Review checklist again:
  - All required fields complete
  - No missing info
  - Screenshots adequate
  - Metadata accurate


Confirm submission -> App sent to review queue!


════════════════════════════════════════════════════════════════════════════════
STEP 7 - APP STORE REVIEW PROCESS
════════════════════════════════════════════════════════════════════════════════

7.1 Review timeline

Typical iOS app store review:
  - Pending Review: 1-24 hours
  - In Review: 1-2 days
  - Decision: Approved, Rejected, Needs Info

Total: 1-3 days average (first submission can be 5-7 days)

Check status:
  App Store Connect -> Activity
  Watch for status updates


7.2 Common rejection reasons

Crashes/Performance:
  - App crashes on launch or during use
  - Excessive battery drain
  - Memory leaks
  Solution: Fix bugs, test thoroughly, resubmit

Metadata issues:
  - Incomplete description
  - Misleading screenshots
  - Claims not supported by app
  Solution: Update metadata, resubmit

Legal/Policy violations:
  - Missing privacy policy
  - Unlicensed content
  - Payments not through in-app purchase
  Solution: Address violation, resubmit

Design issues:
  - UI doesn't follow iOS guidelines
  - Buttons too small
  - Insufficient spacing
  Solution: Update UI, resubmit


7.3 If rejected

Action required:

  1. Read rejection reason carefully
  2. Understand specific issue
  3. Fix in code atau metadata
  4. Test fix thoroughly
  5. Bump version + build number
  6. Re-archive & upload
  7. Submit for review again


Note: Each resubmission starts review from beginning.


7.4 If approved

Status changes to "Approved"

Next action - schedule release or auto-release.


════════════════════════════════════════════════════════════════════════════════
STEP 8 - RELEASE TO APP STORE
════════════════════════════════════════════════════════════════════════════════

8.1 Release options

After approval, choose release method:

Option 1: Automatic Release
  - App available immediately after approval
  - Good for public releases

Option 2: Manual Release
  - App available only when you click "Release"
  - Good untuk controlled launch
  - Allows embargo coordination


8.2 Schedule release

Tab: General Information -> Version Release

Choose:
  - Automatic release after approval
  - Manual release (you click Release button)
  - Scheduled release (specific date/time)


8.3 Release app

If manual release:
  1. Wait untuk approval status
  2. Click "Release" button
  3. Confirm
  4. App appears di App Store within 1 hour


Status after release:
  "Available on the App Store"


════════════════════════════════════════════════════════════════════════════════
STEP 9 - POST-LAUNCH MONITORING
════════════════════════════════════════════════════════════════════════════════

9.1 Monitor app performance

App Store Connect -> Metrics

Track:
  - Sales & Revenue (jika paid)
  - Units sold
  - Downloads
  - Active devices
  - Crash rate
  - Rating & reviews


9.2 Monitor crashes

Tab: Crashes

Important:
  - Fix crash issues quickly
  - Respond to user feedback
  - Patch bugs

If high crash rate:
  1. Investigate crash logs
  2. Identify root cause
  3. Create fix
  4. Submit update


9.3 Respond to reviews

App Store Connect -> Ratings & Reviews

Strategy:
  - Monitor user reviews daily (first week)
  - Respond pro-aktif to critical feedback
  - Fix reported issues
  - Post fixes dalam app updates
  - Ask users to re-rate after fixes


9.4 Plan updates

Version roadmap:
  - 1.0.0 - initial release
  - 1.0.1 - bug fixes
  - 1.1.0 - new features
  - 2.0.0 - major overhaul


Common update schedule:
  - Bug fix: Weekly-bi-weekly
  - Features: 2-4 weeks
  - Major: Monthly or quarterly


════════════════════════════════════════════════════════════════════════════════
TROUBLESHOOTING
════════════════════════════════════════════════════════════════════════════════

Problem: "Invalid provisioning profile"

Solution:
  1. Open Xcode
  2. Select Runner project
  3. Signing & Capabilities tab
  4. Uncheck "Automatically manage signing"
  5. Select correct provisioning profile
  6. Check "Automatically manage signing" again
  7. Rebuild


Problem: "Certificate expired"

Solution:
  1. Go to Apple Developer
  2. Renew certificate
  3. Download new certificate
  4. Install to Keychain
  5. Update Xcode signing
  6. Rebuild


Problem: "Bundle ID mismatch"

Solution:
  1. Get your registered Bundle ID from Apple Developer
  2. In Xcode -> Runner App -> General
  3. Update Bundle Identifier to match exactly
  4. Rebuild


Problem: "Upload failed - Invalid binary"

Solution:
  1. Check Xcode version (must be current)
  2. Check build configuration (Release mode)
  3. Check signing certificate valid
  4. Clean build folder: Cmd+Shift+K
  5. Rebuild
  6. Re-archive


Problem: "App rejected - Crashes on launch"

Solution:
  1. Test app thoroughly on device
  2. Check crash logs in Console.app
  3. Fix bugs
  4. Increment build number
  5. Re-archive and upload
  6. Resubmit


Problem: "Waiting for review" takes too long

Note: Apple doesn't guarantee timeline.
Solution:
  1. Monitor App Store Connect daily
  2. Provide complete info (don't skip fields)
  3. Include helpful notes for reviewer
  4. Responding quickly to review messages helps


════════════════════════════════════════════════════════════════════════════════
CHECKLIST - iOS APP STORE SUBMISSION
════════════════════════════════════════════════════════════════════════════════

PREPARATION:
□ Apple Developer Account created ($99)
□ Distribution certificate created & installed
□ App ID registered (e.g., com.example.notesapp)
□ Provisioning profile created & installed
□ Bundle ID matches App ID exactly

XCODE CONFIGURATION:
□ Opened ios/Runner.xcworkspace (not xcodeproj)
□ Team selected in Signing & Capabilities
□ Bundle Identifier verified
□ Version updated (1.0.0)
□ Build number incremented (1)
□ App icon added to Assets.xcassets
□ Minimum iOS version set (11.0 or higher)

FLUTTER BUILD:
□ flutter clean executed
□ flutter pub get executed
□ flutter build ios --release completed
□ No build errors

ARCHIVE & UPLOAD:
□ Archive created (xcodebuild archive command)
□ Archive exported for App Store
□ Archive uploaded to App Store Connect
□ Upload completed successfully

APP STORE CONNECT:
□ App created on App Store Connect
□ Name & description filled
□ Keywords added (5-10 relevant keywords)
□ Category selected
□ Screenshots uploaded (all device sizes)
□ Privacy policy URL provided
□ Support URL provided
□ Age rating questionnaire completed
□ Pricing set (Free or Paid)
□ Availability countries selected
□ Build associated with version
□ Release notes added

SUBMISSION:
□ All metadata double-checked
□ Export Compliance addressed
□ Submit for Review clicked
□ Submission confirmed

POST-SUBMISSION:
□ Monitor review status daily
□ Respond to review requests quickly
□ Prepare for potential rejection handling
□ Have update ready if needed


════════════════════════════════════════════════════════════════════════════════
QUICK REFERENCE - KEY COMMANDS
════════════════════════════════════════════════════════════════════════════════

Flutter build release:
  flutter build ios --release

Open Xcode workspace:
  open ios/Runner.xcworkspace

Archive from command line:
  xcodebuild -workspace ios/Runner.xcworkspace \
    -scheme Runner \
    -configuration Release \
    -archivePath build/ios/Runner.xcarchive \
    archive

Check provisioning profiles:
  ls ~/Library/MobileDevice/Provisioning\ Profiles/

View certificates in Keychain:
  open /Applications/Utilities/Keychain\ Access.app

Verify app binary:
  xcrun altool --validate-app -f build.ipa -t ios \
    -u yourEmail@apple.com -p yourPassword


════════════════════════════════════════════════════════════════════════════════
IMPORTANT NOTES
════════════════════════════════════════════════════════════════════════════════

1. Bundle ID permanent
   - Can't be changed after first app store submission
   - Decide carefully
   - Must match App ID exactly

2. Version number sequential
   - Each submission must increment
   - Format: MAJOR.MINOR.PATCH
   - Build number always increases

3. Privacy policy required
   - Must meet App Store requirements
   - Be transparent about data collection
   - Include Firestore/Firebase data handling

4. Testing before submission
   - Test on real iOS device (not just simulator)
   - Check all functionality
   - Test offline mode
   - Monitor battery usage
   - Check memory leaks

5. Review guidelines
   - Familiarize with App Store Review Guidelines
   - Avoid common rejection reasons
   - Include helpful notes for reviewer

6. First submission slower
   - First app from account: 5-7 days typical
   - Subsequent updates: 1-3 days
   - Plan accordingly for release date

7. Communication channels
   - App Store Connect Messages: Check for review inquiries
   - Respond quickly to Apple's questions
   - Failure to respond = rejection

8. Rollout strategy
   - Consider beta testing via TestFlight first
   - Gradual rollout percentage (not all at once)
   - Monitor crash rates
   - Ready for quick hotfix if needed

*/

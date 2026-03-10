/// RELEASE CHECKLIST - QUICK START
/// ================================
///
/// Checklist singkat sebelum release ke production

/*

════════════════════════════════════════════════════════════════════════════════
PRE-RELEASE CHECKLIST (1-2 HARI SEBELUM RELEASE)
════════════════════════════════════════════════════════════════════════════════

CODE QUALITY:
  ☐ flutter clean
  ☐ flutter pub get
  ☐ flutter analyze (0 errors)
  ☐ No red squiggly lines di VS Code
  ☐ No console errors saat flutter run
  ☐ git status clean (semua committed)

FEATURE TESTING:
  ☐ Login works
  ☐ Register works
  ☐ Create note works
  ☐ Read notes list works
  ☐ Edit note works
  ☐ Delete note works
  ☐ Search works
  ☐ Logout works

UI/UX REVIEW:
  ☐ All dialogs display correctly
  ☐ All loading overlays appear
  ☐ Navigation smooth (no jank)
  ☐ Buttons responsive
  ☐ Forms validate properly
  ☐ Error messages clear & helpful

PERFORMANCE:
  ☐ App starts quickly (< 3 sec)
  ☐ Notes list loads fast (< 2 sec)
  ☐ No memory leaks (DevTools)
  ☐ 60 FPS stable (Performance overlay)

SECURITY:
  ☐ No hardcoded API keys
  ☐ No debug tokens in production
  ☐ Firebase rules configured
  ☐ Passwords encrypted
  ☐ No sensitive data logged


════════════════════════════════════════════════════════════════════════════════
RELEASE DAY CHECKLIST
════════════════════════════════════════════════════════════════════════════════

VERSION UPDATE:
  ☐ Update pubspec.yaml version
    version: 1.0.0+1  (dari version ini)

FINAL TESTS:
  ☐ Test di physical device (android)
  ☐ Test di simulator/emulator
  ☐ All features working
  ☐ No unexpected crashes

BUILD APK/AAB:
  ☐ flutter build apk --release  (untuk APK testing)
  ☐ flutter build appbundle --release  (untuk Play Store)
  
VERIFY BUILD:
  ☐ APK/AAB size reasonable
  ☐ App icon visible
  ☐ App name correct
  ☐ Version correct

GIT OPERATIONS:
  ☐ git add .
  ☐ git commit -m "Release v1.0.0"
  ☐ git tag v1.0.0
  ☐ git push origin main
  ☐ git push origin --tags


════════════════════════════════════════════════════════════════════════════════
PLAY STORE SUBMISSION
════════════════════════════════════════════════════════════════════════════════

PREPARATION:
  ☐ Create Google Play Developer account ($25)
  ☐ Setup payment method
  ☐ Accept agreements

CREATE APP:
  ☐ Create app di Play Console
  ☐ Set package name: com.yourname.notesapp
  ☐ Set category: Productivity

STORE LISTING:
  ☐ Write app title (max 50 char)
  ☐ Write short description (max 80 char)
  ☐ Write full description (max 4000 char)
  ☐ Add screenshots (min 2)
  ☐ Add feature graphic (1024x500)
  ☐ Add app icon (512x512, max 1MB)

UPLOAD BUILD:
  ☐ Upload AAB (appbundle)
  ☐ Wait for processing (15-30 min)
  ☐ Review pre-launch report
  ☐ Fix any critical issues

CONTENT RATING:
  ☐ Complete questionnaire
  ☐ Select appropriate ratings

SUBMIT FOR REVIEW:
  ☐ Click "Submit for review"
  ☐ Wait 24-48 hours
  ☐ Check email for approval/rejection

POST-REVIEW:
  ☐ App approved?
  ☐ If rejected, fix issues & resubmit
  ☐ If approved, app available dalam 2-3 hours


════════════════════════════════════════════════════════════════════════════════
QUICK TROUBLESHOOTING
════════════════════════════════════════════════════════════════════════════════

Issue: Build error
Solution: flutter clean ; flutter pub get ; flutter build apk --release

Issue: App crashes on device
Solution: Check logcat, verify permissions, check libraries

Issue: Play Store rejects APK
Solution: APK must be 64-bit AND 32-bit (use appbundle)

Issue: Can't upload AAB
Solution: Check signing certificate, package name, version code

Issue: App review rejected
Solution: Read rejection reason, fix, resubmit


════════════════════════════════════════════════════════════════════════════════
POST-RELEASE (FIRST WEEK)
════════════════════════════════════════════════════════════════════════════════

DAILY:
  ☐ Check Play Console for crash reports
  ☐ Fix critical bugs (night same day)
  ☐ Monitor ratings & reviews

ONGOING:
  ☐ Respond to user reviews
  ☐ Collect feature requests
  ☐ Monitor performance metrics
  ☐ Plan next version


════════════════════════════════════════════════════════════════════════════════
QUICK COMMANDS
════════════════════════════════════════════════════════════════════════════════

Clean & build:
  flutter clean && flutter pub get && flutter build apk --release

Build both architectures:
  flutter build apk --split-per-abi --release

Build for Play Store:
  flutter build appbundle --release

Check file paths:
  Output APK: build/app/outputs/flutter-app.apk
  Output AAB: build/app/outputs/bundle/release/app-release.aab

Git release:
  git add . && git commit -m "Release v1.0.0" && git tag v1.0.0 && git push origin main --tags


════════════════════════════════════════════════════════════════════════════════
IMPORTANT NOTES
════════════════════════════════════════════════════════════════════════════════

1. Don't release Fridays (no support staff)
2. Always test release build on real device
3. Keep backup of keystore file (Android signing)
4. Monitor first 24 hours closely
5. Respond quickly to critical bugs
6. Plan next version updates


════════════════════════════════════════════════════════════════════════════════
SUCCESS METRICS (AFTER 1 WEEK)
════════════════════════════════════════════════════════════════════════════════

✅ App available di Play Store
✅ 0 critical crashes (atau < 0.1%)
✅ Rating >= 4.0 stars
✅ Positive user reviews
✅ No major bugs reported
✅ Performance stable
✅ Feature stabilization complete


════════════════════════════════════════════════════════════════════════════════
RELEASE TIMELINE EXAMPLE
════════════════════════════════════════════════════════════════════════════════

Friday 2 PM: Final testing & builds ready
Friday 3 PM: Submit APK untuk internal review
Saturday: Manual verification
Sunday 6 PM: Create Google Play Developer account
Monday 9 AM: Create app di Play Console
Monday 10 AM: Prepare store listing
Monday 11 AM: Upload AAB
Monday 12 PM: Complete rating questionnaire
Monday 1 PM: Submit for review
Tuesday-Wednesday: Google review process
Wednesday PM: App approval & live on Play Store
Thursday+: Monitor & support


════════════════════════════════════════════════════════════════════════════════
REMEMBER BEFORE HITTING "PUBLISH"
════════════════════════════════════════════════════════════════════════════════

□ Is the app tested thoroughly?
□ Is pubspec.yaml version updated?
□ Are all errors fixed?
□ Is it ready for real users?
□ Are you prepared for support?
□ Is backup of code/data ready?

If all "YES", then PUBLISH! 🚀

*/

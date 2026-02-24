# Authentication Flow Guide

## Overview

This document describes the complete authentication flow in the app, including links between Login, Registration, and Email Verification screens.

## Screen Navigation Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    AuthStateWrapper (Hub)                        │
│                   (State Management Center)                      │
└──────────┬──────────────┬───────────────────────┬────────────────┘
           │              │                       │
           │              │                       │
      INDEX 0         INDEX 1               INDEX 2
           │              │                       │
           ▼              ▼                       ▼
    ┌────────────┐ ┌──────────────┐ ┌────────────────────┐
    │   Login    │ │ Registration │ │ Email Verification │
    │   Screen   │ │   Screen     │ │     Screen         │
    └────────────┘ └──────────────┘ └────────────────────┘
           │              │                       │
           │              │                       │
       (Link 1)       (Link 2)               (Link 3)
           │              │                       │
           └──────────────┴───────────────────────┘
                          │
                          ▼
                    ┌────────────────┐
                    │  Home Screen   │
                    │  (After Auth)  │
                    └────────────────┘
```

## Screen Descriptions

### 1. **Login Screen** (INDEX 0)

- **File**: `lib/screens/login_screen.dart`
- **Purpose**: User authentication with email and password
- **Features**:
  - Email validation
  - Password field
  - Remember me checkbox
  - Social login buttons (Google, Facebook)
  - Forgot password link
  - "Belum punya akun? Daftar di sini" link (navigates to Registration)

**Navigation Callbacks**:

- `onLoginSuccess`: Triggered after successful login → Auto-navigate to Home via auth stream
- `onSignUpTap`: Navigates to Registration Screen (calls `_goToRegistration()`)

---

### 2. **Registration Screen** (INDEX 1)

- **File**: `lib/screens/registration_screen.dart`
- **Purpose**: Create new user account
- **Features**:
  - Name field
  - Email field
  - Password field
  - Confirm password validation
  - Terms & conditions checkbox
  - Success message display

**Navigation Callbacks**:

- `onSignUpSuccess(String email)`: Triggered after successful registration → Navigates to Email Verification Screen with user's email
- `onLoginTap`: Navigates back to Login Screen (calls `_goToLogin()`)

---

### 3. **Email Verification Screen** (INDEX 2)

- **File**: `lib/screens/email_verification_screen.dart`
- **Purpose**: Verify user's email address
- **Features**:
  - Automatic verification check every 3 seconds
  - Manual verification check button
  - Resend email verification (with 60-second cooldown)
  - Step-by-step instructions
  - Skip option (with confirmation dialog)
  - Email display showing which address is being verified

**Navigation Callbacks**:

- `onVerificationComplete`: Triggered when email is verified → Auto-navigate to Home via auth stream
- `onSkip`: Navigates back to Login Screen (calls `_goToLogin()`)

---

### 4. **Home Screen**

- **File**: `lib/screens/home_screen.dart`
- **Purpose**: Main application screen (shown after authentication)
- **Navigation**:
  - `onLogout`: Navigates back to Login Screen via auth stream

---

## Navigation Flow Logic

### User Journey 1: New User Registration Path

```
Login Screen
    ↓ [Click "Daftar di sini"]
Registration Screen
    ↓ [Fill form and click "Daftar"]
Email Verification Screen
    ↓ [Click verification link in email OR manual check]
Home Screen
```

### User Journey 2: Existing User Login Path

```
Login Screen
    ↓ [Fill email/password and click "Login"]
Home Screen
```

### User Journey 3: Switch between Login and Registration

```
Login Screen
    ↓ [Click "Daftar di sini"]
Registration Screen
    ↓ [Click "Sudah punya akun? Login"]
Login Screen
```

### User Journey 4: Skip Email Verification

```
Email Verification Screen
    ↓ [Click "Lewati untuk Sekarang"]
    ↓ [Confirm in dialog]
Login Screen (user not verified)
```

---

## AuthStateWrapper Implementation

The `AuthStateWrapper` is the central hub managing all authentication screens. Here's how it works:

```dart
class _AuthStateWrapperState extends State<AuthStateWrapper> {
  // Screen indices
  static const int _screenLogin = 0;
  static const int _screenRegistration = 1;
  static const int _screenEmailVerification = 2;

  late int _currentScreenIndex;
  String? _newUserEmail; // Store email for verification

  // Navigation methods
  void _goToLogin() { /* ... */ }
  void _goToRegistration() { /* ... */ }
  void _goToEmailVerification(String email) { /* ... */ }

  // Returns appropriate screen based on _currentScreenIndex
  Widget _buildAuthScreen() { /* ... */ }
}
```

### Key Features:

1. **Centralized State Management**: All auth screens communicate through the wrapper
2. **Clear Navigation Methods**: Four dedicated navigation functions
3. **Email Passing**: Email is preserved when navigating to verification screen
4. **Safe Navigation**: All navigation checks `mounted` before setState
5. **Auth Stream Integration**: Seamlessly integrates with Firebase auth state changes

---

## Service Methods Used

### AuthService Methods:

- `signUp(email, password, displayName)` - Register new user
- `login(email, password)` - Login existing user
- `logout()` - Logout current user
- `sendEmailVerification()` - Send verification email
- `isEmailVerified()` - Check verification status
- `resendEmailVerification()` - Resend verification email

### FirebaseService Methods:

- `signUp(email, password)` - Firebase sign up
- `login(email, password)` - Firebase login
- `logout()` - Firebase logout
- `sendEmailVerification()` - Send Firebase email verification
- `isEmailVerified()` - Check Firebase email verified status
- `reloadUser()` - Reload user data from Firebase

---

## Navigation Method Details

### 1. `_goToLogin()`

- Navigates to Login Screen
- Clears `_newUserEmail`
- Used by: Registration → "Login" link, Email Verification → "Skip" button

### 2. `_goToRegistration()`

- Navigates to Registration Screen
- Used by: Login → "Daftar di sini" link

### 3. `_goToEmailVerification(String email)`

- Navigates to Email Verification Screen
- Stores email in `_newUserEmail`
- Used by: Registration → successful registration

---

## Error Handling

Each screen has its own error handling:

### Login Screen:

- Invalid email format validation
- Empty field validation
- Firebase authentication errors (wrong password, user not found, etc.)

### Registration Screen:

- Name validation (min 3 characters)
- Email format validation
- Password validation (min 6 characters)
- Password confirmation matching
- Terms acceptance validation
- Firebase registration errors (email already exists, weak password, etc.)

### Email Verification Screen:

- Email not verified error (auto-retry every 3 seconds)
- Email sending errors (resend button retry)
- Network errors (graceful error messages)

---

## Additional Features

### Smooth Transitions

- Screens are managed via setState, allowing smooth transitions
- Success messages displayed via SnackBar before navigation
- Delays added to allow users to read feedback messages

### User Experience

- Loading indicators during async operations
- Form clearing after successful submission
- Clear error messages
- Confirmation dialogs for important actions (skip email verification)
- Email verification auto-detect (checks every 3 seconds)

### Security Considerations

- Passwords validated before sending to Firebase
- Email verified before full app access
- Session managed through Firebase auth stream
- Sensitive data cleared from controllers after use

---

## Testing the Flow

### Test Case 1: Complete Registration with Verification

1. Launch app
2. Click "Daftar di sini" on Login Screen
3. Fill in registration form
4. Click "Daftar"
5. Verify email (open link in test email)
6. Click "Cek Verifikasi" or wait for auto-check
7. Should navigate to Home Screen

### Test Case 2: Login After Verification

1. Launch app
2. Enter verified email and password
3. Click "Login"
4. Should navigate to Home Screen

### Test Case 3: Switch Between Screens

1. On Login Screen, click "Daftar di sini" → should show Registration
2. On Registration Screen, click "Login" link → should show Login
3. On Login Screen, click "Daftar di sini" again → should show Registration

### Test Case 4: Skip Email Verification

1. Complete registration
2. On Email Verification Screen, click "Lewati untuk Sekarang"
3. Confirm in dialog
4. Should navigate back to Login Screen
5. Cannot login without verified email

---

## Future Enhancements

1. **Page Transitions**: Add beautiful page transition animations
2. **Back Button Handling**: Implement proper back navigation
3. **Internet Check**: Verify internet connectivity before navigation
4. **OAuth Integration**: Connect Google and Facebook login
5. **Biometric Authentication**: Add fingerprint/face recognition login
6. **Password Reset Flow**: Integrate forgot password screen
7. **Two-Factor Authentication**: Add OTP verification
8. **Social Proof**: Show login success animations

---

## File Changes

### Modified Files:

1. `lib/widgets/auth_state_wrapper.dart` - Enhanced with email verification integration
2. `lib/screens/registration_screen.dart` - Updated callback to pass email
3. `lib/services/auth_service.dart` - Added email verification methods
4. `lib/services/firebase_service.dart` - Added email verification methods

### New Files:

1. `lib/screens/email_verification_screen.dart` - New verification screen
2. `AUTH_FLOW_GUIDE.md` - This documentation file

---

## Support & Troubleshooting

### Issue: Navigation not working

- **Solution**: Check that all callbacks are properly connected in AuthStateWrapper

### Issue: Email not received

- **Solution**: Check spam folder, resend email, verify Firebase project settings

### Issue: Verification not detecting

- **Solution**: Check Firebase Authentication settings, ensure email is sent correctly

---

**Last Updated**: February 25, 2026
**Version**: 1.0

# AlaGuard Complete Setup Guide

## Overview
This guide provides step-by-step instructions to set up the complete parent-child account system with QR code linking, OTP verification, and admin panel.

## 1. Flutter App Setup

### 1.1 Install Dependencies
```bash
cd alaguard_app
flutter pub add qr_flutter mobile_scanner otp_text_field device_info_plus
```

### 1.2 Firebase Configuration
1. Create a Firebase project at https://console.firebase.google.com
2. Add Android/iOS apps to your Firebase project
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Place them in the appropriate directories

### 1.3 Enable Firebase Services
- **Authentication**: Enable Email/Password and Anonymous sign-in
- **Firestore**: Create database in production mode
- **Storage**: Enable for profile images
- **Messaging**: Enable for notifications

### 1.4 Firestore Collections Structure
```
parents/
  - email: string
  - name: string
  - phone: string
  - isVerified: boolean
  - createdAt: timestamp
  - updatedAt: timestamp

children/
  - parentId: string (reference)
  - name: string
  - age: number
  - deviceId: string
  - deviceName: string
  - isActive: boolean
  - createdAt: timestamp
  - updatedAt: timestamp

linkingSessions/
  - parentId: string
  - childId: string
  - childName: string
  - childAge: number
  - createdAt: timestamp
  - expiresAt: timestamp
  - isUsed: boolean
  - deviceName: string
```

## 2. Admin Panel Setup (Next.js)

### 2.1 Create Admin Panel
```bash
cd /project/sandbox/user-workspace
npx create-next-app@latest admin_panel --typescript --tailwind --eslint
cd admin_panel
npm install firebase-admin
```

### 2.2 Environment Variables
Create `.env.local` file:
```
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_CLIENT_EMAIL=your_service_account_email
FIREBASE_PRIVATE_KEY=your_private_key
```

### 2.3 Generate Service Account Key
1. Go to Firebase Console → Project Settings → Service Accounts
2. Click "Generate new private key"
3. Save the JSON file and extract the values for environment variables

## 3. Security Rules

### 3.1 Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Parents can only access their own data
    match /parents/{parentId} {
      allow read, write: if request.auth != null && request.auth.uid == parentId;
    }
    
    // Children can only access their own data
    match /children/{childId} {
      allow read: if request.auth != null && 
        (request.auth.uid == childId || request.auth.uid == resource.data.parentId);
      allow write: if request.auth != null && request.auth.uid == childId;
    }
    
    // Linking sessions - read for QR scanning, write for parents
    match /linkingSessions/{sessionId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## 4. Implementation Summary

### 4.1 Parent Registration Flow
1. **RegisterScreen** → Email/Phone + Password
2. **OTPVerificationScreen** → Email verification
3. **ParentDashboard** → After successful verification

### 4.2 Child Linking Flow
1. **QRGeneratorScreen** → Parent generates QR code
2. **QRScannerScreen** → Child device scans QR code
3. **ChildLauncherScreen** → Child dashboard after linking

### 4.3 Key Features Implemented
- ✅ **QR Code Linking**: Secure 10-minute expiry sessions
- ✅ **OTP Verification**: Email-based verification
- ✅ **Admin Panel**: Next.js web dashboard
- ✅ **Real-time Monitoring**: Activity tracking
- ✅ **Device Management**: Unique device identification

## 5. Usage Instructions

### 5.1 For Parents
1. Register with email/password
2. Verify email via OTP
3. Add child details and generate QR code
4. Monitor child activities from dashboard

### 5.2 For Children
1. Install app on child device
2. Scan parent's QR code
3. Device automatically links to parent account
4. App runs in restricted mode

### 5.3 For Admins
1. Access admin panel at `http://localhost:3000`
2. View all parents and children
3. Monitor activities and manage accounts
4. Delete accounts if needed

## 6. Testing Checklist

### 6.1 Parent Features
- [ ] Register with valid email
- [ ] Receive and verify OTP
- [ ] Generate QR code for child
- [ ] View child activities

### 6.2 Child Features
- [ ] Scan QR code successfully
- [ ] Link to parent account
- [ ] Access child dashboard
- [ ] Monitor restrictions apply

### 6.3 Admin Features
- [ ] View parent list
- [ ] View child list
- [ ] Delete accounts
- [ ] View activity logs

## 7. Production Deployment

### 7.1 Flutter App
```bash
flutter build apk --release
flutter build ios --release
```

### 7.2 Admin Panel
```bash
cd admin_panel
npm run build
npm run start
```

## 8. Troubleshooting

### 8.1 Common Issues
- **QR Code Expired**: Generate new QR code (expires in 10 minutes)
- **Email Not Received**: Check spam folder and resend
- **Device Linking Failed**: Ensure stable internet connection

### 8.2 Support Contact
For technical issues, please check the Firebase console logs and ensure all services are properly configured.

## 9. Next Steps
1. Customize UI according to Figma design
2. Add push notifications
3. Implement advanced monitoring features
4. Add subscription/payment integration
5. Implement advanced parental controls

This completes the full parent-child account system with QR code linking, OTP verification, and admin panel setup.

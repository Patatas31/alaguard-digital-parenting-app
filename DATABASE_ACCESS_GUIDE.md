# Database Access Guide - Where to Find Your Data

## 🔍 **Database Location & Access**

### **Primary Database: Firebase Firestore**
**URL**: https://console.firebase.google.com/project/YOUR_PROJECT_ID/firestore

### **Database Structure**

#### **Collection 1: `parents`**
**Location**: Firestore → `parents` collection
**Access**: 
- **Flutter App**: `FirebaseFirestore.instance.collection('parents')`
- **Admin Panel**: `db.collection('parents')`

**Sample Document**:
```json
{
  "email": "parent@example.com",
  "name": "John Doe",
  "phone": "+1234567890",
  "isVerified": true,
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

#### **Collection 2: `children`**
**Location**: Firestore → `children` collection
**Access**:
- **Flutter App**: `FirebaseFirestore.instance.collection('children')`
- **Admin Panel**: `db.collection('children')`

**Sample Document**:
```json
{
  "parentId": "parent_doc_id",
  "name": "Emma",
  "age": 8,
  "deviceId": "device_abc123",
  "deviceName": "Samsung Galaxy S21",
  "isActive": true,
  "createdAt": "2024-01-15T11:00:00Z"
}
```

#### **Collection 3: `linkingSessions`**
**Location**: Firestore → `linkingSessions` collection
**Purpose**: Temporary QR code sessions (10-minute expiry)

**Sample Document**:
```json
{
  "parentId": "parent_doc_id",
  "childId": "child_doc_id",
  "childName": "Emma",
  "childAge": 8,
  "createdAt": "2024-01-15T11:00:00Z",
  "expiresAt": "2024-01-15T11:10:00Z",
  "isUsed": false,
  "deviceName": "Samsung Galaxy S21"
}
```

#### **Collection 4: `activityLogs`**
**Location**: Firestore → `activityLogs` collection
**Purpose**: Child activity monitoring data

**Sample Document**:
```json
{
  "childId": "child_doc_id",
  "activityType": "app_usage",
  "appName": "YouTube",
  "duration": 45,
  "timestamp": "2024-01-15T12:00:00Z"
}
```

## 🌐 **Access Methods**

### **1. Firebase Console (Web Interface)**
**URL**: https://console.firebase.google.com
**Steps**:
1. Go to Firebase Console
2. Select your project
3. Click "Firestore Database" in left sidebar
4. Browse collections and documents

### **2. Flutter App (Code Access)**
```dart
// Access parents collection
final parents = await FirebaseFirestore.instance
    .collection('parents')
    .get();

// Access specific parent
final parent = await FirebaseFirestore.instance
    .collection('parents')
    .doc('parent_id')
    .get();

// Access children of a parent
final children = await FirebaseFirestore.instance
    .collection('children')
    .where('parentId', isEqualTo: 'parent_id')
    .get();
```

### **3. Admin Panel (Web Dashboard)**
**URL**: http://localhost:3000 (when running Next.js admin)
**Features**:
- Real-time view of all parents
- Real-time view of all children
- Activity monitoring
- Account management

### **4. Firebase Admin SDK (Backend)**
```typescript
// Access from admin panel
import { db } from './firebase-admin';

// Get all parents
const parents = await db.collection('parents').get();

// Get all children
const children = await db.collection('children').get();
```

## 📊 **Database Monitoring Tools**

### **1. Firebase Console Analytics**
**URL**: https://console.firebase.google.com/project/YOUR_PROJECT_ID/analytics

### **2. Firestore Usage Metrics**
**Location**: Firebase Console → Firestore → Usage tab

### **3. Real-time Database Updates**
**Location**: Firebase Console → Firestore → Data tab (auto-refreshes)

## 🔐 **Security & Permissions**

### **Access Control**:
- **Parents**: Can only access their own data
- **Children**: Can only access their own data
- **Admin**: Full access via service account

### **Security Rules Location**:
**Firebase Console** → Project Settings → Firestore → Rules tab

## 🛠️ **Database Management**

### **1. Data Export/Import**
**Location**: Firebase Console → Firestore → Import/Export tab

### **2. Indexes**
**Location**: Firebase Console → Firestore → Indexes tab

### **3. Usage & Billing**
**Location**: Firebase Console → Project Settings → Usage and billing

## 📱 **Real-time Access Examples**

### **From Flutter App**:
```dart
// Stream real-time updates
FirebaseFirestore.instance
    .collection('children')
    .where('parentId', isEqualTo: currentUser.uid)
    .snapshots()
    .listen((snapshot) {
      // Handle real-time updates
    });
```

### **From Admin Panel**:
```typescript
// Real-time listener
db.collection('parents').onSnapshot((snapshot) => {
  // Handle real-time updates
});
```

## 🚨 **Important Notes**

1. **Database URL**: Your Firestore URL will be:
   `https://console.firebase.google.com/project/[YOUR_PROJECT_ID]/firestore`

2. **Service Account**: For admin access, use service account credentials

3. **Security Rules**: Ensure rules are properly configured for production

4. **Backup**: Regular backups via Firebase Console Import/Export

## 🔗 **Quick Access Links**
- **Firebase Console**: https://console.firebase.google.com
- **Firestore Database**: https://console.firebase.google.com/project/YOUR_PROJECT_ID/firestore
- **Admin Panel**: http://localhost:3000 (when running Next.js)

Replace `YOUR_PROJECT_ID` with your actual Firebase project ID.

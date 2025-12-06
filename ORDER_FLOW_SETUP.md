# Order Request Flow - Setup Guide

## Overview

The new order flow prevents payment issues by requesting Spark approval **before** payment:

### Flow:

1. **SME** views gig → specifies requirements → sends **order request** (no payment yet)
2. **Spark** receives notification → reviews order → accepts/rejects
3. If **accepted** → **SME** gets notified to pay
4. If **rejected** → Order cancelled (no refund needed ✅)
5. After **payment** → Work begins

## Order Status Flow

```
pendingSparkAcceptance → pendingPayment → inProgress → delivered → completed
                      ↘                                           ↗
                        cancelled
```

## Setup Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Firebase Setup

#### a. Add firebase_messaging to your app

**Android** (`android/app/build.gradle.kts`):

```kotlin
android {
    defaultConfig {
        // ... other config
    }
}

dependencies {
    // ... other dependencies
}
```

**iOS** (`ios/Runner/Info.plist`):

```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

#### b. Initialize NotificationService in main.dart

```dart
import 'package:sparkd/core/services/notification_service.dart';
import 'package:sparkd/core/services/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await init(); // Initialize service locator

  // Initialize notification service
  final notificationService = sl<NotificationService>();
  await notificationService.initialize();

  // Listen to foreground messages
  notificationService.listenToForegroundMessages((message) {
    print('Foreground message: ${message.notification?.title}');
    // Show in-app notification
  });

  // Handle notification taps
  notificationService.handleBackgroundNotificationTap((message) {
    print('App opened from notification: ${message.data}');
    // Navigate to order screen
  });

  runApp(MyApp());
}
```

#### c. Save FCM token after login

In your login success handler:

```dart
final currentUser = FirebaseAuth.instance.currentUser;
if (currentUser != null) {
  await sl<NotificationService>().saveTokenToUser(currentUser.uid);
}
```

### 3. Deploy Cloud Functions

```bash
cd functions
npm install
firebase deploy --only functions
```

This deploys:

- `sendNotificationOnCreate`: Sends FCM when notification document is created
- `onOrderStatusChange`: Auto-notifies on status changes
- `cleanupOldNotifications`: Removes old read notifications (runs daily)

### 4. Firestore Security Rules

Update `firestore.rules`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Orders
    match /orders/{orderId} {
      // SME can create orders
      allow create: if request.auth != null &&
                      request.resource.data.smeID == request.auth.uid;

      // SME and Spark can read their own orders
      allow read: if request.auth != null &&
                    (resource.data.smeID == request.auth.uid ||
                     resource.data.sparkID == request.auth.uid);

      // Spark can update orders (accept/reject)
      allow update: if request.auth != null &&
                      resource.data.sparkID == request.auth.uid;
    }

    // Notifications
    match /notifications/{notificationId} {
      // Users can read their own notifications
      allow read: if request.auth != null &&
                    resource.data.userId == request.auth.uid;

      // Users can update (mark as read)
      allow update: if request.auth != null &&
                      resource.data.userId == request.auth.uid;
    }

    // Users (for FCM tokens)
    match /users/{userId} {
      allow read, write: if request.auth != null &&
                           request.auth.uid == userId;
    }
  }
}
```

## Usage

### Creating an Order Request (SME)

```dart
// Navigate to requirements screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SmeSpecifyRequirements(gig: gig),
  ),
);

// Fill requirements and tap "Send Order Request"
// Order is created with status: pendingSparkAcceptance
// Spark receives FCM notification
```

### Accepting/Rejecting Orders (Spark)

Create a screen to display pending orders:

```dart
class SparkOrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sparkId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<List<OrderEntity>>(
      stream: sl<OrderRepository>().getSparkOrders(sparkId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final pendingOrders = snapshot.data!
            .where((o) => o.status == OrderStatus.pendingSparkAcceptance)
            .toList();

        return ListView.builder(
          itemCount: pendingOrders.length,
          itemBuilder: (context, index) {
            final order = pendingOrders[index];
            return OrderCard(
              order: order,
              onAccept: () => _acceptOrder(order),
              onReject: () => _rejectOrder(order),
            );
          },
        );
      },
    );
  }

  Future<void> _acceptOrder(OrderEntity order) async {
    await sl<OrderRepository>().updateOrderStatus(
      order.id!,
      {
        'status': 'pendingPayment',
        'acceptedAt': DateTime.now().toIso8601String(),
      },
    );
    // SME gets notification to pay
  }

  Future<void> _rejectOrder(OrderEntity order) async {
    await sl<OrderRepository>().updateOrderStatus(
      order.id!,
      {
        'status': 'cancelled',
        'rejectionReason': 'Not available at this time',
        'rejectedAt': DateTime.now().toIso8601String(),
      },
    );
  }
}
```

## Database Structure

### Order Document

```json
{
  "gigID": "gig123",
  "smeID": "user456",
  "sparkID": "user789",
  "gigTitle": "Logo Design",
  "gigPrice": 5000,
  "gigThumbnail": "https://...",
  "requirements": [
    {
      "description": "Business name",
      "type": "text",
      "isMandatory": true
    }
  ],
  "requirementResponses": {
    "Business name": {
      "type": "text",
      "value": "Acme Corp"
    },
    "Company logo": {
      "type": "file",
      "url": "https://storage.../logo.png"
    }
  },
  "status": "pendingSparkAcceptance",
  "createdAt": "2025-12-06T10:00:00.000Z",
  "acceptedAt": null,
  "paymentID": null,
  "deadline": null
}
```

### Notification Document

```json
{
  "userId": "user789",
  "title": "New Order Request!",
  "body": "Logo Design - ₹5000",
  "data": {
    "type": "new_order",
    "orderId": "order123",
    "gigId": "gig123"
  },
  "read": false,
  "createdAt": "2025-12-06T10:00:00.000Z"
}
```

## Testing

1. **Create order request**: SME fills requirements → "Send Order Request"
2. **Check Firestore**: Order document created with `pendingSparkAcceptance`
3. **Check notifications collection**: Notification for Spark created
4. **Spark accepts**: Status changes to `pendingPayment`
5. **SME gets notified**: Check FCM and notifications collection

## Next Steps

- [ ] Implement payment integration (after Spark accepts)
- [ ] Create Spark order management screen
- [ ] Add order history for SME and Spark
- [ ] Implement dispute resolution
- [ ] Add order delivery and review system

// Firebase Cloud Functions for FCM notifications
// This should be deployed to Firebase Functions

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

/**
 * Send FCM notification when a new notification document is created
 */
exports.sendNotificationOnCreate = functions.firestore
  .document("notifications/{notificationId}")
  .onCreate(async (snap, context) => {
    const notification = snap.data();

    try {
      // Get user's FCM token
      const userDoc = await admin
        .firestore()
        .collection("users")
        .doc(notification.userId)
        .get();

      const fcmToken = userDoc.data()?.fcmToken;

      if (!fcmToken) {
        console.log(`No FCM token for user: ${notification.userId}`);
        return null;
      }

      // Send FCM notification
      const message = {
        notification: {
          title: notification.title,
          body: notification.body,
        },
        data: notification.data || {},
        token: fcmToken,
        android: {
          priority: "high",
          notification: {
            channelId: "sparkd_orders",
            sound: "default",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };

      const response = await admin.messaging().send(message);
      console.log("Successfully sent notification:", response);

      return response;
    } catch (error) {
      console.error("Error sending notification:", error);
      return null;
    }
  });

/**
 * Send notification when order status changes
 */
exports.onOrderStatusChange = functions.firestore
  .document("orders/{orderId}")
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    // Check if status changed
    if (beforeData.status === afterData.status) {
      return null;
    }

    try {
      let recipientId, title, body;

      switch (afterData.status) {
        case "pendingPayment":
          // Spark accepted - notify SME
          recipientId = afterData.smeID;
          title = "Order Accepted! 🎉";
          body = `Your order "${afterData.gigTitle}" was accepted. Please complete payment to start work.`;
          break;

        case "inProgress":
          // Payment received - notify Spark
          recipientId = afterData.sparkID;
          title = "Payment Received! 💰";
          body = `Payment received for "${afterData.gigTitle}". You can now start working.`;
          break;

        case "delivered":
          // Work delivered - notify SME
          recipientId = afterData.smeID;
          title = "Work Delivered! 📦";
          body = `Your order "${afterData.gigTitle}" has been delivered. Please review.`;
          break;

        case "completed":
          // Work accepted - notify Spark
          recipientId = afterData.sparkID;
          title = "Order Completed! ✅";
          body = `Order "${afterData.gigTitle}" completed successfully!`;
          break;

        case "cancelled":
          // Order cancelled - notify both
          const smeTitle = "Order Cancelled";
          const smeBody = `Your order "${afterData.gigTitle}" was cancelled.`;

          // Send to SME
          await createNotification(afterData.smeID, smeTitle, smeBody, {
            type: "order_cancelled",
            orderId: context.params.orderId,
          });

          // Send to Spark
          await createNotification(
            afterData.sparkID,
            "Order Cancelled",
            `Order "${afterData.gigTitle}" was cancelled.`,
            { type: "order_cancelled", orderId: context.params.orderId }
          );

          return null;

        default:
          return null;
      }

      // Create notification document (triggers sendNotificationOnCreate)
      await createNotification(recipientId, title, body, {
        type: "order_status_change",
        orderId: context.params.orderId,
        status: afterData.status,
      });

      return null;
    } catch (error) {
      console.error("Error in order status change:", error);
      return null;
    }
  });

/**
 * Helper function to create notification document
 */
async function createNotification(userId, title, body, data) {
  return await admin.firestore().collection("notifications").add({
    userId: userId,
    title: title,
    body: body,
    data: data,
    read: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

/**
 * Clean up old notifications (runs daily)
 */
exports.cleanupOldNotifications = functions.pubsub
  .schedule("every 24 hours")
  .onRun(async (context) => {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const snapshot = await admin
      .firestore()
      .collection("notifications")
      .where("createdAt", "<", thirtyDaysAgo)
      .where("read", "==", true)
      .get();

    const batch = admin.firestore().batch();
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    console.log(`Deleted ${snapshot.size} old notifications`);
    return null;
  });

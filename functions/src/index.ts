import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import { logger } from "firebase-functions";

admin.initializeApp();

export const sendPendingNotification = onDocumentCreated("pending_notifications/{notificationId}", async (event) => {
  const snap = event.data;
  const notificationId = event.params.notificationId;

  if (!snap) return;

  const data = snap.data();
  const fcmToken = data?.fcmToken;
  const title = data?.title;
  const body = data?.body;

  if (!fcmToken || !title || !body) {
    logger.error("Missing FCM token, title, or body");
    return;
  }

  const message = {
    token: fcmToken,
    notification: { title, body },
    data: {
      ...Object.entries(data)
        .filter(([k, v]) => typeof v === "string")
        .reduce((acc, [k, v]) => ({ ...acc, [k]: v as string }), {}),
      notificationId,
    },
  };

  try {
    await admin.messaging().send(message);
    await snap.ref.update({
      delivered: true,
      deliveredAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    logger.log(`Notification sent to ${fcmToken}`);
  } catch (error: any) {
    await snap.ref.update({ error: error.message, delivered: false });
    logger.error("Error sending notification:", error);
  }
});

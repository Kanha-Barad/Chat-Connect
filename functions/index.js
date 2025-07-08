const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendPushNotification = functions.https.onRequest(async (req, res) => {
  // Set CORS
  res.set("Access-Control-Allow-Origin", "*");

  if (req.method === "OPTIONS") {
    res.set("Access-Control-Allow-Methods", "POST");
    res.set("Access-Control-Allow-Headers", "Content-Type");
    return res.status(204).send("");
  }

  if (req.method !== "POST") {
    return res.status(405).send("Method Not Allowed");
  }

  try {
    const {toUserId, title, body, data, fromUserId} = req.body;

    if (!toUserId || !title || !body || !fromUserId) {
      return res.status(400).send("Missing required fields");
    }

    const userDoc = await admin.firestore().collection("users").doc(toUserId).get();
    if (!userDoc.exists || !userDoc.data().fcmToken) {
      return res.status(404).send("User or FCM token not found");
    }

    // Corrected message structure
    const message = {
      token: userDoc.data().fcmToken,
      notification: {
        title,
        body,
      },
      data: {
        ...(data || {}),
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        targetUserId: toUserId,
        senderUserId: fromUserId,
      },
      android: {
        priority: "high",
        notification: {
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      },
      apns: {
        payload: {
          aps: {
            contentAvailable: true,
            category: "FLUTTER_NOTIFICATION_CLICK",
          },
        },
      },
    };
    // const message = {
    //   token: userDoc.data().fcmToken,
    //   notification: {
    //     title,
    //     body,
    //     // ❌ Removed click_action from here (invalid in Admin SDK)
    //   },
    //   data: {
    //     ...(data || {}), // Spread custom data if provided
    //     click_action: "FLUTTER_NOTIFICATION_CLICK", // ✅ Correct placement for Flutter
    //   },
    //   android: {
    //     priority: "high",
    //     notification: {
    //       clickAction: "FLUTTER_NOTIFICATION_CLICK", // For native Android
    //     },
    //   },
    //   apns: {
    //     payload: {
    //       aps: {
    //         contentAvailable: true,
    //         // iOS-specific click action (if needed)
    //         category: "FLUTTER_NOTIFICATION_CLICK",
    //       },
    //     },
    //   },
    // };

    const response = await admin.messaging().send(message);
    return res.status(200).json({
      success: true,
      messageId: response,
    });
  } catch (error) {
    console.error("Error:", error);
    return res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

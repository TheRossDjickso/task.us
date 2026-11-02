import admin from 'firebase-admin';
import fs from 'fs';
import path from 'path';
import { DeviceToken } from '../models/index.js';

let firebaseApp: admin.app.App | null = null;

try {
  const credPath = process.env.GOOGLE_APPLICATION_CREDENTIALS || './firebase-service-account.json';
  const resolvedPath = path.resolve(process.cwd(), credPath);

  if (fs.existsSync(resolvedPath)) {
    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert(resolvedPath),
    });
    console.log('Firebase Admin initialized successfully.');
  } else if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
    const credentials = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);
    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert(credentials),
    });
    console.log('Firebase Admin initialized from JSON env variable.');
  } else {
    console.warn(
      'Firebase Service Account file not found. Push notifications will be disabled in this session.'
    );
  }
} catch (error) {
  console.error('Failed to initialize Firebase Admin SDK:', error);
}

/**
 * Sends a push notification to multiple device tokens.
 * Automatically removes unregistered/invalid tokens from the database.
 */
export async function sendPushNotification(
  tokens: string[],
  title: string,
  body: string,
  data?: Record<string, string>
) {
  if (!firebaseApp || tokens.length === 0) {
    return;
  }

  try {
    const message: admin.messaging.MulticastMessage = {
      tokens,
      notification: {
        title,
        body,
      },
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
        },
      },
    };

    if (data) {
      message.data = data;
    }

    const response = await firebaseApp.messaging().sendEachForMulticast(message);

    if (response.failureCount > 0) {
      const tokensToRemove: string[] = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success && resp.error) {
          const code = resp.error.code;
          if (
            code === 'messaging/invalid-registration-token' ||
            code === 'messaging/registration-token-not-registered'
          ) {
            const token = tokens[idx];
            if (token) {
              tokensToRemove.push(token);
            }
          }
        }
      });

      if (tokensToRemove.length > 0) {
        await DeviceToken.destroy({
          where: {
            token: tokensToRemove,
          },
        });
        console.log(`Cleaned up ${tokensToRemove.length} expired FCM tokens.`);
      }
    }
  } catch (error) {
    console.error('Error sending multicast FCM push notifications:', error);
  }
}

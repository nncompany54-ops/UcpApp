// Service worker for Firebase Cloud Messaging in Flutter Web
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

// Initialize Firebase App in Service Worker.
// Replace these placeholders with your actual Firebase config values from Firebase Console.
firebase.initializeApp({
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_AUTH_DOMAIN",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_STORAGE_BUCKET",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId: "YOUR_APP_ID"
});

const messaging = firebase.messaging();

// Background message handler
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  
  // Customizing notification details
  const notificationTitle = payload.notification.title || 'رسالة جديدة من المؤسسة المتحدة';
  const notificationOptions = {
    body: payload.notification.body || '',
    icon: '/assets/assets/images/app_icon.png', // Fallback to app icon
    badge: '/assets/assets/images/app_icon.png',
    data: payload.data
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

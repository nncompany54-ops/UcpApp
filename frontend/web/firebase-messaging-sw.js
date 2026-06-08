// Service worker for Firebase Cloud Messaging in Flutter Web
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

// Initialize Firebase App in Service Worker.
// Replace these placeholders with your actual Firebase config values from Firebase Console.
firebase.initializeApp({
  apiKey: "AIzaSyB9uweZD8K7vXMKOtHVLVwjImKINlRR4ZE",
  authDomain: "ucp-platform.firebaseapp.com",
  projectId: "ucp-platform",
  storageBucket: "ucp-platform.firebasestorage.app",
  messagingSenderId: "757541342147",
  appId: "1:757541342147:web:f9d438d1c86c7c58eb4b76"
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

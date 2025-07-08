importScripts('https://www.gstatic.com/firebasejs/9.1.3/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.1.3/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyBqMSDEXEjZa3QYs1hReRLhpA5mfPAfqGg',
  appId: '1:98767185642:web:76ede13f84c14f41a89993',
  messagingSenderId: '98767185642',
  projectId: 'chatconnect-b5073',
  authDomain: 'chatconnect-b5073.firebaseapp.com',
  storageBucket: 'chatconnect-b5073.firebasestorage.app',
  //storageBucket: 'chatconnect-b5073.appspot.com', // ✅ correct

});

const messaging = firebase.messaging();

//messaging.onBackgroundMessage(function(payload) {
//  console.log('[firebase-messaging-sw.js] Received background message ', payload);
//  const notificationTitle = payload.notification.title;
//  const notificationOptions = {
//    body: payload.notification.body,
//    icon: '/icons/Icon-192.png'
//  };
//
//  self.registration.showNotification(notificationTitle, notificationOptions);
//});

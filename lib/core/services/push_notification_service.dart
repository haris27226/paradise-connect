// import 'package:firebase_messaging/firebase_messaging.dart';

// class PushNotificationService {
//   static Future<void> initialize() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;

//     // 1️⃣ Request Permission
//     await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     // 2️⃣ Get Token
//     String? token = await messaging.getToken();
//     print("FCM TOKEN: $token");

//     // 3️⃣ Foreground Listener
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print("Foreground Message: ${message.notification?.title}");
//     });

//     // 4️⃣ When App Opened From Notification
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print("Notification Clicked");
//     });
//   }
// }
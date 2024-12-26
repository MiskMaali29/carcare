// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAwuE0A2M_8J5l4Xmy0sjUo-gHKh2oIzYg',
    appId: '1:732379485235:android:8db411e8fea7189c0ebf46',
    messagingSenderId: '732379485235',
    projectId: 'carcare-app-52eb1',
    storageBucket: 'carcare-app-52eb1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCxxLOLNv_9SZAdSo9VO8UjMrthEU_lZ5U',
    appId: '1:732379485235:ios:0aed8e5cbfbe5e8e0ebf46',
    messagingSenderId: '732379485235',
    projectId: 'carcare-app-52eb1',
    storageBucket: 'carcare-app-52eb1.firebasestorage.app',
    iosBundleId: 'com.example.carcare',
  );
}
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the flutterfire cli.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the flutterfire cli.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the flutterfire cli.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the flutterfire cli.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB9uweZD8K7vXMKOtHVLVwjImKINlRR4ZE',
    appId: '1:757541342147:web:f9d438d1c86c7c58eb4b76',
    messagingSenderId: '757541342147',
    projectId: 'ucp-platform',
    authDomain: 'ucp-platform.firebaseapp.com',
    storageBucket: 'ucp-platform.firebasestorage.app',
    measurementId: 'G-MTX2TPJYN9',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCqsa42HH9iBP84ssGT8NzTfd8sSWkb1hk',
    appId: '1:757541342147:android:86317dded76036cceb4b76',
    messagingSenderId: '757541342147',
    projectId: 'ucp-platform',
    storageBucket: 'ucp-platform.firebasestorage.app',
  );
}

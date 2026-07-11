import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBlW_t26qzXb4EmwCeYIwmrMSi_lr0QJHE',
    appId: '1:564761085746:web:c90e0195591016306a792b',
    messagingSenderId: '564761085746',
    projectId: 'kdxapp-2c34a',
    authDomain: 'kdxapp-2c34a.firebaseapp.com',
    storageBucket: 'kdxapp-2c34a.firebasestorage.app',
    measurementId: 'G-SZ5SW7Y908',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBkkJ2cTWFSKG26JVeVLJcV8fCntsLTSTA',
    appId: '1:564761085746:android:ef9c9749785c74506a792b',
    messagingSenderId: '564761085746',
    projectId: 'kdxapp-2c34a',
    storageBucket: 'kdxapp-2c34a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAYQQYdB0KhYs6-onw9vGLhhOIpDK4-aoQ',
    appId: '1:564761085746:ios:9626eb32cbab8a286a792b',
    messagingSenderId: '564761085746',
    projectId: 'kdxapp-2c34a',
    storageBucket: 'kdxapp-2c34a.firebasestorage.app',
    iosBundleId: 'com.example.store',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAYQQYdB0KhYs6-onw9vGLhhOIpDK4-aoQ',
    appId: '1:564761085746:ios:9626eb32cbab8a286a792b',
    messagingSenderId: '564761085746',
    projectId: 'kdxapp-2c34a',
    storageBucket: 'kdxapp-2c34a.firebasestorage.app',
    iosBundleId: 'com.example.store',
  );
}

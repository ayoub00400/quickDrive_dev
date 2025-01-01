import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      // case TargetPlatform.android:
      //   return android;
      // default:
      //   throw UnsupportedError(
      //     'DefaultFirebaseOptions are not supported for this platform.',
      //   );
      case TargetPlatform.android:
        print("Firebase Platform is Android");
        return android;
      case TargetPlatform.iOS:
        print("Firebase Platform is IOS");
        return ios;
      default:
        print("Firebase Platform - Unsupported");
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
      apiKey: "AIzaSyBf5kZx5V-40dpi4isxJwJ6LcSsmckbogg",
      projectId: "quickcargoo-68335",
      storageBucket: "quickcargoo-68335.appspot.com",
      messagingSenderId: "522987428134",
      appId: "1:980935620101:android:e2b092ee17d6d4ddcace6c",
      measurementId: "G-Z8X6437N06");

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyCflabBeIT4v1qUkJWms3VoNrge6phbciQ",
    authDomain: "taxi-booking-810bf.firebaseapp.com",
    projectId: "taxi-booking-810bf",
    storageBucket: "taxi-booking-810bf.appspot.com",
    messagingSenderId: "522987428134",
    appId: "1:522987428134:ios:5a81eab57ec4ad92e809e7",
    measurementId: "G-Z8X6437N06",
    androidClientId:
        '522987428134-aq4d1ei9571vouqqovja59uj5hqi9bho.apps.googleusercontent.com',
    iosClientId:
        '522987428134-f8lkt3rai45nnpf2nhs90c51unt81mm7.apps.googleusercontent.com',
    iosBundleId: 'com.mighty.taxidriver',
  );
}

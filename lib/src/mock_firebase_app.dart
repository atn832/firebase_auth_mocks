import 'package:firebase_core/firebase_core.dart';

// TODO: Move this into a new package (eg. FakeFirebaseCore).
class MockFirebaseApp implements FirebaseApp {
  // The value comes from
  // https://github.com/firebase/flutterfire/blob/ea03c6b349ccd63317f96e37c85daf7e11f2a28a/packages/firebase_core/firebase_core_platform_interface/lib/firebase_core_platform_interface.dart#L31.
  @override
  String get name => '[DEFAULT]';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

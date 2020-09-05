import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

class MockUser extends Mock implements User {
  @override
  String get displayName => 'Bob';

  @override
  String get uid => 'aabbcc';

  @override
  String get email => 'bob@somedomain.com';

  @override
  Future<String> getIdToken([bool forceRefresh = false]) async {
    return Future.value('fake_token');
  }
}

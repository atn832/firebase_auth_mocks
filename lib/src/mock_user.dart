import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

class MockUser extends Mock implements User {
  final bool _isAnonymous;

  MockUser({bool isAnonymous}) : _isAnonymous = isAnonymous;

  @override
  String get displayName => 'Bob';

  @override
  String get uid => 'aabbcc';

  @override
  String get email => 'bob@somedomain.com';

  @override
  bool get isAnonymous => _isAnonymous;

  @override
  Future<String> getIdToken([bool forceRefresh = false]) async {
    return Future.value('fake_token');
  }
}

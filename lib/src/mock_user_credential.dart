import 'package:firebase_auth/firebase_auth.dart';

import 'mock_user.dart';

class MockUserCredential implements UserCredential {
  final MockUser _mockUser;

  MockUserCredential(bool isAnonymous, {MockUser? mockUser})
      // Ensure no mocked credentials or mocked for Anonymous
      : assert(mockUser == null || mockUser.isAnonymous == isAnonymous),
        _mockUser = mockUser ?? MockUser(isAnonymous: isAnonymous);

  @override
  User get user => mockUser;

  // Strongly typed for use within the project.
  MockUser get mockUser => _mockUser;

  @override
  // TODO: implement additionalUserInfo
  AdditionalUserInfo? get additionalUserInfo => throw UnimplementedError();

  @override
  // TODO: implement credential
  AuthCredential? get credential => throw UnimplementedError();
}

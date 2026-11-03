/// App-level view of a signed-in user, independent of Firebase types.
class AuthUser {
  const AuthUser({required this.uid, this.email, this.displayName});

  final String uid;
  final String? email;
  final String? displayName;
}

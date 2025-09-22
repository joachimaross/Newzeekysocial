class AppUser {
  final String uid;
  final String displayName;
  final String? photoURL;

  AppUser({
    required this.uid,
    required this.displayName,
    this.photoURL,
  });
}

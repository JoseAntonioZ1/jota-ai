class UserProfile {
  const UserProfile({required this.userId, required this.name, required this.onboardingCompleted});

  final String userId;
  final String? name;
  final bool onboardingCompleted;
}

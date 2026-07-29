class CreateProfileRequest {
  final String name;
  final List<String> favoriteSports;
  final String profileImageUrl;

  const CreateProfileRequest({
    required this.name,
    required this.favoriteSports,
    required this.profileImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'favoriteSports': favoriteSports,
      'profileImageUrl': profileImageUrl,
    };
  }
}

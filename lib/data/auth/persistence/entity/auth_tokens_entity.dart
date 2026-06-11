import 'package:json_annotation/json_annotation.dart';

part 'auth_tokens_entity.g.dart';

@JsonSerializable()
class AuthTokensEntity {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  @JsonKey(defaultValue: 0)
  final int accessTokenExpiresAtMillisecondsSinceEpoch;

  AuthTokensEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.accessTokenExpiresAtMillisecondsSinceEpoch,
  });

  factory AuthTokensEntity.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensEntityFromJson(json);

  Map<String, dynamic> toJson() => _$AuthTokensEntityToJson(this);
}

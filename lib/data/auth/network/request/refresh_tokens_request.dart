import 'package:json_annotation/json_annotation.dart';

part 'refresh_tokens_request.g.dart';

@JsonSerializable(createFactory: false)
class RefreshTokensRequest {
  final String refreshToken;

  RefreshTokensRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => _$RefreshTokensRequestToJson(this);
}

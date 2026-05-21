import 'package:json_annotation/json_annotation.dart';

part 'logout_request.g.dart';

@JsonSerializable(createFactory: false)
class LogoutRequest {
  final String refreshToken;

  LogoutRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => _$LogoutRequestToJson(this);
}

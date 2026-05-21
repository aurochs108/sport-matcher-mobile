import 'package:json_annotation/json_annotation.dart';

part 'email_login_request.g.dart';

@JsonSerializable(createFactory: false)
class EmailLoginRequest {
  final String email;
  final String password;
  final String deviceId;

  EmailLoginRequest({
    required this.email,
    required this.password,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() => _$EmailLoginRequestToJson(this);
}

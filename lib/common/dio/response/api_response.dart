import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

/// 단순히 성공/실패의 결과값만 받는 api 요청의 경우에 사용하는 공통 응답 모델
@JsonSerializable()
class ApiResponse {
  final int statusCode;
  final String? message;
  final String? error;

  ApiResponse({
    required this.statusCode,
    this.message,
    this.error,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) => _$ApiResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ApiResponseToJson(this);
}

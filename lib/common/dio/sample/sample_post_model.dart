import 'package:json_annotation/json_annotation.dart';

part 'sample_post_model.g.dart';

/// JsonSerializable 사용 예시 모델
/// 응답 예시 (https://jsonplaceholder.typicode.com/posts/1)
/// { "userId": 1, "id": 1, "title": "...", "body": "..." }
///
/// 모델 수정 후 코드 생성 :
///   dart run build_runner build
@JsonSerializable()
class SamplePostModel {
  final int id;
  final int userId;
  final String title;

  /// 서버 key 와 변수명이 다를 경우 @JsonKey(name: ...) 사용
  @JsonKey(name: 'body')
  final String content;

  SamplePostModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
  });

  factory SamplePostModel.fromJson(Map<String, dynamic> json) => _$SamplePostModelFromJson(json);
  Map<String, dynamic> toJson() => _$SamplePostModelToJson(this);
}

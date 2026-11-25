// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sample_post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SamplePostModel _$SamplePostModelFromJson(Map<String, dynamic> json) =>
    SamplePostModel(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      title: json['title'] as String,
      content: json['body'] as String,
    );

Map<String, dynamic> _$SamplePostModelToJson(SamplePostModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'body': instance.content,
    };

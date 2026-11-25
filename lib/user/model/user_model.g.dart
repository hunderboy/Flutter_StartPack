// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String,
  profileImage: json['profileImage'] as String?,
  loginType: $enumDecode(_$SocialLoginTypeEnumMap, json['loginType']),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'profileImage': instance.profileImage,
  'loginType': _$SocialLoginTypeEnumMap[instance.loginType]!,
};

const _$SocialLoginTypeEnumMap = {
  SocialLoginType.google: 'google',
  SocialLoginType.apple: 'apple',
  SocialLoginType.kakao: 'kakao',
  SocialLoginType.naver: 'naver',
};

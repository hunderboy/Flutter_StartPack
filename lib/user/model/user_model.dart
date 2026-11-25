import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// 아래 3가지 경우는 모두 UserModelBase 의 자식 (+ null : 로그아웃 상태)
/// 1. UserModelError   : 계정정보 가져오는데 에러 발생
/// 2. UserModelLoading : 계정정보 가져오는 중
/// 3. UserModel        : 계정정보 가지고 있는 상태
sealed class UserModelBase {}

class UserModelError extends UserModelBase {
  final String message;

  UserModelError({required this.message});
}

class UserModelLoading extends UserModelBase {}

/// 소셜 로그인 종류
enum SocialLoginType { google, apple, kakao, naver }

@JsonSerializable()
class UserModel extends UserModelBase {
  final int id;
  final String name;
  final String email;
  final String? profileImage;
  final SocialLoginType loginType;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    required this.loginType,
  });

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? profileImage,
    SocialLoginType? loginType,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      loginType: loginType ?? this.loginType,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

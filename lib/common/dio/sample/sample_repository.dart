import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

import 'package:flutter_start_pack/common/const/data.dart';
import 'package:flutter_start_pack/common/dio/dio.dart';
import 'package:flutter_start_pack/common/dio/sample/sample_post_model.dart';

part 'sample_repository.g.dart';

/// Provider
final sampleRepositoryProvider = Provider<SampleRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return SampleRepository(dio, baseUrl: sampleServerIP);
});

/// 샘플 데이터 요청 Provider (Lobby 홈 탭에서 사용)
final samplePostsProvider = FutureProvider.autoDispose<List<SamplePostModel>>((ref) {
  return ref.watch(sampleRepositoryProvider).getPosts();
});

/// Retrofit 사용 예시 Repository
/// 새로운 Repository 를 만들 때 이 파일을 복사해서 사용한다.
@RestApi()
abstract class SampleRepository {
  factory SampleRepository(Dio dio, {String? baseUrl}) = _SampleRepository;

  /// GET 목록
  @GET('/posts')
  Future<List<SamplePostModel>> getPosts();

  /// GET 단건 (Path 파라미터)
  @GET('/posts/{id}')
  Future<SamplePostModel> getPost(@Path() int id);

  /// 토큰이 필요한 요청 예시
  /// Header 에 accessToken: true 를 넣으면 CustomInterceptor 가 실제 토큰으로 교체한다.
  @POST('/posts')
  @Headers({'accessToken': 'true'})
  Future<SamplePostModel> createPost(@Body() SamplePostModel body);
}

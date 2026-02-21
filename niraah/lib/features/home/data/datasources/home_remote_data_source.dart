import '../../../../core/network/api_repository.dart';
import '../../../../shared/helpers/result.dart';
import '../dto/post_dto.dart';

class HomeRemoteDataSource {
  HomeRemoteDataSource(this._apiRepository);

  final ApiRepository _apiRepository;

  Future<Result<List<PostDto>>> fetchPosts() {
    return _apiRepository.get<List<PostDto>>(
      '/posts',
      parser: (dynamic data) {
        final List<dynamic> raw = data as List<dynamic>;
        return raw
            .map(
              (dynamic item) => PostDto.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      },
    );
  }
}

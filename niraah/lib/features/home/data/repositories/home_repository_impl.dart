import '../../../../shared/helpers/result.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';
import '../dto/post_dto.dart';
import '../mappers/post_mapper.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._remoteDataSource);

  final HomeRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<Post>>> fetchPosts() async {
    final Result<List<PostDto>> rawResult = await _remoteDataSource.fetchPosts();
    return rawResult.when(
      success: (List<PostDto> data) {
        final List<Post> entities = data.map(PostMapper.toEntity).toList();
        return Success<List<Post>>(entities);
      },
      failure: FailureResult<List<Post>>.new,
    );
  }
}

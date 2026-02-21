import '../../../../shared/helpers/result.dart';
import '../entities/post.dart';

abstract class HomeRepository {
  Future<Result<List<Post>>> fetchPosts();
}

import '../../domain/entities/post.dart';
import '../dto/post_dto.dart';

class PostMapper {
  const PostMapper._();

  static Post toEntity(PostDto dto) {
    return Post(
      id: dto.id,
      title: dto.title,
      body: dto.body,
    );
  }
}

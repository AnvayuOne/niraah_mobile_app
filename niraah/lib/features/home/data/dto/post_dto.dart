import '../../../../shared/helpers/typedefs.dart';

class PostDto {
  const PostDto({
    required this.id,
    required this.title,
    required this.body,
  });

  static PostDto fromJson(JsonMap json) {
    return PostDto(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  final int id;
  final String title;
  final String body;
}

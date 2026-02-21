import 'package:flutter/material.dart';

import '../../domain/entities/post.dart';

class PostTile extends StatelessWidget {
  const PostTile({required this.post, super.key});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(post.title),
        subtitle: Text(
          post.body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

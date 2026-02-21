import 'package:equatable/equatable.dart';

import '../../../../core/state/status.dart';
import '../../domain/entities/post.dart';

class HomeState extends Equatable {
  const HomeState({
    this.status = Status.initial,
    this.posts = const <Post>[],
    this.message,
  });

  final Status status;
  final List<Post> posts;
  final String? message;

  HomeState copyWith({
    Status? status,
    List<Post>? posts,
    String? message,
  }) {
    return HomeState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, posts, message];
}

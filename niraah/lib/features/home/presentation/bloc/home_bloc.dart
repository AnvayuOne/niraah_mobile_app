import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/state/status.dart';
import '../../../../shared/helpers/result.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._repository) : super(const HomeState()) {
    on<HomeStarted>(_onLoad);
    on<HomeRefreshed>(_onLoad);
  }

  final HomeRepository _repository;

  Future<void> _onLoad(HomeEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: Status.loading, message: null));
    final Result<List<Post>> result = await _repository.fetchPosts();
    result.when(
      success: (List<Post> posts) {
        emit(
          state.copyWith(
            status: posts.isEmpty ? Status.empty : Status.success,
            posts: posts,
          ),
        );
      },
      failure: (String message) {
        emit(state.copyWith(status: Status.failure, message: message));
      },
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/state/status.dart';
import '../../../../../shared/helpers/result.dart';
import '../../../common/presentation/bloc/member_data_state.dart';
import '../../data/repositories/chat_ai_repository.dart';

class ChatAiCubit extends Cubit<MemberDataState> {
  ChatAiCubit(this._repository) : super(const MemberDataState(title: 'AI Chat'));

  final ChatAiRepository _repository;

  Future<void> send(String prompt) async {
    emit(state.copyWith(status: Status.loading, message: null));
    final Result<List<String>> result = await _repository.sendPrompt(prompt);
    result.when(
      success: (List<String> data) =>
          emit(state.copyWith(status: Status.success, payload: data, title: 'AI Chat')),
      failure: (String message) => emit(state.copyWith(status: Status.failure, message: message)),
    );
  }
}

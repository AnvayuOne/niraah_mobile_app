import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/state/status.dart';
import '../../../../../shared/helpers/result.dart';
import '../../../common/presentation/bloc/member_data_state.dart';
import '../../data/repositories/questionnaire_repository.dart';

class QuestionnaireCubit extends Cubit<MemberDataState> {
  QuestionnaireCubit(this._repository) : super(const MemberDataState(title: 'Questionnaire'));

  final QuestionnaireRepository _repository;

  Future<void> submit() async {
    emit(state.copyWith(status: Status.loading, message: null));
    final Result<List<String>> result = await _repository.submitSampleQuestionnaire();
    result.when(
      success: (List<String> data) =>
          emit(state.copyWith(status: Status.success, payload: data, title: 'Questionnaire')),
      failure: (String message) => emit(state.copyWith(status: Status.failure, message: message)),
    );
  }
}

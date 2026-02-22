import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../../../design_system/widgets/app_button.dart';
import '../../../../../design_system/widgets/app_scaffold.dart';
import '../../../common/presentation/widgets/member_data_page_view.dart';
import '../bloc/chat_ai_cubit.dart';

class ChatAiPage extends StatefulWidget {
  const ChatAiPage({super.key});

  @override
  State<ChatAiPage> createState() => _ChatAiPageState();
}

class _ChatAiPageState extends State<ChatAiPage> {
  final TextEditingController _promptController =
      TextEditingController(text: 'How can I improve hormonal balance?');

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatAiCubit>(
      create: (_) => getIt<ChatAiCubit>()..send(_promptController.text),
      child: AppScaffold(
        title: 'AI Chat',
        body: Column(
          children: <Widget>[
            Expanded(
              child: MemberDataPageView<ChatAiCubit>(
                title: 'AI Chat',
                showScaffold: false,
                onRefresh: () => context.read<ChatAiCubit>().send(_promptController.text),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _promptController,
                      decoration: const InputDecoration(labelText: 'Prompt'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    label: 'Ask',
                    onPressed: () => context.read<ChatAiCubit>().send(_promptController.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

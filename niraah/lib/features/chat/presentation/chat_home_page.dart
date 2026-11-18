import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/area_navigation.dart';
import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/bottom_nav.dart';
import '../../../design_system/widgets/error_view.dart';
import '../../../design_system/widgets/loading_view.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/constants/route_constants.dart';
import '../../home/domain/home.dart';
import '../../home/presentation/home_labels.dart';
import '../domain/chat.dart';
import 'chat_cubits.dart';

/// AI Care home (spec 010 §8): personalisation, a new conversation, starter
/// prompts and her conversations, newest first.
class ChatHomePage extends StatelessWidget {
  const ChatHomePage({super.key, this.cubit});

  /// For tests and screenshots.
  final ChatHomeCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final ChatHomeCubit? given = cubit;
    return given != null
        ? BlocProvider<ChatHomeCubit>.value(value: given, child: const _ChatHomeView())
        : BlocProvider<ChatHomeCubit>(create: (_) => ChatHomeCubit(getIt<ChatRepository>())..load(), child: const _ChatHomeView());
  }
}

class _ChatHomeView extends StatelessWidget {
  const _ChatHomeView();

  Future<void> _open(BuildContext context, {String? starter}) async {
    final ChatHomeCubit cubit = context.read<ChatHomeCubit>();
    final String id = await cubit.newConversation();
    if (!context.mounted) return;
    await context.push('${RouteConstants.chat}/$id', extra: starter);
    await cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return BlocBuilder<ChatHomeCubit, ChatHomeState>(
      builder: (BuildContext context, ChatHomeState st) {
        final ChatHome? home = st.home;
        final Widget body = st.status == ChatLoad.failure
            ? ErrorView(message: s.commonLoadError, retryLabel: s.tryAgain, onRetry: context.read<ChatHomeCubit>().load)
            : home == null
                ? LoadingView(label: s.loading)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(NSpace.lg, NSpace.lg, NSpace.lg, NSpace.xl),
                    children: <Widget>[
                      Semantics(header: true, child: Text(s.chatTitle, style: NType.h2.copyWith(color: NColors.inkPrimary))),
                      const SizedBox(height: NSpace.xs),
                      _Personalisation(on: home.personalised),
                      const SizedBox(height: NSpace.lg),
                      NPrimaryButton(label: s.chatNewChat, onPressed: () => _open(context)),
                      const SizedBox(height: NSpace.lg),
                      Semantics(header: true, child: Text(s.chatStarterTitle, style: NType.h4.copyWith(color: NColors.inkPrimary))),
                      const SizedBox(height: NSpace.sm),
                      Wrap(
                        spacing: NSpace.xs,
                        runSpacing: NSpace.xs,
                        children: <Widget>[
                          for (final String p in home.starters)
                            ActionChip(
                              label: Text(p),
                              labelStyle: NType.bodySm.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w500),
                              backgroundColor: NColors.brandLavenderLight,
                              side: BorderSide.none,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(horizontal: NSpace.sm, vertical: NSpace.xs),
                              onPressed: () => _open(context, starter: p),
                            ),
                        ],
                      ),
                      const SizedBox(height: NSpace.xl),
                      Semantics(header: true, child: Text(s.chatConversations, style: NType.h4.copyWith(color: NColors.inkPrimary))),
                      const SizedBox(height: NSpace.sm),
                      if (home.conversations.isEmpty)
                        Text(s.chatNoConversations, style: NType.bodySm.copyWith(color: NColors.inkMuted))
                      else
                        for (final ConversationSummary c in home.conversations)
                          Padding(
                            padding: const EdgeInsets.only(bottom: NSpace.xs),
                            child: Material(
                              color: NColors.surfaceCard,
                              borderRadius: BorderRadius.circular(NRadius.lg),
                              child: ListTile(
                                minTileHeight: NLayout.minTapTarget + NSpace.sm,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NRadius.lg), side: const BorderSide(color: NColors.lineDefault)),
                                title: Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: NType.body.copyWith(color: NColors.inkPrimary)),
                                trailing: const Icon(Icons.chevron_right_rounded, color: NColors.inkMuted),
                                onTap: () async {
                                  await context.push('${RouteConstants.chat}/${c.id}');
                                  if (context.mounted) await context.read<ChatHomeCubit>().load();
                                },
                              ),
                            ),
                          ),
                    ],
                  );
        return Scaffold(
          backgroundColor: NColors.surfacePage,
          body: SafeArea(child: body),
          bottomNavigationBar: NBottomNav(
            labels: <String>[for (final Area a in Area.values) s.areaName(a)],
            index: 2,
            onSelected: (int i) {
              if (i != 2) goToArea(context, Area.values[i]);
            },
          ),
        );
      },
    );
  }
}

class _Personalisation extends StatelessWidget {
  const _Personalisation({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: NSpace.xs,
      children: <Widget>[
        Icon(on ? Icons.tune_rounded : Icons.public_rounded, size: NSpace.md, color: NColors.inkMuted),
        Text(on ? s.chatPersonalisedOn : s.chatPersonalisedOff, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
        Semantics(
          link: true,
          child: TextButton(
            onPressed: () => context.push(RouteConstants.privacy),
            child: Text(s.chatPersonalisedSettings),
          ),
        ),
      ],
    );
  }
}

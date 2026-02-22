import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../../../core/state/status.dart';
import '../../../../../design_system/tokens/color_tokens.dart';
import '../../../../../design_system/widgets/health_score_card.dart';
import '../../../../../design_system/widgets/section_tab_chip.dart';
import '../../../../../shared/constants/route_constants.dart';
import '../../../common/presentation/bloc/member_data_state.dart';
import '../bloc/member_home_cubit.dart';

class MemberHomePage extends StatelessWidget {
  const MemberHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MemberHomeCubit>(
      create: (_) => getIt<MemberHomeCubit>()..load(),
      child: BlocBuilder<MemberHomeCubit, MemberDataState>(
        builder: (BuildContext context, MemberDataState state) {
          final bool loading = state.status == Status.loading;
          return Stack(
            children: <Widget>[
              RefreshIndicator(
                onRefresh: () => context.read<MemberHomeCubit>().load(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        SectionTabChip(
                          label: 'Symptoms',
                          onTap: () => context.go(RouteConstants.symptoms),
                        ),
                        const SizedBox(width: 8),
                        SectionTabChip(
                          label: 'Appointments',
                          onTap: () => context.go(RouteConstants.appointments),
                        ),
                        const SizedBox(width: 8),
                        SectionTabChip(
                          label: 'Programs',
                          onTap: () => context.go(RouteConstants.plans),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (loading)
                      const Center(child: CircularProgressIndicator())
                    else
                      const HealthScoreCard(
                        score: 70,
                        riskBand: 'HIGH',
                        bmiText: '31.2 (Obese)',
                        attentionItems: <String>[
                          'spotting',
                          'irregular cycles',
                          'hirsutism',
                          'acne',
                          'hair thinning',
                          'obesity',
                        ],
                      ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Insights',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: ColorTokens.primary,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'You reported symptoms of androgen imbalance. Keep tracking symptoms daily.',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 18,
                bottom: 28,
                child: FloatingActionButton(
                  onPressed: () => context.go(RouteConstants.chatAi),
                  backgroundColor: ColorTokens.primary,
                  child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

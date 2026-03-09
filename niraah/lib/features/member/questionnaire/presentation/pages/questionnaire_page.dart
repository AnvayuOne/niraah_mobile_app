import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../design_system/widgets/app_button.dart';
import '../../../../../design_system/widgets/app_scaffold.dart';
import '../../../../../design_system/widgets/app_text_field.dart';
import '../../../../../design_system/widgets/brand_logo_header.dart';
import '../../../../../design_system/widgets/step_progress_header.dart';
import '../../../../../shared/constants/route_constants.dart';

class QuestionnairePage extends StatefulWidget {
  const QuestionnairePage({super.key});

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  static const List<String> _questions = <String>[
    'Full Name',
    'Age',
    'Height (cm)',
    'Weight (kg)',
    'Cycle length (days)',
    'Any irregular periods?',
    'Acne severity',
    'Hair growth concerns',
    'Hair thinning level',
    'Sleep hours',
    'Stress level',
    'Physical activity days/week',
    'Current medications',
    'Primary health goal',
  ];

  final TextEditingController _answerController = TextEditingController();
  final Map<int, String> _answers = <int, String>{};
  int _currentStep = 1;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _onBack() {
    if (_currentStep == 1) {
      return;
    }
    _answers[_currentStep] = _answerController.text.trim();
    setState(() {
      _currentStep -= 1;
      _answerController.text = _answers[_currentStep] ?? '';
    });
  }

  void _onContinue() {
    _answers[_currentStep] = _answerController.text.trim();
    if (_currentStep == _questions.length) {
      context.go(RouteConstants.plans);
      return;
    }
    setState(() {
      _currentStep += 1;
      _answerController.text = _answers[_currentStep] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              const BrandLogoHeader(showMenu: true),
              const SizedBox(height: 28),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        StepProgressHeader(
                          currentStep: _currentStep,
                          totalSteps: _questions.length,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'PROFILE INFORMATION',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _questions[_currentStep - 1],
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          label: '',
                          controller: _answerController,
                        ),
                        const Spacer(),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: AppButton(
                                label: 'Back',
                                variant: AppButtonVariant.secondary,
                                onPressed: _onBack,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: AppButton(
                                label: _currentStep == _questions.length
                                    ? 'Plan for you'
                                    : 'Continue',
                                onPressed: _onContinue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

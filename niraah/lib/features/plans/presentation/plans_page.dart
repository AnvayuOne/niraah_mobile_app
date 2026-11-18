import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/error_view.dart';
import '../../../design_system/widgets/loading_view.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../design_system/widgets/plan_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/constants/route_constants.dart';
import '../../../shared/helpers/result.dart';
import '../domain/plan.dart';

/// The plans screen (spec 010 §5). Everything shown comes from the plans list.
class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  late Future<Result<PlansOffer>> _offer = getIt<PlansRepository>().offer();

  static String _rupees(int paise) =>
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: paise % 100 == 0 ? 0 : 2).format(paise / 100);

  String _unit(S s, String unit, int count) => switch (unit) {
        'weeks' => s.plansUnitWeeks(count),
        'months' => s.plansUnitMonths(count),
        'years' => s.plansUnitYears(count),
        _ => s.plansUnitDays(count),
      };

  String _line(S s, PlanFeature f) => switch (f.kind) {
        FeatureValueKind.included => f.name,
        FeatureValueKind.unlimited => s.plansUnlimited(f.name),
        FeatureValueKind.limit => s.plansLimit(f.name, f.amount ?? 0, f.period ?? ''),
        FeatureValueKind.quantity => s.plansQuantity(f.name, f.amount ?? 0, f.period ?? ''),
      };

  bool _choosing = false;

  /// Choose a plan (spec 008 §1): locally, with payment skipped for testing, it is active at once and she goes
  /// home; otherwise payment comes later.
  Future<void> _choose(S s, Plan p) async {
    if (_choosing || p.prices.isEmpty) return;
    setState(() => _choosing = true);
    final Result<bool> r = await getIt<PlansRepository>().choose(p.prices.first.id);
    if (!mounted) return;
    setState(() => _choosing = false);
    r.when(
      success: (bool active) => active ? context.go(RouteConstants.home) : ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.plansPaymentLater))),
      failure: (String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Scaffold(
      backgroundColor: NColors.surfacePage,
      body: SafeArea(
        child: FutureBuilder<Result<PlansOffer>>(
          future: _offer,
          builder: (BuildContext context, AsyncSnapshot<Result<PlansOffer>> snap) {
            final Result<PlansOffer>? r = snap.data;
            if (r == null) return LoadingView(label: s.loading);
            if (r case FailureResult<PlansOffer>()) {
              return ErrorView(
                message: s.notConnectedYet,
                retryLabel: s.tryAgain,
                onRetry: () => setState(() => _offer = getIt<PlansRepository>().offer()),
              );
            }
            final PlansOffer offer = (r as Success<PlansOffer>).data;
            return ListView(
              padding: const EdgeInsets.all(NSpace.lg),
              children: <Widget>[
                Semantics(header: true, child: Text(s.plansTitle, style: NType.h2.copyWith(color: NColors.inkPrimary))),
                const SizedBox(height: NSpace.xs),
                Text(s.plansBody, style: NType.body.copyWith(color: NColors.inkSecondary)),
                const SizedBox(height: NSpace.lg),
                for (final Plan p in offer.plans) ...<Widget>[
                  _card(s, offer, p),
                  const SizedBox(height: NSpace.md),
                ],
                // The free plan's own card offers "Continue free" when it is listed.
                if (!offer.plans.any((Plan p) => p.isFree))
                  NSecondaryButton(label: s.plansContinueFree, onPressed: () => context.go(RouteConstants.home)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _card(S s, PlansOffer offer, Plan p) {
    final bool current = p.id == offer.currentPlanId;
    final PlanPrice? price = p.prices.firstOrNull;
    final String priceText = price == null ? s.plansFreePrice : _rupees(price.amountPaise);
    final String priceNote = price == null
        ? s.plansFreeNote
        : s.plansIncludesGst(
            price.renews
                ? s.plansEvery(price.validityCount, _unit(s, price.validityUnit, price.validityCount))
                : s.plansFor(price.validityCount, _unit(s, price.validityUnit, price.validityCount)),
          );
    final bool trial = price != null && price.renews && offer.trialDays > 0;
    final List<String> lines = <String>[for (final PlanFeature f in p.features) _line(s, f), ...p.extraLines];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PlanCard(
          name: current ? '${p.name} · ${s.plansCurrent}' : p.name,
          description: p.description,
          priceText: priceText,
          priceNote: priceNote,
          lines: lines,
          colorToken: p.colorToken,
          badge: p.badge,
          recommendedLabel: p.recommended ? s.plansRecommended : null,
          quietAction: p.isFree || current,
          actionLabel: p.isFree ? s.plansContinueFree : (trial ? s.plansStartTrial(offer.trialDays) : s.plansChoose(p.name)),
          onAction: p.isFree ? () => context.go(RouteConstants.home) : () => _choose(s, p),
        ),
        if (trial)
          Padding(
            padding: const EdgeInsets.fromLTRB(NSpace.sm, NSpace.xs, NSpace.sm, 0),
            child: Text(offer.trialNote, style: NType.bodySm.copyWith(color: NColors.inkMuted)),
          ),
      ],
    );
  }
}

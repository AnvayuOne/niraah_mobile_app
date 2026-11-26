import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/payments/payment_checkout.dart';
import '../../../design_system/tokens/tokens.dart';
import '../../../design_system/widgets/error_view.dart';
import '../../../design_system/widgets/loading_view.dart';
import '../../../design_system/widgets/n_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/area/area_access.dart';
import '../../../shared/area/area_widgets.dart';
import '../../../shared/constants/route_constants.dart';
import '../../../shared/helpers/money.dart';
import '../../../shared/helpers/result.dart';
import '../../../shared/widgets/payment_flow.dart';
import '../../plans/domain/plan.dart';
import '../domain/billing.dart';
import 'manage_plan_cubit.dart';

/// "Manage plan" (spec 010 §5.6; spec 008 §4, §8.6): renewal or end date, price, change plan, cancel saying exactly what
/// she keeps and until when (asked once), undo while she still holds it, and her invoices.
class ManagePlanPage extends StatelessWidget {
  const ManagePlanPage({super.key, this.repository, this.plans, this.gateway});

  final BillingRepository? repository;
  final PlansRepository? plans;
  final PaymentCheckout? gateway;

  @override
  Widget build(BuildContext context) => BlocProvider<ManagePlanCubit>(
        create: (_) => ManagePlanCubit(repository ?? getIt<BillingRepository>())..load(),
        child: _ManagePlanView(plans: plans, gateway: gateway),
      );
}

class _ManagePlanView extends StatelessWidget {
  const _ManagePlanView({this.plans, this.gateway});

  final PlansRepository? plans;
  final PaymentCheckout? gateway;

  String _status(S s, Subscription p) => switch (p.status) {
        'trialing' => s.billStatusTrial,
        'active' => s.billStatusActive,
        'past_due' => s.billStatusPastDue,
        'pending' => s.billStatusPending,
        _ => p.status,
      };

  Future<void> _cancel(BuildContext context, Subscription p) async {
    final S s = S.of(context);
    final ManagePlanCubit cubit = context.read<ManagePlanCubit>();
    final String until = p.renewsAt ?? p.endsAt ?? '';
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (BuildContext d) => AlertDialog(
        title: Text(s.billCancelTitle),
        content: Text(until.isEmpty ? s.billCancelBodyNoDate(p.name) : s.billCancelBody(p.name, shortDate(context, until))),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(s.billKeep)),
          FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(s.billCancelAction)),
        ],
      ),
    );
    if (!(yes ?? false) || !context.mounted) return;
    final PlanActionResult r = await cubit.cancel();
    if (context.mounted) showNote(context, r.ok ? s.billCancelled(shortDate(context, r.endsAt!)) : failureText(r.error!, s.commonLoadError));
  }

  Future<void> _undo(BuildContext context) async {
    final S s = S.of(context);
    final PlanActionResult r = await context.read<ManagePlanCubit>().undo();
    if (context.mounted) showNote(context, r.ok ? s.billUndone : failureText(r.error!, s.commonLoadError));
  }

  Future<void> _change(BuildContext context, Subscription p) async {
    final S s = S.of(context);
    final ManagePlanCubit cubit = context.read<ManagePlanCubit>();
    final String? priceId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ChangeSheet(plans: plans ?? getIt<PlansRepository>(), currentPlanId: p.planId),
    );
    if (priceId == null || !context.mounted) return;
    final PlanActionResult r = await cubit.change(priceId);
    if (!context.mounted) return;
    if (!r.ok) {
      showNote(context, failureText(r.error!, s.commonLoadError));
      return;
    }
    switch (r.change!) {
      case DowngradeScheduled(:final String effectiveAt):
        showNote(context, s.billChangeLater(shortDate(context, effectiveAt)));
      case UpgradeActive():
        showNote(context, s.billChangeDone);
      case UpgradeNeedsPayment(:final int amountPaise, :final Checkout? checkout):
        await _payUpgrade(context, s, cubit, amountPaise, checkout);
    }
  }

  /// An upgrade takes effect on confirmed payment (spec 008 AC14): the amount the server worked out is shown first,
  /// then the gateway's checkout, then the server is asked until it has the verified payment.
  Future<void> _payUpgrade(BuildContext context, S s, ManagePlanCubit cubit, int amountPaise, Checkout? checkout) async {
    final bool go = checkout != null &&
        (await showDialog<bool>(
              context: context,
              builder: (BuildContext d) => AlertDialog(
                title: Text(s.billPayTitle),
                content: Text(s.billPayBody(rupees(amountPaise))),
                actions: <Widget>[
                  TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(s.billKeep)),
                  FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(s.billPay(rupees(amountPaise)))),
                ],
              ),
            ) ??
            false);
    if (!go || !context.mounted) return;
    final PlansRepository repo = plans ?? getIt<PlansRepository>();
    final PaymentResult paid = await runPayment(
      context,
      (void Function() onConfirming) => payAndConfirm(
        gateway: gateway ?? getIt<PaymentCheckout>(),
        checkout: checkout,
        description: s.billTitle,
        onConfirming: onConfirming,
        check: () async {
          final String? id = checkout.subscriptionId;
          if (id == null) return ServerPaymentState.waiting;
          final SubscriptionCheck c = await repo.subscriptionStatus(id);
          return c.confirmed ? ServerPaymentState.confirmed : (c.status == 'ended' ? ServerPaymentState.lapsed : ServerPaymentState.waiting);
        },
      ),
    );
    await cubit.load();
    if (context.mounted) showNote(context, paid.outcome == PaymentOutcome.confirmed ? s.billChangeDone : (paid.outcome == PaymentOutcome.lapsed ? s.payFailed : paymentNote(s, paid)!));
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.billTitle,
      body: BlocBuilder<ManagePlanCubit, ManagePlanState>(
        builder: (BuildContext context, ManagePlanState st) {
          final ManagePlanCubit cubit = context.read<ManagePlanCubit>();
          if (st.status == PlanStatus.loading) return LoadingView(label: s.loading);
          if (st.status == PlanStatus.failure) return ErrorView(message: s.commonLoadError, retryLabel: s.tryAgain, onRetry: cubit.load);
          final Subscription? p = st.subscription;
          return ListView(
            padding: const EdgeInsets.all(NSpace.lg),
            children: <Widget>[
              NCard(
                color: NColors.brandLavenderLight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Semantics(header: true, child: Text(p?.name ?? s.meNoPlan, style: NType.h3.copyWith(color: NColors.inkPrimary))),
                    if (p != null && p.paid) ...<Widget>[
                      Text(_status(s, p), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                      if (p.priceDisplay != null) Text(p.priceDisplay!, style: NType.body.copyWith(color: NColors.inkPrimary)),
                      if (p.cancelled && (p.endsAt ?? p.renewsAt) != null)
                        Text(s.billEndsOn(shortDate(context, (p.endsAt ?? p.renewsAt)!)), style: NType.body.copyWith(color: NColors.inkPrimary))
                      else if (p.retired && p.endsAt != null)
                        Text(s.mePlanRetired(shortDate(context, p.endsAt!)), style: NType.body.copyWith(color: NColors.inkPrimary))
                      else if (p.renewsAt != null)
                        Text((p.renews ?? true) ? s.billRenewsOn(shortDate(context, p.renewsAt!)) : s.billValidUntil(shortDate(context, p.renewsAt!)), style: NType.body.copyWith(color: NColors.inkPrimary)),
                    ] else
                      Text(s.billNoSubscription, style: NType.body.copyWith(color: NColors.inkSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: NSpace.md),
              if (p != null && p.paid) ...<Widget>[
                NSecondaryButton(label: s.billChange, onPressed: st.busy ? null : () => _change(context, p)),
                const SizedBox(height: NSpace.xs),
                if (p.cancelled)
                  NPrimaryButton(label: s.billUndo, loading: st.busy, onPressed: () => _undo(context))
                else
                  TextButton(onPressed: st.busy ? null : () => _cancel(context, p), child: Text(s.billCancelAction)),
              ] else
                NPrimaryButton(label: s.meSeePlans, onPressed: () => context.push(RouteConstants.plans)),
              NSectionTitle(s.billInvoices),
              NCard(
                onTap: () => context.push(RouteConstants.invoices),
                semanticsLabel: s.billInvoicesOpen,
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.receipt_long_outlined, color: NColors.inkSecondary),
                    const SizedBox(width: NSpace.sm),
                    Expanded(child: Text(s.billInvoicesOpen, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600))),
                    const Icon(Icons.chevron_right_rounded, color: NColors.inkMuted),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The plans she can move to, from the plans list (never the free plan or her own).
class _ChangeSheet extends StatefulWidget {
  const _ChangeSheet({required this.plans, required this.currentPlanId});

  final PlansRepository plans;
  final String currentPlanId;

  @override
  State<_ChangeSheet> createState() => _ChangeSheetState();
}

class _ChangeSheetState extends State<_ChangeSheet> {
  late final Future<Result<PlansOffer>> _offer = widget.plans.offer();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return SafeArea(
      child: FutureBuilder<Result<PlansOffer>>(
        future: _offer,
        builder: (BuildContext context, AsyncSnapshot<Result<PlansOffer>> snap) {
          final Result<PlansOffer>? r = snap.data;
          if (r == null) return SizedBox(height: NSpace.xl3 * 2, child: LoadingView(label: s.loading));
          return r.when(
            failure: (String message) => Padding(padding: const EdgeInsets.all(NSpace.lg), child: Text(message)),
            success: (PlansOffer o) {
              final List<(Plan, PlanPrice)> options = <(Plan, PlanPrice)>[
                for (final Plan p in o.plans)
                  if (!p.isFree && p.id != widget.currentPlanId)
                    for (final PlanPrice x in p.prices) (p, x),
              ];
              return ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(NSpace.lg),
                children: <Widget>[
                  Semantics(header: true, child: Text(s.billChange, style: NType.h4.copyWith(color: NColors.inkPrimary))),
                  Text(s.billChangeNote, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                  if (options.isEmpty) Padding(padding: const EdgeInsets.only(top: NSpace.sm), child: Text(s.billNoOtherPlans)),
                  for (final (Plan p, PlanPrice x) in options)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(p.name),
                      subtitle: Text(s.billPriceLine(rupees(x.amountPaise))),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).pop(x.id),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Her invoices and credit notes (spec 008 §8.6), any time, also after her plan has ended (AC30).
class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key, this.repository});

  final BillingRepository? repository;

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  late final BillingRepository _repo = widget.repository ?? getIt<BillingRepository>();
  late Future<List<Invoice>> _list = _repo.invoices();

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.billInvoices,
      body: AsyncBody<List<Invoice>>(
        future: _list,
        onRetry: () => setState(() => _list = _repo.invoices()),
        builder: (BuildContext context, List<Invoice> items) => ListView(
          padding: const EdgeInsets.all(NSpace.lg),
          children: <Widget>[
            if (items.isEmpty) EmptyNote(text: s.billNoInvoices),
            for (final Invoice i in items) ...<Widget>[
              NCard(
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => InvoicePage(repository: _repo, invoiceId: i.id))),
                semanticsLabel: '${i.creditNote ? s.billCreditNote : s.billInvoice} ${i.number}, ${i.totalDisplay}',
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(i.number, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
                          Text('${i.creditNote ? s.billCreditNote : s.billInvoice} · ${shortDate(context, i.issuedAt)}', style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
                        ],
                      ),
                    ),
                    Text(i.totalDisplay, style: NType.body.copyWith(color: NColors.inkPrimary)),
                    const Icon(Icons.chevron_right_rounded, color: NColors.inkMuted),
                  ],
                ),
              ),
              const SizedBox(height: NSpace.xs),
            ],
          ],
        ),
      ),
    );
  }
}

/// One invoice as issued (spec 008 §8.3): seller, buyer, date, each line before tax, the tax and the total she paid.
class InvoicePage extends StatefulWidget {
  const InvoicePage({required this.invoiceId, super.key, this.repository});

  final String invoiceId;
  final BillingRepository? repository;

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  late final BillingRepository _repo = widget.repository ?? getIt<BillingRepository>();
  late Future<Invoice> _invoice = _repo.invoice(widget.invoiceId);

  Widget _row(String label, String value, {bool strong = false}) => Padding(
        padding: const EdgeInsets.only(bottom: NSpace.xxs),
        child: MergeSemantics(
          child: Row(
            children: <Widget>[
              Expanded(child: Text(label, style: NType.body.copyWith(color: NColors.inkSecondary))),
              Text(value, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: strong ? FontWeight.w700 : FontWeight.w400)),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AreaScaffold(
      title: s.billInvoice,
      body: AsyncBody<Invoice>(
        future: _invoice,
        onRetry: () => setState(() => _invoice = _repo.invoice(widget.invoiceId)),
        builder: (BuildContext context, Invoice i) => ListView(
          padding: const EdgeInsets.all(NSpace.lg),
          children: <Widget>[
            Semantics(header: true, child: Text('${i.creditNote ? s.billCreditNote : s.billInvoice} ${i.number}', style: NType.h3.copyWith(color: NColors.inkPrimary))),
            Text(shortDate(context, i.issuedAt), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
            NSectionTitle(s.billFrom),
            Text(i.sellerName ?? s.profileNotSet, style: NType.body.copyWith(color: NColors.inkPrimary)),
            if (i.sellerAddress != null) Text(i.sellerAddress!, style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
            if (i.sellerGstin != null) Text(s.billGstin(i.sellerGstin!), style: NType.bodySm.copyWith(color: NColors.inkSecondary)),
            NSectionTitle(s.billTo),
            Text(i.buyerName ?? s.profileNotSet, style: NType.body.copyWith(color: NColors.inkPrimary)),
            NSectionTitle(s.billLines),
            for (final InvoiceLine l in i.lines) ...<Widget>[
              Text(l.description, style: NType.body.copyWith(color: NColors.inkPrimary, fontWeight: FontWeight.w600)),
              _row(s.billBeforeTax, rupees(l.beforeTaxPaise)),
              _row(s.billTax(i.taxRatePercent.toStringAsFixed(i.taxRatePercent == i.taxRatePercent.roundToDouble() ? 0 : 2)), rupees(l.taxPaise)),
              _row(s.billLineTotal, l.display),
              const Divider(),
            ],
            _row(s.billTotalTax, rupees(i.taxPaise)),
            _row(s.billTotal, i.totalDisplay, strong: true),
          ],
        ),
      ),
    );
  }
}

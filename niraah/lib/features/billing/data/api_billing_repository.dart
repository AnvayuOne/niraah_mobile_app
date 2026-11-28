import '../../../core/network/niraah_api.dart';
import '../../../core/payments/payment_checkout.dart';
import '../domain/billing.dart';

/// Billing on `/api/v1` (spec 008 §4, §8): `GET /me/plan`, `POST /me/subscription/cancel`, `/undo-cancel`, `/change`,
/// `GET /me/invoices`, `GET /me/invoices/{id}`.
class ApiBillingRepository implements BillingRepository {
  ApiBillingRepository(this._api);

  final NiraahApi _api;

  @override
  Future<Subscription?> current() async {
    final ApiResult<Map<String, dynamic>> res = await _api.get('/me/plan');
    if (res is ApiFail<Map<String, dynamic>> && res.status == 404) return null;
    final Map<String, dynamic> r = res.orThrow();
    final Map<String, dynamic>? price = r['price'] as Map<String, dynamic>?;
    return Subscription(
      subscriptionId: r['subscriptionId'] as String?,
      planId: '${r['planId']}',
      name: '${r['name']}',
      status: '${r['status']}',
      priceDisplay: price?['display'] as String?,
      renews: price?['renews'] as bool?,
      renewsAt: r['renewsAt'] as String?,
      endsAt: r['endsAt'] as String?,
      cancelled: r['cancelled'] == true,
      retired: r['retired'] == true,
    );
  }

  @override
  Future<String> cancel() async => '${(await _api.post('/me/subscription/cancel')).orThrow()['endsAt']}';

  @override
  Future<void> undoCancel() async => (await _api.post('/me/subscription/undo-cancel')).orThrow();

  @override
  Future<PlanChange> change(String priceId) async {
    final Map<String, dynamic> r = (await _api.post('/me/subscription/change', <String, dynamic>{'priceId': priceId})).orThrow();
    if (r['kind'] == 'downgrade') return DowngradeScheduled('${r['effectiveAt']}');
    final Map<String, dynamic> checkout = (r['checkout'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    if (checkout['skippedPayment'] == true) return const UpgradeActive();
    return UpgradeNeedsPayment((checkout['amountPaise'] as num?)?.toInt() ?? 0, Checkout.fromJson(checkout));
  }

  @override
  Future<List<Invoice>> invoices() async =>
      <Invoice>[for (final dynamic i in (await _api.get('/me/invoices')).orThrow()['items'] as List<dynamic>) parseInvoice(i as Map<String, dynamic>)];

  @override
  Future<Invoice> invoice(String id) async => parseInvoice((await _api.get('/me/invoices/${Uri.encodeComponent(id)}')).orThrow());

  static Invoice parseInvoice(Map<String, dynamic> i) {
    final Map<String, dynamic> seller = i['seller'] is Map ? Map<String, dynamic>.from(i['seller'] as Map<dynamic, dynamic>) : <String, dynamic>{};
    final Map<String, dynamic> buyer = i['buyer'] is Map ? Map<String, dynamic>.from(i['buyer'] as Map<dynamic, dynamic>) : <String, dynamic>{};
    return Invoice(
      id: '${i['id']}',
      kind: '${i['kind']}',
      number: '${i['number']}',
      issuedAt: '${i['issuedAt']}',
      sellerName: seller['legal_name'] as String?,
      sellerAddress: seller['address'] as String?,
      sellerGstin: seller['gstin'] as String?,
      buyerName: buyer['name'] as String?,
      lines: <InvoiceLine>[
        for (final dynamic l in i['lines'] as List<dynamic>)
          InvoiceLine(
            description: '${(l as Map<String, dynamic>)['description']}',
            beforeTaxPaise: (l['beforeTaxPaise'] as num).toInt(),
            taxPaise: (l['taxPaise'] as num).toInt(),
            totalPaise: (l['totalPaise'] as num).toInt(),
            display: '${l['display']}',
          ),
      ],
      taxRatePercent: (i['taxRatePercent'] as num).toDouble(),
      taxPaise: (i['taxPaise'] as num).toInt(),
      totalPaise: (i['totalPaise'] as num).toInt(),
      totalDisplay: '${i['totalDisplay']}',
    );
  }
}

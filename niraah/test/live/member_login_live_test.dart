// Live check of the member sign-in path against a running niraah-platform
// in local test mode (AUTH_PROVIDER=test, DEV_FIXED_OTP=123456). Runs only when
// LIVE_API is set, e.g. LIVE_API=http://localhost:3000/api/v1 flutter test test/live
// Plain test(): no widget binding, so real HTTP is allowed.
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niraah/core/auth/session_store.dart';
import 'package:niraah/core/network/niraah_api.dart';
import 'package:niraah/features/assessment/data/api_assessment_repository.dart';
import 'package:niraah/features/assessment/domain/assessment_repository.dart';
import 'package:niraah/features/auth/data/api_auth_repository.dart';
import 'package:niraah/features/auth/domain/auth_repository.dart';
import 'package:niraah/features/auth/presentation/pages/account_details_page.dart';
import 'package:niraah/shared/helpers/result.dart';

final String? _base = Platform.environment['LIVE_API'];

void main() {
  test('new member: code, verify, account details, assessment opens', () async {
    final MemorySessionStore store = MemorySessionStore();
    final NiraahApi api = NiraahApi(dio: Dio(BaseOptions(baseUrl: _base!)), store: store);
    final ApiAuthRepository auth = ApiAuthRepository(api);
    final String phone = '+9198${(10000000 + Random().nextInt(89999999))}';

    final Result<void> sent = await auth.requestCode(phone);
    expect(sent, isA<Success<void>>(), reason: '$sent');

    final Result<CodeOutcome> v = await auth.verifyCode(phone, '123456');
    expect(v, isA<Success<CodeOutcome>>(), reason: v is FailureResult<CodeOutcome> ? v.message : '');
    expect((v as Success<CodeOutcome>).data, CodeOutcome.newAccount);
    expect(await store.read(), isNotNull, reason: 'tokens saved');

    final Result<void> details = await auth.saveAccountDetails(
      displayName: 'Priya',
      termsVersion: AccountDetailsPage.termsVersion,
      privacyVersion: AccountDetailsPage.privacyVersion,
    );
    expect(details, isA<Success<void>>(), reason: details is FailureResult<void> ? details.message : '');

    final AssessmentRepository assessment = ApiAssessmentRepository(api);
    final Result<void> consent = await assessment.recordConsent(healthData: true, doctorReview: true, textVersion: 'v1');
    expect(consent, isA<Success<void>>(), reason: consent is FailureResult<void> ? consent.message : '');
    final Result<AssessmentSession> session = await assessment.startOrResume();
    expect(session, isA<Success<AssessmentSession>>(), reason: session is FailureResult<AssessmentSession> ? session.message : '');

    // Signing in again with the same number is a returning member, not a new account.
    final Result<void> again = await auth.requestCode(phone);
    expect(again, isA<Success<void>>());
  }, skip: _base == null ? 'set LIVE_API' : false, timeout: const Timeout(Duration(minutes: 2)));
}

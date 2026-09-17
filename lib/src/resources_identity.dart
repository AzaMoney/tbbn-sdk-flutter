import 'client.dart';

/// Sign-in flows. TBBN is passwordless: every flow sends a one-time code (or magic link) and
/// exchanges it for an access/refresh token pair.
class AuthResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.auth`.
  AuthResource(this._request);

  /// Sends a one-time code to a merchant representative's email address.
  Future<dynamic> requestMerchantOtp(String email) => _request('POST', '/v1/auth/merchant/otp/request', body: {'email': email});

  /// Exchanges a merchant representative's one-time code for tokens.
  Future<dynamic> verifyMerchantOtp(String email, String code) =>
      _request('POST', '/v1/auth/merchant/otp/verify', body: {'email': email, 'code': code});

  /// Sends a one-time code to a seller's email address.
  Future<dynamic> requestSellerOtp(String email) => _request('POST', '/v1/auth/seller/otp/request', body: {'email': email});

  /// Exchanges a seller's one-time code for tokens.
  Future<dynamic> verifySellerOtp(String email, String code) =>
      _request('POST', '/v1/auth/seller/otp/verify', body: {'email': email, 'code': code});

  /// Emails a seller a magic sign-in link.
  Future<dynamic> requestMagicLink(String email) => _request('POST', '/v1/auth/seller/magic-link/request', body: {'email': email});

  /// Exchanges the token from a magic link for tokens.
  Future<dynamic> consumeMagicLink(String token) =>
      _request('GET', '/v1/auth/seller/magic-link/consume?token=${Uri.encodeQueryComponent(token)}');

  /// Exchanges a refresh token for a new access/refresh pair.
  Future<dynamic> refresh(String refreshToken) => _request('POST', '/v1/auth/refresh', body: {'refreshToken': refreshToken});

  /// Revokes a refresh token.
  Future<dynamic> logout(String refreshToken) => _request('POST', '/v1/auth/logout', body: {'refreshToken': refreshToken});

  /// Returns the principal behind the current credential.
  Future<dynamic> me() => _request('GET', '/v1/auth/me');
}

/// Merchant organisations, their onboarding application and their team members.
class MerchantsResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.merchants`.
  MerchantsResource(this._request);

  /// Onboards a new merchant. Every merchant is linked to a business via `businessId`.
  Future<dynamic> create(Map<String, dynamic> input) => _request('POST', '/v1/merchants', body: input);

  /// Fetches a merchant by id.
  Future<dynamic> get(String id) => _request('GET', '/v1/merchants/$id');

  /// Updates a merchant's profile fields.
  Future<dynamic> update(String id, Map<String, dynamic> patch, {String? idempotencyKey}) =>
      _request('PATCH', '/v1/merchants/$id', body: patch, extraHeaders: idempotencyHeader(idempotencyKey));

  /// Submits the merchant's application for review, optionally with supporting documents.
  Future<dynamic> submitApplication(String id, {Map<String, dynamic>? submittedDocs}) =>
      _request('POST', '/v1/merchants/$id/submit-application', body: {'submittedDocs': submittedDocs});

  /// Returns the review status of the merchant's application.
  Future<dynamic> applicationStatus(String id) => _request('GET', '/v1/merchants/$id/application-status');

  /// Invites a team member to the merchant with the given role.
  Future<dynamic> inviteUser(String id, String email, String role, {String? idempotencyKey}) => _request(
        'POST',
        '/v1/merchants/$id/users/invite',
        body: {'email': email, 'role': role},
        extraHeaders: idempotencyHeader(idempotencyKey),
      );

  /// Lists the merchant's team members.
  Future<dynamic> listUsers(String id) => _request('GET', '/v1/merchants/$id/users');

  /// Changes a team member's role.
  Future<dynamic> changeRole(String id, String userId, String role, {String? idempotencyKey}) => _request(
        'PATCH',
        '/v1/merchants/$id/users/$userId/role',
        body: {'role': role},
        extraHeaders: idempotencyHeader(idempotencyKey),
      );
}

/// Merchant API keys. The full key is returned exactly once, at creation or rotation.
class ApiKeysResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.apiKeys`.
  ApiKeysResource(this._request);

  /// Issues a new key for [merchantId] in the given [environment] (`SANDBOX` or `PRODUCTION`)
  /// with the given [scopes].
  Future<dynamic> create(String merchantId, String environment, List<String> scopes, {String? idempotencyKey}) => _request(
        'POST',
        '/v1/api-keys',
        body: {'merchantId': merchantId, 'environment': environment, 'scopes': scopes},
        extraHeaders: idempotencyHeader(idempotencyKey),
      );

  /// Lists a merchant's keys (prefixes only, never the full secret).
  Future<dynamic> list(String merchantId) => _request('GET', '/v1/api-keys?merchantId=$merchantId');

  /// Rotates a key, returning the replacement's full value once.
  Future<dynamic> rotate(String id, {String? idempotencyKey}) =>
      _request('POST', '/v1/api-keys/$id/rotate', extraHeaders: idempotencyHeader(idempotencyKey));

  /// Revokes a key immediately.
  Future<dynamic> revoke(String id) => _request('DELETE', '/v1/api-keys/$id');
}

/// Sellers a merchant tracks. Verifying a seller under your merchant links your reference for
/// them to their TBBN identity, so trades can be attributed across merchants.
class SellersResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.sellers`.
  SellersResource(this._request);

  /// Verifies (creates or attributes) a seller under your merchant.
  Future<dynamic> verify(Map<String, dynamic> input, {String? idempotencyKey}) =>
      _request('POST', '/merchant/sellers/verify', body: input, extraHeaders: idempotencyHeader(idempotencyKey));

  /// Starts confirmation of a cross-merchant identity match.
  Future<dynamic> requestLinkOtp(String linkRequestId) =>
      _request('POST', '/v1/sellers/link/otp/request', body: {'linkRequestId': linkRequestId});

  /// Confirms the email step of an identity-link request.
  Future<dynamic> verifyEmail(String linkRequestId, String code) =>
      _request('POST', '/v1/sellers/link/otp/verify-email', body: {'linkRequestId': linkRequestId, 'code': code});

  /// Confirms the phone step of an identity-link request.
  Future<dynamic> verifyPhone(String linkRequestId, String code) =>
      _request('POST', '/v1/sellers/link/otp/verify-phone', body: {'linkRequestId': linkRequestId, 'code': code});

  /// Fetches a seller by id.
  Future<dynamic> get(String id) => _request('GET', '/v1/sellers/$id');

  /// Removes the link between a seller and [merchantId].
  Future<dynamic> unlink(String id, String merchantId, {String? idempotencyKey}) =>
      _request('POST', '/v1/sellers/$id/unlink', body: {'merchantId': merchantId}, extraHeaders: idempotencyHeader(idempotencyKey));
}

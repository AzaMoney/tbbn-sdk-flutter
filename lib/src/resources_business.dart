import 'client.dart';

/// Businesses — the account that owns locations (Branches), linked Merchants, billing and TBBN
/// Space hosting.
class BusinessesResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.businesses`.
  BusinessesResource(this._request);

  /// Creates a Business. `type` is INDIVIDUAL or REGISTERED (REGISTERED also needs `legalName`);
  /// only a verified REGISTERED Business can run a Merchant.
  Future<dynamic> create(Map<String, dynamic> input) => _request('POST', '/v1/businesses', body: input);

  /// Fetches a Business by id.
  Future<dynamic> get(String id) => _request('GET', '/v1/businesses/$id');

  /// Businesses you own.
  Future<dynamic> list() => _request('GET', '/v1/businesses');

  /// Updates a Business. [stepUpToken] is required once it is verified.
  Future<dynamic> update(String id, Map<String, dynamic> patch, {String? stepUpToken}) => _request('PATCH', '/v1/businesses/$id',
      body: patch, extraHeaders: stepUpToken != null ? {'x-tbbn-step-up-token': stepUpToken} : null);

  /// The Business's team and their roles.
  Future<dynamic> listUsers(String businessId) => _request('GET', '/v1/businesses/$businessId/business-users');

  /// The team's invitations waiting for an answer.
  Future<dynamic> listInvitations(String businessId) => _request('GET', '/v1/businesses/$businessId/invitations');
}

/// A Business's locations.
class BranchesResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.branches`.
  BranchesResource(this._request);

  /// Adds a location.
  Future<dynamic> create(String businessId, Map<String, dynamic> input) =>
      _request('POST', '/v1/businesses/$businessId/branches', body: input);

  /// Lists a Business's locations.
  Future<dynamic> list(String businessId) => _request('GET', '/v1/businesses/$businessId/branches');

  /// Updates a location.
  Future<dynamic> update(String id, Map<String, dynamic> patch) => _request('PATCH', '/v1/branches/$id', body: patch);

  /// Removes a location.
  Future<dynamic> delete(String id) => _request('DELETE', '/v1/branches/$id');

  /// Turns TBBN Space on or off for a location: NOT_ENABLED or SPACE_ENABLED.
  Future<dynamic> setSpaceStatus(String id, String spaceStatus) =>
      _request('POST', '/v1/branches/$id/space-status', body: {'spaceStatus': spaceStatus});

  /// Creates or updates many locations at once, keyed by each one's `externalLocationId`.
  Future<dynamic> bulkUpsert(String businessId, List<Map<String, dynamic>> locations) =>
      _request('POST', '/v1/businesses/$businessId/branches/bulk', body: {'locations': locations});
}

/// Links between a Business and the Merchants it runs.
class BusinessMerchantLinksResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.businessMerchantLinks`.
  BusinessMerchantLinksResource(this._request);

  /// Links a Merchant to a Business.
  Future<dynamic> create(String businessId, String merchantId) =>
      _request('POST', '/v1/businesses/$businessId/merchant-links', body: {'merchantId': merchantId});

  /// Lists a Business's linked Merchants.
  Future<dynamic> listForBusiness(String businessId) => _request('GET', '/v1/businesses/$businessId/merchant-links');

  /// Removes a link.
  Future<dynamic> revoke(String businessId, String linkId) =>
      _request('POST', '/v1/businesses/$businessId/merchant-links/$linkId/revoke');
}

/// TBBN Space — search, booking terms and bookings. Construct the client with a Space API key
/// (`sk_space_...`) to book for clients without a TBBN account.
class SpaceResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.space`.
  SpaceResource(this._request);

  /// Searches Spaces. Query keys include country, region, category, lat/lng, radiusMiles, query,
  /// minCapacity, amenity, sortBy and limit.
  Future<dynamic> search([Map<String, dynamic> query = const {}]) => _request('GET', withQuery('/v1/space/search', query));

  /// Lists the Spaces at a location.
  Future<dynamic> listSpaces(String branchId) => _request('GET', '/v1/space/branches/$branchId/spaces');

  /// Fetches a Space by id.
  Future<dynamic> getSpace(String id) => _request('GET', '/v1/space/spaces/$id');

  /// The refund and no-show policy, processing fee and terms a guest agrees to.
  Future<dynamic> bookingTerms(String spaceId) => _request('GET', '/v1/space/spaces/$spaceId/booking-terms');

  /// Bookable slots ('from': YYYY-MM-DD in the Space's time zone, 'days': up to 62). A booking
  /// must start on an AVAILABLE slot.
  Future<dynamic> availability(String spaceId, [Map<String, dynamic> query = const {}]) =>
      _request('GET', withQuery('/v1/space/spaces/$spaceId/availability', query));

  /// Books a Space. A member booking must include `acceptTerms: true`.
  Future<dynamic> createBooking(Map<String, dynamic> input) => _request('POST', '/v1/space/bookings', body: input);

  /// Lists bookings (by `branchId`, `spaceId`, `bookedByUserId` or `bookedByBusinessId`).
  Future<dynamic> listBookings(Map<String, dynamic> query) => _request('GET', withQuery('/v1/space/bookings', query));

  /// A location's spot board: who should be in each spot now, who's next, who's arriving.
  Future<dynamic> spotBoard(String branchId) => _request('GET', '/v1/space/branches/$branchId/spot-board');

  /// The amount to pay and how.
  Future<dynamic> paymentInfo(String bookingId, {String? token}) =>
      _request('GET', withQuery('/v1/space/bookings/$bookingId/payment-info', {'token': token}));

  /// Cancels a booking under the host's refund policy.
  Future<dynamic> cancelBooking(String bookingId, {String? token}) =>
      _request('POST', withQuery('/v1/space/bookings/$bookingId/cancel', {'token': token}));

  /// Moves a booking to another free time, within the host's reschedule policy.
  Future<dynamic> rescheduleBooking(String bookingId, String scheduledAt, {String? token}) =>
      _request('POST', withQuery('/v1/space/bookings/$bookingId/reschedule', {'token': token}), body: {'scheduledAt': scheduledAt});

  /// The host cancels; the guest is refunded in full.
  Future<dynamic> hostCancelBooking(String bookingId, String reason) =>
      _request('POST', '/v1/space/bookings/$bookingId/host-cancel', body: {'reason': reason});
}

/// A scheduled catalog feed from your own feed URL.
class MerchantFeedResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.merchantFeed`.
  MerchantFeedResource(this._request);

  /// Your feed settings.
  Future<dynamic> get() => _request('GET', '/v1/merchant/feed-source');

  /// Sets your feed URL, format and default seller.
  Future<dynamic> set(Map<String, dynamic> input) => _request('POST', '/v1/merchant/feed-source', body: input);

  /// Fetches the feed now instead of waiting for the next scheduled run.
  Future<dynamic> fetchNow() => _request('POST', '/v1/merchant/feed-source/fetch-now');
}

/// Your merchant's OAuth clients for seller account linking.
class OAuthClientsResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.oauthClients`.
  OAuthClientsResource(this._request);

  /// Registers an OAuth client.
  Future<dynamic> create(String merchantId, List<String> redirectUris, {String? idempotencyKey}) => _request('POST', '/v1/oauth-clients',
      body: {'merchantId': merchantId, 'redirectUris': redirectUris}, extraHeaders: idempotencyHeader(idempotencyKey));

  /// Lists your OAuth clients.
  Future<dynamic> list(String merchantId) => _request('GET', withQuery('/v1/oauth-clients', {'merchantId': merchantId}));

  /// Issues a new client secret.
  Future<dynamic> rotateSecret(String id, {String? idempotencyKey}) =>
      _request('POST', '/v1/oauth-clients/$id/rotate-secret', extraHeaders: idempotencyHeader(idempotencyKey));

  /// Revokes an OAuth client.
  Future<dynamic> revoke(String id) => _request('DELETE', '/v1/oauth-clients/$id');
}

/// Seller account linking (OAuth 2.0). Call [token] from your backend only.
class OAuthLinkResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.oauthLink`.
  OAuthLinkResource(this._request);

  /// Public details of an OAuth client.
  Future<dynamic> getClient(String clientId) => _request('GET', '/v1/link/oauth/clients/$clientId');

  /// Exchanges an authorization code for a seller link.
  Future<dynamic> token(String code, String clientId, String clientSecret, String redirectUri, {String? codeVerifier}) =>
      _request('POST', '/v1/link/oauth/token', body: {
        'grant_type': 'authorization_code',
        'code': code,
        'client_id': clientId,
        'client_secret': clientSecret,
        'redirect_uri': redirectUri,
        if (codeVerifier != null) 'code_verifier': codeVerifier,
      });
}

/// 1–5 star reviews, earned by a completed trade or Space booking.
class ReviewsResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.reviews`.
  ReviewsResource(this._request);

  /// Leaves a review.
  Future<dynamic> create(Map<String, dynamic> input) => _request('POST', '/v1/reputation/reviews', body: input);

  /// Reviews of a merchant.
  Future<dynamic> forMerchant(String merchantId) => _request('GET', '/v1/reputation/merchants/$merchantId/reviews');

  /// Reviews of a Space location.
  Future<dynamic> forBranch(String branchId) => _request('GET', '/v1/reputation/branches/$branchId/reviews');
}

/// Live platform status.
class StatusResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.status`.
  StatusResource(this._request);

  /// Status of every product area (public, no credential needed).
  Future<dynamic> get() => _request('GET', '/v1/status');
}

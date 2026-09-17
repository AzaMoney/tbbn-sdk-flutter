import 'client.dart';

/// Settlement computation. Trade value is `original price + requested amount − willing to pay`
/// for each side; the difference is what one party owes the other in cash.
class TradeEngineResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.tradeEngine`.
  TradeEngineResource(this._request);

  /// Computes the settlement for a proposed set of listings on each side.
  Future<dynamic> computeSettlement(Map<String, dynamic> input) => _request('POST', '/v1/trade-engine/settlement', body: input);
}

/// Supported currencies and conversion.
class CurrencyResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.currency`.
  CurrencyResource(this._request);

  /// Lists the currencies listings may be priced in.
  Future<dynamic> supported() => _request('GET', '/v1/currency/supported');

  /// Converts [amount] from one currency code to another.
  Future<dynamic> convert(double amount, String from, String to) =>
      _request('POST', '/v1/currency/convert', body: {'amount': amount, 'from': from, 'to': to});
}

/// Reference data for countries and languages, plus phone-number normalisation.
class LocalizationResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.localization`.
  LocalizationResource(this._request);

  /// Lists supported countries.
  Future<dynamic> countries() => _request('GET', '/v1/localization/countries');

  /// Lists supported languages.
  Future<dynamic> languages() => _request('GET', '/v1/localization/languages');

  /// Normalises a phone number to E.164.
  Future<dynamic> normalizePhone(String phone) => _request('POST', '/v1/localization/normalize-phone', body: {'phone': phone});
}

/// Finding listings that could be traded for one another.
class MatchingResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.matching`.
  MatchingResource(this._request);

  /// Returns listings that match what [listingId]'s seller wants, best first.
  Future<dynamic> candidates(String listingId, {int? limit}) =>
      _request('POST', '/v1/matching/candidates', body: {'listingId': listingId, 'limit': limit});

  /// Scores how well two specific listings match each other.
  Future<dynamic> score(String listingIdA, String listingIdB) =>
      _request('POST', '/v1/matching/score', body: {'listingIdA': listingIdA, 'listingIdB': listingIdB});
}

/// Personalised listing recommendations.
class RecommendationsResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.recommendations`.
  RecommendationsResource(this._request);

  /// Recommends listings for [sellerId] based on their listings and wants.
  Future<dynamic> forSeller(String sellerId, {int? limit}) =>
      _request('GET', withQuery('/v1/recommendations/sellers/$sellerId', {'limit': limit}));
}

/// Offers — one seller proposing a set of their listings for a set of another's.
///
/// `actingSellerId` on the action methods names the seller performing the action; the
/// credential you present must be entitled to act for that seller.
class OffersResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.offers`.
  OffersResource(this._request);

  /// Creates an offer.
  Future<dynamic> create(Map<String, dynamic> input) => _request('POST', '/v1/offers', body: input);

  /// Lists a seller's offers. [direction] is `sent`, `received` or `all`.
  Future<dynamic> list(String sellerId, {String direction = 'all'}) =>
      _request('GET', withQuery('/v1/offers', {'sellerId': sellerId, 'direction': direction}));

  /// Fetches an offer by id.
  Future<dynamic> get(String id) => _request('GET', '/v1/offers/$id');

  /// Accepts an offer, which opens a trade session.
  Future<dynamic> accept(String id, String actingSellerId) =>
      _request('POST', '/v1/offers/$id/accept', body: {'actingSellerId': actingSellerId});

  /// Rejects an offer.
  Future<dynamic> reject(String id, String actingSellerId) =>
      _request('POST', '/v1/offers/$id/reject', body: {'actingSellerId': actingSellerId});

  /// Withdraws an offer you sent.
  Future<dynamic> cancel(String id, String actingSellerId) =>
      _request('POST', '/v1/offers/$id/cancel', body: {'actingSellerId': actingSellerId});

  /// Responds to an offer with a counter-proposal.
  Future<dynamic> counter(String id, Map<String, dynamic> input) => _request('POST', '/v1/offers/$id/counter', body: input);
}

/// Trade sessions — the lifecycle of an accepted offer through checkout and fulfilment.
class TradeSessionsResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.tradeSessions`.
  TradeSessionsResource(this._request);

  /// Lists a seller's trade sessions.
  Future<dynamic> list(String sellerId) => _request('GET', withQuery('/v1/trade-sessions', {'sellerId': sellerId}));

  /// Fetches a trade session by id.
  Future<dynamic> get(String id) => _request('GET', '/v1/trade-sessions/$id');

  /// Cancels a trade session.
  Future<dynamic> cancel(String id, String actingSellerId, {String? reason}) =>
      _request('POST', '/v1/trade-sessions/$id/cancel', body: {'actingSellerId': actingSellerId, 'reason': reason});
}

/// Checkout reporting. Each side of a trade pays on its own merchant's checkout; the merchant
/// then reports payment and fulfilment here so the session can progress.
class CheckoutResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.checkout`.
  CheckoutResource(this._request);

  /// Reports a payment outcome for one side of a trade session.
  Future<dynamic> paymentWebhook(Map<String, dynamic> input) => _request('POST', '/v1/checkout/webhooks/payment', body: input);

  /// Reports a fulfilment (shipping) update for one side of a trade session.
  Future<dynamic> fulfillmentWebhook(Map<String, dynamic> input) => _request('POST', '/v1/checkout/webhooks/fulfillment', body: input);

  /// Marks a trade session complete once both sides have paid and fulfilled.
  Future<dynamic> complete(String tradeSessionId) => _request('POST', '/v1/checkout/trade-sessions/$tradeSessionId/complete');

  /// Lists the payment records for a trade session, one per side.
  Future<dynamic> payments(String tradeSessionId) =>
      _request('GET', withQuery('/v1/checkout/payments', {'tradeSessionId': tradeSessionId}));
}

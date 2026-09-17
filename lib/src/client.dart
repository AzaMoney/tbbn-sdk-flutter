import 'dart:convert';
import 'package:http/http.dart' as http;

import 'resources_identity.dart';
import 'resources_listings.dart';
import 'resources_trading.dart';
import 'resources_platform.dart';

/// Thrown for any non-2xx API response.
///
/// Mirrors the `{ "error": { "code", "message", "requestId" } }` envelope every TBBN endpoint
/// returns on failure. Quote [requestId] when contacting support about a specific call.
class TbbnApiException implements Exception {
  /// HTTP status code of the failed response.
  final int status;

  /// Machine-readable error code, e.g. `VALIDATION_ERROR` or `FORBIDDEN`.
  final String code;

  /// Human-readable description of what went wrong.
  final String message;

  /// Server-side request identifier, when the response carried one.
  final String? requestId;

  /// Creates an exception from the pieces of an API error envelope.
  TbbnApiException(this.status, this.code, this.message, this.requestId);

  @override
  String toString() => 'TbbnApiException($status, $code): $message';
}

/// Signature of the request function every resource class is handed, so the HTTP
/// implementation lives in exactly one place.
typedef RequestFn = Future<dynamic> Function(
  String method,
  String path, {
  dynamic body,
  Map<String, String>? extraHeaders,
});

/// Client for the TBBN Platform API.
///
/// Construct it once with either a merchant API key (`sk_live_…` / `sk_sandbox_…`) or a
/// session access token, then call methods on the resource groups it exposes:
///
/// ```dart
/// final client = TbbnClient(baseUrl: 'https://api.tbbnetwork.com', apiKey: 'sk_sandbox_...');
/// final listing = await client.listings.upsert({...});
/// ```
///
/// Responses are decoded JSON (`Map<String, dynamic>` / `List`), not typed models; every
/// method returns `Future<dynamic>`. Non-2xx responses throw [TbbnApiException].
class TbbnClient {
  /// API origin, e.g. `https://api.tbbnetwork.com`.
  final String baseUrl;

  /// Merchant API key. Takes precedence over [accessToken] when both are set.
  final String? apiKey;

  /// Session access token for a signed-in user, used when [apiKey] is not set.
  final String? accessToken;

  final http.Client _http;

  /// Sign-in flows for merchant representatives and marketplace members.
  late final AuthResource auth;

  /// Merchant organisations, onboarding and team members.
  late final MerchantsResource merchants;

  /// Merchant API keys.
  late final ApiKeysResource apiKeys;

  /// Sellers a merchant tracks, and their cross-merchant identity.
  late final SellersResource sellers;

  /// A merchant's listings and the items each seller wants in return.
  late final ListingsResource listings;

  /// Categories, subcategories and brands.
  late final CatalogResource catalog;

  /// Image ingestion.
  late final MediaResource media;

  /// The public, cross-merchant listing directory.
  late final DirectoryResource directory;

  /// Listing search.
  late final SearchResource search;

  /// Settlement computation for a proposed trade.
  late final TradeEngineResource tradeEngine;

  /// Supported currencies and conversion.
  late final CurrencyResource currency;

  /// Countries, languages and phone-number normalisation.
  late final LocalizationResource localization;

  /// Trade-match candidates and scoring.
  late final MatchingResource matching;

  /// Personalised listing recommendations.
  late final RecommendationsResource recommendations;

  /// Offers between sellers.
  late final OffersResource offers;

  /// Trade sessions opened from an accepted offer.
  late final TradeSessionsResource tradeSessions;

  /// Checkout, payment and fulfilment reporting for a trade session.
  late final CheckoutResource checkout;

  /// Subscription billing and usage.
  late final BillingResource billing;

  /// In-app notifications.
  late final NotificationsResource notifications;

  /// Outbound webhook subscriptions and deliveries.
  late final WebhooksResource webhooks;

  /// The audit trail.
  late final AuditLogsResource auditLogs;

  /// Content-moderation flags.
  late final ModerationResource moderation;

  /// Fraud signals.
  late final FraudResource fraud;

  /// Seller reputation.
  late final ReputationResource reputation;

  /// Analytics for your own merchant.
  late final AnalyticsResource analytics;

  /// Feature flags.
  late final FeaturesResource features;

  /// Sandbox provisioning and fixtures.
  late final SandboxResource sandbox;

  /// Creates a client. Pass [httpClient] to supply your own `package:http` client (for
  /// proxies, timeouts or testing); otherwise one is created and owned by this instance.
  TbbnClient({required this.baseUrl, this.apiKey, this.accessToken, http.Client? httpClient})
      : _http = httpClient ?? http.Client() {
    auth = AuthResource(_request);
    merchants = MerchantsResource(_request);
    apiKeys = ApiKeysResource(_request);
    sellers = SellersResource(_request);
    listings = ListingsResource(_request);
    catalog = CatalogResource(_request);
    media = MediaResource(_request);
    directory = DirectoryResource(_request);
    search = SearchResource(_request);
    tradeEngine = TradeEngineResource(_request);
    currency = CurrencyResource(_request);
    localization = LocalizationResource(_request);
    matching = MatchingResource(_request);
    recommendations = RecommendationsResource(_request);
    offers = OffersResource(_request);
    tradeSessions = TradeSessionsResource(_request);
    checkout = CheckoutResource(_request);
    billing = BillingResource(_request);
    notifications = NotificationsResource(_request);
    webhooks = WebhooksResource(_request);
    auditLogs = AuditLogsResource(_request);
    moderation = ModerationResource(_request);
    fraud = FraudResource(_request);
    reputation = ReputationResource(_request);
    analytics = AnalyticsResource(_request);
    features = FeaturesResource(_request);
    sandbox = SandboxResource(_request);
  }

  Future<dynamic> _request(String method, String path, {dynamic body, Map<String, String>? extraHeaders}) async {
    final headers = <String, String>{'Content-Type': 'application/json', ...?extraHeaders};
    final token = apiKey ?? accessToken;
    if (token != null) headers['Authorization'] = 'Bearer $token';

    final uri = Uri.parse('$baseUrl$path');
    final encodedBody = body != null ? jsonEncode(body) : null;

    late http.Response response;
    switch (method) {
      case 'GET':
        response = await _http.get(uri, headers: headers);
      case 'POST':
        response = await _http.post(uri, headers: headers, body: encodedBody);
      case 'PUT':
        response = await _http.put(uri, headers: headers, body: encodedBody);
      case 'PATCH':
        response = await _http.patch(uri, headers: headers, body: encodedBody);
      case 'DELETE':
        response = await _http.delete(uri, headers: headers, body: encodedBody);
      default:
        throw ArgumentError('Unsupported method: $method');
    }

    if (response.statusCode == 204) return null;

    dynamic data;
    try {
      data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } catch (_) {
      data = null;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = (data is Map) ? data['error'] as Map<String, dynamic>? ?? {} : {};
      throw TbbnApiException(
        response.statusCode,
        error['code'] as String? ?? 'UNKNOWN_ERROR',
        error['message'] as String? ?? response.reasonPhrase ?? 'Unknown error',
        error['requestId'] as String?,
      );
    }

    return data;
  }

  /// Closes the underlying HTTP client. Call this when you are done with the instance.
  void close() => _http.close();
}

/// Builds the `Idempotency-Key` header for [key], or an empty map when no key is given.
Map<String, String> idempotencyHeader(String? key) => key != null ? {'Idempotency-Key': key} : {};

/// Appends the non-null entries of [query] to [path] as URL-encoded query parameters.
String withQuery(String path, Map<String, dynamic> query) {
  final params = query.entries.where((e) => e.value != null);
  if (params.isEmpty) return path;
  final qs = params.map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value.toString())}').join('&');
  return '$path?$qs';
}

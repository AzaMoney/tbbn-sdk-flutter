import 'client.dart';

/// Subscription billing and metered usage for a merchant's plan.
class BillingResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.billing`.
  BillingResource(this._request);

  /// Starts a subscription.
  Future<dynamic> createSubscription(Map<String, dynamic> input) => _request('POST', '/v1/billing/subscriptions', body: input);

  /// Fetches the subscription for [merchantId].
  Future<dynamic> getSubscription(String merchantId) => _request('GET', '/v1/billing/subscriptions/$merchantId');

  /// Moves the subscription to a different plan tier.
  Future<dynamic> changeTier(String merchantId, String tier) =>
      _request('POST', '/v1/billing/subscriptions/$merchantId/change-tier', body: {'tier': tier});

  /// Cancels the subscription at the end of the current period.
  Future<dynamic> cancelSubscription(String merchantId) => _request('POST', '/v1/billing/subscriptions/$merchantId/cancel');

  /// Records a usage event.
  Future<dynamic> recordUsage(Map<String, dynamic> input) => _request('POST', '/v1/billing/usage', body: input);

  /// Summarises usage for a billing period (defaults to the current one).
  Future<dynamic> usageSummary(String merchantId, {String? billingPeriodRef}) =>
      _request('GET', withQuery('/v1/billing/usage/$merchantId', {'billingPeriodRef': billingPeriodRef}));
}

/// In-app notifications.
class NotificationsResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.notifications`.
  NotificationsResource(this._request);

  /// Lists a user's notifications.
  Future<dynamic> list(String userId) => _request('GET', withQuery('/v1/notifications', {'userId': userId}));

  /// Marks a notification as read.
  Future<dynamic> markRead(String id) => _request('POST', '/v1/notifications/$id/read');
}

/// Outbound webhooks — subscriptions to platform events and the record of each delivery.
/// Verify inbound deliveries with [verifyWebhookSignature].
class WebhooksResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.webhooks`.
  WebhooksResource(this._request);

  /// Subscribes an HTTPS endpoint to a set of event types.
  Future<dynamic> createSubscription(Map<String, dynamic> input) => _request('POST', '/v1/webhooks/subscriptions', body: input);

  /// Lists a merchant's subscriptions.
  Future<dynamic> listSubscriptions(String merchantId) =>
      _request('GET', withQuery('/v1/webhooks/subscriptions', {'merchantId': merchantId}));

  /// Disables a subscription without deleting its delivery history.
  Future<dynamic> disableSubscription(String id, String merchantId) =>
      _request('POST', '/v1/webhooks/subscriptions/$id/disable', body: {'merchantId': merchantId});

  /// Lists delivery attempts, optionally for one subscription.
  Future<dynamic> listDeliveries({String? subscriptionId}) =>
      _request('GET', withQuery('/v1/webhooks/deliveries', {'subscriptionId': subscriptionId}));

  /// Re-sends a delivery.
  Future<dynamic> replayDelivery(String id) => _request('POST', '/v1/webhooks/deliveries/$id/replay');
}

/// The audit trail of changes made through the API.
class AuditLogsResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.auditLogs`.
  AuditLogsResource(this._request);

  /// Lists audit entries, filtered by the optional [query] parameters.
  Future<dynamic> list([Map<String, dynamic>? query]) => _request('GET', withQuery('/v1/audit-logs', query ?? {}));
}

/// Content-moderation flags raised on listings and messages.
class ModerationResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.moderation`.
  ModerationResource(this._request);

  /// Lists flags, filtered by the optional [query] parameters.
  Future<dynamic> listFlags([Map<String, dynamic>? query]) => _request('GET', withQuery('/v1/moderation/flags', query ?? {}));

  /// Fetches a flag by id.
  Future<dynamic> getFlag(String id) => _request('GET', '/v1/moderation/flags/$id');

  /// Records a review decision on a flag.
  Future<dynamic> reviewFlag(String id, String reviewedBy, String decision) =>
      _request('POST', '/v1/moderation/flags/$id/review', body: {'reviewedBy': reviewedBy, 'decision': decision});
}

/// Fraud signals detected on trading activity.
class FraudResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.fraud`.
  FraudResource(this._request);

  /// Lists signals, filtered by the optional [query] parameters.
  Future<dynamic> listSignals([Map<String, dynamic>? query]) => _request('GET', withQuery('/v1/fraud/signals', query ?? {}));
}

/// Seller reputation.
class ReputationResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.reputation`.
  ReputationResource(this._request);

  /// Returns a seller's reputation score and its inputs.
  Future<dynamic> getScore(String sellerId) => _request('GET', '/v1/reputation/sellers/$sellerId');
}

/// Analytics for your own merchant.
class AnalyticsResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.analytics`.
  AnalyticsResource(this._request);

  /// Trade-flow overview (volume, completion and acceptance rates) for a date range.
  Future<dynamic> overview([Map<String, dynamic>? query]) => _request('GET', withQuery('/v1/analytics/overview', query ?? {}));
}

/// Feature flags.
class FeaturesResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.features`.
  FeaturesResource(this._request);

  /// Creates or updates a flag.
  Future<dynamic> upsert(Map<String, dynamic> input) => _request('POST', '/v1/features', body: input);

  /// Lists flags, optionally scoped to a merchant.
  Future<dynamic> list({String? merchantId}) => _request('GET', withQuery('/v1/features', {'merchantId': merchantId}));

  /// Checks whether a flag is enabled.
  Future<dynamic> check(String key, {String? merchantId}) =>
      _request('GET', withQuery('/v1/features/$key/check', {'merchantId': merchantId}));
}

/// Sandbox helpers for integration testing.
class SandboxResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.sandbox`.
  SandboxResource(this._request);

  /// Provisions a throwaway sandbox merchant.
  Future<dynamic> provisionMerchant({String? displayName}) =>
      _request('POST', '/v1/sandbox/merchants', body: {'displayName': displayName});

  /// Returns fixture data you can trade against in the sandbox.
  Future<dynamic> fixtures() => _request('GET', '/v1/sandbox/fixtures');
}

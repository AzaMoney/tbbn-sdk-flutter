import 'client.dart';

/// TBBN's own plan and usage billing, per Business — never trade money. Every method takes a
/// Business id.
class BillingResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.billing`.
  BillingResource(this._request);

  /// Starts a plan (`businessId`, `billingEmail`, `tier`, optional `interval` MONTH/YEAR). A paid
  /// plan returns a Stripe Checkout `checkoutUrl`.
  Future<dynamic> createSubscription(Map<String, dynamic> input) => _request('POST', '/v1/billing/subscriptions', body: input);

  /// Fetches the Business's subscription.
  Future<dynamic> getSubscription(String businessId) => _request('GET', '/v1/billing/subscriptions/$businessId');

  /// Whether service is paused (unpaid invoice or a usage balance below zero).
  Future<dynamic> suspension(String businessId) => _request('GET', '/v1/billing/subscriptions/$businessId/suspension');

  /// Upgrade (charged now) or downgrade (at period end); [interval] is MONTH or YEAR.
  Future<dynamic> changePlan(String businessId, String tier, {String? interval}) =>
      _request('POST', '/v1/billing/subscriptions/$businessId/change-plan', body: {'tier': tier, 'interval': interval});

  /// Moves the subscription to a different plan tier.
  Future<dynamic> changeTier(String businessId, String tier) =>
      _request('POST', '/v1/billing/subscriptions/$businessId/change-tier', body: {'tier': tier});

  /// Cancels the subscription at the end of the current period.
  Future<dynamic> cancelSubscription(String businessId) => _request('POST', '/v1/billing/subscriptions/$businessId/cancel');

  /// Applies a finished Stripe Checkout (plan, top-up or card). Safe to call twice.
  Future<dynamic> completeCheckout(String sessionId) =>
      _request('POST', '/v1/billing/checkout/complete', body: {'sessionId': sessionId});

  /// The usage balance, alarms, and this allowance window's usage per service.
  Future<dynamic> wallet(String businessId) => _request('GET', '/v1/billing/wallet/$businessId');

  /// Adds to the usage balance (stays on the same plan). Returns a Checkout URL.
  Future<dynamic> topUp(String businessId, num amountUsd) =>
      _request('POST', '/v1/billing/wallet/$businessId/top-up', body: {'amountUsd': amountUsd});

  /// Records a usage event.
  Future<dynamic> recordUsage(Map<String, dynamic> input) => _request('POST', '/v1/billing/usage', body: input);

  /// Your Merchant's plan (its Business's) and this period's usage: your own count of each service beside the Business's total and the plan's allowance.
  Future<dynamic> merchantSummary() => _request('GET', '/v1/billing/merchant/summary');

  /// Summarises usage for a billing period (defaults to the current one).
  Future<dynamic> usageSummary(String businessId, {String? billingPeriodRef}) =>
      _request('GET', withQuery('/v1/billing/usage/$businessId', {'billingPeriodRef': billingPeriodRef}));

  /// Where usage went — [groupBy] is day, merchant or eventType.
  Future<dynamic> usageBreakdown(String businessId, {String? from, String? to, String? groupBy}) =>
      _request('GET', withQuery('/v1/billing/usage/$businessId/breakdown', {'from': from, 'to': to, 'groupBy': groupBy}));

  /// The Business's statement: plan charges owed and Space earnings paid out, kept separate.
  Future<dynamic> statement(String businessId, {String? billingPeriodRef}) =>
      _request('GET', withQuery('/v1/billing/statements/$businessId', {'billingPeriodRef': billingPeriodRef}));
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

  /// Renames a subscription ('name'), moves it ('url') or changes its 'events'. The signing
  /// secret is kept.
  Future<dynamic> updateSubscription(String id, Map<String, dynamic> input) =>
      _request('PATCH', '/v1/webhooks/subscriptions/$id', body: input);

  /// Disables a subscription without deleting its delivery history. Ownership comes from your
  /// credential.
  Future<dynamic> disableSubscription(String id) => _request('POST', '/v1/webhooks/subscriptions/$id/disable');

  /// Lists delivery attempts for one of your subscriptions.
  Future<dynamic> listDeliveries(String subscriptionId) =>
      _request('GET', withQuery('/v1/webhooks/deliveries', {'subscriptionId': subscriptionId}));

  /// Re-sends a delivery.
  Future<dynamic> replayDelivery(String id) => _request('POST', '/v1/webhooks/deliveries/$id/replay');

  /// Subscribes a Business (TBBN Space) endpoint to booking lifecycle events. ADMIN or DEVELOPER role.
  Future<dynamic> createBusinessSubscription(String businessId, String url, List<String> events) =>
      _request('POST', '/v1/webhooks/business-subscriptions', body: {'businessId': businessId, 'url': url, 'events': events});

  /// Lists a Business's webhook subscriptions.
  Future<dynamic> listBusinessSubscriptions(String businessId) =>
      _request('GET', withQuery('/v1/webhooks/business-subscriptions', {'businessId': businessId}));

  /// Disables a Business webhook subscription.
  Future<dynamic> disableBusinessSubscription(String id) => _request('POST', '/v1/webhooks/business-subscriptions/$id/disable');

  /// Lists delivery attempts for a Business webhook subscription.
  Future<dynamic> listBusinessDeliveries(String subscriptionId) =>
      _request('GET', withQuery('/v1/webhooks/business-deliveries', {'subscriptionId': subscriptionId}));

  /// Re-sends a Business webhook delivery.
  Future<dynamic> replayBusinessDelivery(String id) => _request('POST', '/v1/webhooks/business-deliveries/$id/replay');
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

  /// Returns fixture data you can trade against in the sandbox.
  Future<dynamic> fixtures() => _request('GET', '/v1/sandbox/fixtures');
}

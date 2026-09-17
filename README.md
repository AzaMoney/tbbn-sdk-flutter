> **This is a public read-only mirror.** The source of truth lives in `packages/sdk-flutter` of
> TBBN's private main repository; this mirror exists solely so pub.dev's automated publishing
> (which checks out a public git URL at a pushed tag, not a decoupled artifact registry) can
> read it. Content here is kept in sync automatically — don't open PRs directly against this
> repo.

# tbbn_sdk

Dart client for the [TBBN Platform API](https://developer.tbbnetwork.com), for Flutter apps and Dart servers alike.
Publish listings, manage offers and trade sessions, and verify webhooks. Null-safe, Dart 3+,
built on `package:http`.

## Install

```yaml
dependencies:
  tbbn_sdk: ^0.2.0
```

## Quick start

```dart
import 'package:tbbn_sdk/tbbn_sdk.dart';

final client = TbbnClient(baseUrl: 'https://api.tbbnetwork.com', apiKey: 'sk_sandbox_...');

final listing = await client.listings.upsert({
  'merchantId': '...',
  'merchantListingRef': 'sku-1042',
  'sellerId': '...',
  'listingType': 'BOTH',
  'title': 'Nike Air Max 90 — size 10, lightly worn',
  'category': 'Apparel',
  'originalPrice': 150,
  'requestedAmount': 25,
  'currency': 'USD',
  'visibility': 'GLOBAL',
}) as Map<String, dynamic>;

final offers = await client.offers.list(listing['sellerId'] as String, direction: 'received');
```

Responses are decoded JSON (`Map` / `List`). A complete runnable walkthrough is in
[`example/tbbn_sdk_example.dart`](./example/tbbn_sdk_example.dart).

## Authentication

Pass either an **API key** (`apiKey`, issued to your merchant at
[merchants.tbbnetwork.com](https://merchants.tbbnetwork.com)) or a **session token**
(`accessToken`, obtained through one of the `auth` sign-in flows). Sandbox keys
(`sk_sandbox_…`) work against the same API and never touch live data.

## Webhooks

Verify every inbound delivery before trusting it. Pass the raw request body exactly as
received — re-serialising the JSON changes the bytes and the signature will not match.
Signatures are HMAC-SHA256 with a five-minute replay window.

```dart
final ok = verifyWebhookSignature(rawBody, request.headers['x-tbbn-signature']!, signingSecret);
```

## Errors

Every non-2xx response throws `TbbnApiException` with `status`, `code`, `message`, and `requestId`. Quote the request id when asking
for help with a specific call.

## Resources

`auth`, `merchants`, `apiKeys`, `sellers`, `listings`, `catalog`, `media`, `directory`, `search`, `tradeEngine`, `currency`, `localization`, `matching`, `recommendations`, `offers`, `tradeSessions`, `checkout`, `billing`, `notifications`, `webhooks`, `auditLogs`, `moderation`, `fraud`, `reputation`, `analytics`, `features`, `sandbox`. Each method maps one-to-one onto an API endpoint documented in the
[API reference](https://developer.tbbnetwork.com/merchant/docs/api).

## Support

Questions and bug reports: the [developer community](https://developer.tbbnetwork.com/community).

## License

MIT © Trade By Barter Network, Inc.

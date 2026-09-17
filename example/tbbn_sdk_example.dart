// A minimal end-to-end walkthrough: publish a listing, look at incoming offers, and verify a
// webhook delivery. Run against the sandbox with a sandbox key:
//
//   TBBN_API_KEY=sk_sandbox_... TBBN_MERCHANT_ID=... TBBN_SELLER_ID=... \
//     dart run example/tbbn_sdk_example.dart
import 'dart:io';

import 'package:tbbn_sdk/tbbn_sdk.dart';

Future<void> main() async {
  final apiKey = Platform.environment['TBBN_API_KEY'];
  if (apiKey == null) {
    stderr.writeln('Set TBBN_API_KEY to a sandbox key (sk_sandbox_...) first.');
    exit(1);
  }

  final client = TbbnClient(
    baseUrl: Platform.environment['TBBN_API_BASE_URL'] ?? 'https://api.tbbnetwork.com',
    apiKey: apiKey,
  );

  try {
    // 1. Publish (or update) one of your seller's items. `merchantListingRef` is your own id
    //    for the item, so calling this again with the same ref updates rather than duplicates.
    final listing = await client.listings.upsert({
      'merchantId': Platform.environment['TBBN_MERCHANT_ID'],
      'merchantListingRef': 'sku-1042',
      'sellerId': Platform.environment['TBBN_SELLER_ID'],
      'listingType': 'BOTH',
      'title': 'Nike Air Max 90 — size 10, lightly worn',
      'category': 'Apparel',
      'subcategory': 'Sneakers',
      'brand': 'Nike',
      'condition': 'Good',
      'originalPrice': 150,
      'requestedAmount': 25,
      'currency': 'USD',
      'visibility': 'GLOBAL',
      'wants': [
        {'category': 'Electronics', 'subcategory': 'Tablets'},
      ],
    }) as Map<String, dynamic>;
    print('Listing ${listing['id']} is live.');

    // 2. See what other sellers have offered for it.
    final offers = await client.offers.list(listing['sellerId'] as String, direction: 'received') as List;
    print('${offers.length} offer(s) waiting.');

    // 3. When a webhook arrives, verify it before trusting the payload.
    const rawBody = '{"type":"offer.created","data":{}}';
    const header = 't=1700000000,v1=deadbeef';
    final ok = verifyWebhookSignature(rawBody, header, 'whsec_example', now: 1700000000);
    print('Webhook signature valid: $ok');
  } on TbbnApiException catch (e) {
    stderr.writeln('API error ${e.status} ${e.code}: ${e.message} (request ${e.requestId})');
  } finally {
    client.close();
  }
}

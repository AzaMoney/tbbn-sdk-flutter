/// Dart client for the TBBN Platform API.
///
/// Create a [TbbnClient] with your API key, call methods on its resource groups, and verify
/// inbound webhooks with [verifyWebhookSignature]. See the package README for a walkthrough.
library tbbn_sdk;

export 'src/client.dart' show TbbnClient, TbbnApiException, RequestFn;
export 'src/resources_identity.dart';
export 'src/resources_listings.dart';
export 'src/resources_trading.dart';
export 'src/resources_platform.dart';
export 'src/webhooks.dart' show verifyWebhookSignature;

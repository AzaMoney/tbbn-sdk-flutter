import 'dart:convert';
import 'package:crypto/crypto.dart';

const _replayWindowSeconds = 5 * 60;

/// Verifies the `X-TBBN-Signature` header on an inbound webhook delivery.
///
/// The header has the form `t=<unix_ts>,v1=<hmac_sha256_hex>`. The signature is an HMAC-SHA256
/// of `"<t>.<rawBody>"` under your subscription's signing secret. Deliveries older than five
/// minutes are rejected to defeat replay. Pass [rawBody] exactly as received — re-serialising
/// the JSON changes the bytes and the signature will not match. [now] (seconds since the epoch)
/// is only needed for testing.
bool verifyWebhookSignature(String rawBody, String signatureHeader, String signingSecret, {int? now}) {
  now ??= DateTime.now().millisecondsSinceEpoch ~/ 1000;

  final parts = <String, String>{};
  for (final pair in signatureHeader.split(',')) {
    final kv = pair.split('=');
    if (kv.length == 2) parts[kv[0]] = kv[1];
  }

  final timestampStr = parts['t'];
  final signature = parts['v1'];
  if (timestampStr == null || signature == null) return false;

  final timestamp = int.tryParse(timestampStr);
  if (timestamp == null) return false;
  if ((now - timestamp).abs() > _replayWindowSeconds) return false;

  final expected = Hmac(sha256, utf8.encode(signingSecret)).convert(utf8.encode('$timestamp.$rawBody')).toString();
  return _constantTimeEquals(expected, signature);
}

bool _constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  var result = 0;
  for (var i = 0; i < a.length; i++) {
    result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return result == 0;
}

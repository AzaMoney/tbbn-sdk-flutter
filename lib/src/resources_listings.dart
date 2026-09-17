import 'client.dart';

/// A merchant's listings — the items its sellers have put up for trade — and the "wants" that
/// describe what each seller would accept in return.
class ListingsResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.listings`.
  ListingsResource(this._request);

  /// Creates or updates a listing, keyed by your own `merchantListingRef`.
  Future<dynamic> upsert(Map<String, dynamic> input, {String? idempotencyKey}) =>
      _request('POST', '/merchant/listings', body: input, extraHeaders: idempotencyHeader(idempotencyKey));

  /// Replaces a listing's fields.
  Future<dynamic> update(String id, Map<String, dynamic> input, {String? idempotencyKey}) =>
      _request('PUT', '/merchant/listings/$id', body: input, extraHeaders: idempotencyHeader(idempotencyKey));

  /// Removes a listing.
  Future<dynamic> remove(String id) => _request('DELETE', '/merchant/listings/$id');

  /// Sets a listing's availability status (for example when it sells elsewhere).
  Future<dynamic> updateAvailability(String id, String status) =>
      _request('POST', '/merchant/listings/$id/availability', body: {'status': status});

  /// Replaces the set of items the seller wants in exchange for this listing.
  Future<dynamic> replaceWants(String id, List<Map<String, dynamic>> wants) =>
      _request('PUT', '/merchant/listings/$id/wants', body: {'wants': wants});

  /// Returns the seller's wants for this listing.
  Future<dynamic> getWants(String id) => _request('GET', '/merchant/listings/$id/wants');

  /// Fetches a listing by id.
  Future<dynamic> get(String id) => _request('GET', '/v1/listings/$id');

  /// Lists listings, filtered by the optional [query] parameters.
  Future<dynamic> list([Map<String, dynamic>? query]) => _request('GET', withQuery('/v1/listings', query ?? {}));
}

/// The category, subcategory and brand taxonomy listings are filed under.
class CatalogResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.catalog`.
  CatalogResource(this._request);

  /// Lists top-level categories.
  Future<dynamic> categories() => _request('GET', '/v1/catalog/categories');

  /// Lists the subcategories of [category].
  Future<dynamic> subcategories(String category) =>
      _request('GET', '/v1/catalog/categories/${Uri.encodeComponent(category)}/subcategories');

  /// Lists known brands, optionally narrowed to a category and subcategory.
  Future<dynamic> brands({String? category, String? subcategory}) =>
      _request('GET', withQuery('/v1/catalog/brands', {'category': category, 'subcategory': subcategory}));
}

/// Image ingestion for listings.
class MediaResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.media`.
  MediaResource(this._request);

  /// Ingests images by URL and returns the stored media records.
  Future<dynamic> ingest(List<String> images) => _request('POST', '/v1/media/ingest', body: {'images': images});
}

/// The public, cross-merchant listing directory.
class DirectoryResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.directory`.
  DirectoryResource(this._request);

  /// Browses the directory, filtered by the optional [query] parameters.
  Future<dynamic> list([Map<String, dynamic>? query]) => _request('GET', withQuery('/v1/directory/listings', query ?? {}));

  /// Fetches one directory entry.
  Future<dynamic> get(String id) => _request('GET', '/v1/directory/listings/$id');
}

/// Listing search.
class SearchResource {
  final RequestFn _request;

  /// Creates the resource; you normally reach it as `client.search`.
  SearchResource(this._request);

  /// Searches listings by text, category, price range and location.
  Future<dynamic> listings(Map<String, dynamic> input) => _request('POST', '/v1/search/listings', body: input);
}

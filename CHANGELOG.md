# Changelog

## 0.2.0 — 2026-09-15

- Removed the `reservations` resource group. Reservations are managed by the platform for the
  duration of a trade session and are no longer reachable through the public API.
- Every public class, field and method now carries API documentation, and the resource classes
  are exported so their types can be named in your own code.
- Added a runnable example (`example/tbbn_sdk_example.dart`).

## 0.1.0

Initial release — a client for every public resource group of the TBBN Platform API, plus
webhook signature verification.

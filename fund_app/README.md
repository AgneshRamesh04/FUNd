# fund_app

FUNd iOS app

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Deep Links

Custom scheme: `fund://`

Examples:

- Open transaction form: `fund:///transaction-form?type=deposit&date=2026-05-09`
- Open trip expense form:
  `fund:///transaction-form?type=trip_expense&tripId=abc123&tripName=Bali%20Trip&date=2026-05-09`
- Open leave page for a user: `fund:///leave?userId=<user-id>`

Supported transaction deep-link params for `shared_expense`,
`personal_expense`, `deposit`:

- `description` (default: blank)
- `user` (accepted hints: `akku` or `malu`; default: blank)
- `date` in `YYYY-MM-DD` (default: today)
- `amount` (default: `0`)
- `confirm` (`true|1|yes`) to auto-submit immediately

Examples:

- `fund:///transaction-form?type=shared-expense&description=Lunch&user=akku&date=2026-05-09&amount=12.5`
- `fund:///transaction-form?type=personal-expense&description=Coffee&user=malu&amount=4.2`
- `fund:///transaction-form?type=personal-expense&description=Cash%20advance&user=akku&date=2026-05-09&confirm=true`
- `fund:///transaction-form?type=deposit&description=Topup&user=malu&date=2026-05-09&amount=200&confirm=1`

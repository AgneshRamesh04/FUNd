# FUNd

> Finance made FUN — a shared money pool manager for two.

FUNd is a Flutter iOS app that lets two people manage a shared pool of money together. It tracks deposits, personal borrowing, shared expenses, and leave in real time — all synced instantly between both users via Supabase.

---

## Features

- **Pool balance** — live balance derived from all transactions
- **Monthly inflow / outflow** — at-a-glance summaries per month
- **Member debts** — who owes what to the pool
- **Personal transactions** — deposits, borrows, and personal expenses per user
- **Shared expenses** — expenses split between both users, optionally grouped under a trip
- **Trip tracking** — group expenses under a named trip with date range and total summary
- **Leave tracking** — annual leave balance per user with entry log
- **Dark / Light / System theme** — persisted between sessions
- **Real-time sync** — Supabase Realtime keeps both devices in sync instantly

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter (iOS) · Dart |
| State management | Riverpod |
| Backend | Supabase (PostgreSQL + Realtime + Auth) |
| Code generation | Freezed · json_serializable |

---

## Getting Started

1. **Clone the repo**
   ```
   git clone <repo-url>
   cd FUNd-ag-dev-finalVer/fund_app
   ```

2. **Install dependencies**
   ```
   flutter pub get
   ```

3. **Configure Supabase**
   Create a `.env` file in `fund_app/` with your project credentials:
   ```
   SUPABASE_URL=https://<your-project>.supabase.co
   SUPABASE_ANON_KEY=<your-anon-key>
   ```

4. **Run on iOS**
   ```
   flutter run
   ```

### Troubleshooting

- See [Troubleshooting](./troubleshooting.md) for common setup/runtime fixes.
- Includes fix for: `Creation failed, path = '.dart_tool' (OS Error: Permission denied, errno = 13)`.

---

## Project Structure

```
lib/
├── core/
│   ├── auth/          # Auth provider
│   ├── models/        # Shared data models (AppUser)
│   ├── realtime/      # Supabase Realtime service
│   ├── theme/         # AppTheme + ThemeProvider
│   └── utils/         # Date, validation, username helpers
├── features/
│   ├── auth/          # Login screen + auth gate
│   ├── home/          # Home screen + pool/debt/leave cards
│   ├── personal/      # Personal transactions screen
│   ├── shared_expenses/ # Shared expenses + trip details
│   ├── leave/         # Leave tracker + entry management
│   ├── transactions/  # Unified transaction form
│   ├── settings/      # Settings bottom sheet
│   └── shell/         # App shell (nav, FAB, month picker)
└── shared/
    ├── providers/     # Cross-feature providers
    ├── ui/            # AppUi constants, AppCardSurface, AppFeedback
    └── widgets/       # EmptyState, SkeletonLoader
```

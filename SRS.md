# FUNd – Software Requirements Specification (SRS)

---

# 1. Project Overview

## 1.1 Purpose

FUNd is a mobile application designed for **two users to manage a shared pool of money**.

It enables users to:

* Deposit money into a shared pool
* Borrow money for personal use
* Record expenses paid using or on behalf of the pool
* Track **pool balance and individual user obligations** in real time
* View monthly summaries and financial activity

The system is built on a **pool-centric transaction model**, where all transactions affect:

* The **Pool Balance** (actual money available)
* Each user's **Net Position vs Pool**:

  * Positive → user owes the pool
  * Negative → pool owes the user

---

## 1.2 Target Users

Two individuals sharing finances such as:

* Household expenses
* Travel
* Subscriptions
* Dining
* Temporary borrowing

---

# 2. System Architecture

Flutter iOS App (User A)
↕ Realtime Sync
Supabase Backend (PostgreSQL)
↕ Realtime Sync
Flutter iOS App (User B)

* Backend is the **single source of truth**
* Clients subscribe to realtime updates

---

# 3. Technology Stack

## Frontend

* Flutter (iOS focus)
* Dart

## Backend

* Supabase (PostgreSQL + Realtime + Auth)

---

# 4. User Roles

* Two users only
* Equal permissions:

  * View all transactions
  * Add / Edit / Delete transactions

---

# 5. Core Financial Model

FUNd uses a **pool-centric event-based transaction system**.

### Key Concepts

1. **Pool Balance** – actual cash available in the pool
2. **User Balance (per user)** – net position vs pool

   * Positive → user owes pool
   * Negative → pool owes user

> The system does **not enforce global balance (sum = 0)**.

---

# 6. Application Structure

## Navigation

Bottom Navigation Bar:

* Home
* Personal
* Shared

Floating Action Button (+):

* Accessible globally
* Opens Add Transaction flow

---

# 7. Home Screen

Provides a **monthly financial overview**.

## Displays

### Pool Balance

Total available money in the pool

### Monthly Summary

* Inflow (money entering pool)
* Outflow (money leaving pool)

### User Positions

For each user:

* Net balance vs pool

  * Positive → owes pool
  * Negative → pool owes user

### Leave Tracking

Per user:

* Leave used
* Remaining balance

---

# 8. Personal Screen

Displays **personal financial interactions with the pool**.

## Includes

* Borrow transactions (Pool → User)
* Deposits (User → Pool)
* Monthly obligations

## Behavior

* Borrow → increases user debt, reduces pool balance
* Deposit → reduces user debt, increases pool balance
* Obligation → increases user debt only

---

# 9. Shared Screen

Displays **expenses related to the pool**.

## Includes

* Pool Expenses – paid directly from pool
* User Paid for Pool – user pays on behalf of pool

## Behavior

| Scenario           | Effect                                  |
| ------------------ | --------------------------------------- |
| Pool pays          | Pool balance decreases                  |
| User pays for pool | User balance decreases (pool owes user) |

---

# 10. Trip Tracking (Optional)

Allows grouping expenses under trips.

## Fields

* Trip name
* Date range
* Expense list

## Summary

* Total cost
* Contribution per user

---

# 11. Transaction System

## 11.1 Transaction Types

* `monthly_obligation` – user owes pool (no cash movement)
* `deposit` – user adds money to pool
* `borrow` – user takes money from pool
* `pool_expense` – expense paid using pool funds
* `user_paid_for_pool` – user pays on behalf of pool

---

## 11.2 Transaction Effects

| Type               | Pool Balance | User Balance |
| ------------------ | ------------ | ------------ |
| monthly_obligation | 0            | +amount      |
| deposit            | +amount      | -amount      |
| borrow             | -amount      | +amount      |
| pool_expense       | -amount      | 0            |
| user_paid_for_pool | 0            | -amount      |

---

# 12. Add Transaction Flow

## Entry Options

* Add Monthly Obligation
* Add Money to Pool (Deposit)
* Borrow from Pool
* Pool Expense
* Paid for Pool

---

## 12.1 Form Fields

* Description
* Amount
* User (if applicable)
* Date (default: today)
* Notes (optional)

---

## 12.2 Default Logic

| Type          | User          |
| ------------- | ------------- |
| Obligation    | Selected user |
| Deposit       | Selected user |
| Borrow        | Selected user |
| Pool Expense  | None          |
| Paid for Pool | Selected user |

---

# 13. Database Design

## 13.1 Users

* id (uuid)
* name
* email
* created_at

---

## 13.2 Pools

* id (uuid)
* name
* created_at

---

## 13.3 Transactions

* id (uuid)
* type (monthly_obligation, deposit, borrow, pool_expense, user_paid_for_pool)
* user_id (nullable for pool_expense)
* pool_id
* description
* amount
* date
* notes
* created_at

---

## 13.4 Trips (Optional)

* id
* pool_id
* name
* start_date
* end_date
* created_at

---

## 13.5 Leave Tracking (Optional)

* id
* user_id
* used
* balance
* month
* year
* linked_transaction_id (nullable)
* created_at

---

# 14. Derived Calculations

All balances are **derived**, not stored.

## Pool Balance

```
sum(deposits) - sum(borrows) - sum(pool_expenses)
```

## User Balance

```
+ obligations
+ borrows
- deposits
- paid_for_pool
```

## Monthly Metrics

* Inflow = deposits
* Outflow = borrows + pool_expenses

---

# 15. Real-Time Synchronization

* Instant updates across devices
* Subscriptions on:

  * transactions
  * trips
  * leave

---

# 16. Performance Requirements

* Initial load < 2s
* UI updates < 500ms

---

# 17. Data Consistency

* Backend = source of truth
* Conflict strategy: Last write wins
* All records include timestamps

---

# 18. Edge Case Handling

System must handle:

* Editing transactions → recalculates balances
* Deleting transactions → reverses impact
* Partial repayments (via deposits)
* Negative pool balance (allowed)
* Pool owing users (negative user balance)

---

# 19. Security

* Email/password authentication
* Row-level security
* Restricted access to only 2 users

---

# 20. Non-Functional Requirements

* Real-time sync
* High reliability
* Clean UI/UX
* Minimal user input effort

---

# 21. Future Enhancements

* Analytics dashboard
* Spending charts
* Budget alerts
* Export (CSV/PDF)
* Notifications
* iOS widgets
* Offline support

---

# 22. Development Phases

## Phase 1 – MVP

* Core transactions
* Pool balance
* Real-time sync

## Phase 2

* Trips
* Leave tracking improvements

## Phase 3

* Offline support
* Analytics

---

# 23. Success Criteria

* Real-time sync between both users
* Transaction entry < 10 seconds
* Accurate balance calculations
* No manual sync required
* Full transparency between users

---

# 24. Architecture Recommendation (Flutter)

Feature-based structure:

```
/features
  /transactions
  /home
  /personal
  /shared
/core
  /database
  /services
  /utils
```

## Key Rule

All calculations must be handled in a **Transaction Service Layer**, not UI.

---

# 25. Key Design Principles

* Pool is the central financial anchor
* User balances represent obligation to pool
* Transactions are simple, explicit, and event-based
* No artificial balancing constraints
* All balances are derived, never stored

---

# END OF DOCUMENT

 to do that next?

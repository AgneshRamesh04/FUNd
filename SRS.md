# FUNd – Software Requirements Specification (SRS)

---

# 1. Project Overview

## 1.1 Purpose

FUNd is a mobile application designed for **two users to manage a shared pool of money**.

It enables users to:

* Deposit money into a shared pool
* Borrow money temporarily for personal use
* Record shared expenses
* Track balances and debts in real time
* View monthly summaries and financial activity

The system is built on a **ledger-style transaction model**, where all money movements are recorded between:

* User A
* User B
* FUNd Pool

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

FUNd uses a **ledger-based transaction system**.

Each transaction represents a movement of money between entities:

* User A
* User B
* Pool

Balances are **not stored**, but derived from transactions.

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

Total available money in pool

### Monthly Summary

* Inflow
* Outflow

### Money Owed to Pool

* User A debt
* User B debt

### Leave Tracking

Per user:

* Leave used
* Remaining balance

---

# 8. Personal Screen

Displays **Borrow transactions** (Pool → User).

## Fields

* Description
* Amount
* User
* Date
* Notes

## Behavior

* Reduces pool balance
* Increases user debt

---

# 9. Shared Screen

Displays **Shared Expenses**.

## Fields

* Description
* Amount
* Paid by
* Date
* Notes

## Behavior

* Splits cost between users
* Adjusts user balances

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

* borrow (Pool → User)
* deposit (User → Pool)
* shared_expense (User → Shared)
* pool_expense (Pool → External)

---

## 11.2 Transaction Effects

| Type           | Effect              |
| -------------- | ------------------- |
| Borrow         | Pool ↓, User debt ↑ |
| Deposit        | Pool ↑, User debt ↓ |
| Shared Expense | Split between users |
| Pool Expense   | Pool ↓              |

---

# 12. Add Transaction Flow

Single reusable form.

## Entry Options

* Borrow from FUNd
* Add Money to FUNd
* Shared Expense

---

## 12.1 Form Fields

* Description
* Amount
* Paid by
* Received by / Split with
* Date (default: today)
* Notes (optional)

---

## 12.2 Default Logic

| Type    | Paid By      | Received By  |
| ------- | ------------ | ------------ |
| Borrow  | Pool         | Current User |
| Deposit | Current User | Pool         |
| Shared  | Current User | Both         |

---

# 13. Database Design

## 13.1 Users

* id (uuid)
* name
* email
* created_at

---

## 13.2 Transactions

* id
* type (borrow, deposit, shared_expense, pool_expense)
* description
* amount
* paid_by
* received_by
* split_type (equal / custom)
* split_data (json)
* date
* trip_id (optional)
* notes
* created_at
* updated_at

---

## 13.3 Trips

* id
* name
* start_date
* end_date
* created_at

---

## 13.4 Leave Tracking

* id
* user_id
* used
* balance
* month
* year

---

# 14. Derived Calculations

Not stored in DB:

* Pool Balance
* User Debt
* Monthly Inflow / Outflow

All computed via transaction service.

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

* Editing transactions (recalculate balances)
* Deleting transactions (reverse effects)
* Partial repayments
* Negative pool balance (configurable)

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

/features
/transactions
/home
/personal
/shared

/core
/database
/services
/utils

## Key Rule

All calculations must be handled in a **Transaction Service Layer**, not UI.

---

# 25. Key Design Principles

* Single source of truth (transactions)
* Reusable UI components
* Minimal duplication
* Scalable transaction model
* Clear separation of concerns

---

# END OF DOCUMENT

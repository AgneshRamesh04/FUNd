# FUNd

**FUNd** is an iOS application built with Flutter to manage a **shared pool of money between two users**.  
It allows both users to track deposits, shared expenses, personal withdrawals, and balances while maintaining **real-time synchronization across both devices**.

The goal of FUNd is to provide a simple and transparent way for two people to manage a shared financial pool for things like household spending, travel, subscriptions, or temporary personal borrowing.

---

# Table of Contents

- Project Overview
- Technology Stack
- System Architecture
- Functional Requirements
- Application Screens
- Expense & Deposit Flow
- Database Design
- Non-Functional Requirements
- Security
- Future Enhancements
- Development Phases
- Success Criteria

---

# Project Overview

## Purpose

FUNd helps **two users maintain and monitor a shared financial pool**.

Users can:

- Deposit money into the pool
- Record shared expenses
- Temporarily use money from the pool for personal expenses
- Track debts owed back to the pool
- Monitor inflow, outflow, and balance
- View leave usage and remaining balance

All data is **visible to both users and synchronized in real time**.

---

## Target Users

Two individuals who share expenses such as:

- Household costs
- Travel
- Subscriptions
- Dining
- Temporary personal borrowing from the shared pool

---

# Technology Stack

## Frontend

- Flutter (iOS focus)
- Dart

## Backend

Recommended backend:

**Supabase**

Reasons:

- Free tier
- Real-time database updates
- PostgreSQL
- Flutter support
- Authentication support

Alternative options:

- Appwrite
- PocketBase (self hosted)

---

# System Architecture

Flutter iOS App (User A)  
↕ Real-time Sync  
Supabase Backend (PostgreSQL + Realtime)  
↕ Real-time Sync  
Flutter iOS App (User B)

The Supabase database acts as the **single source of truth**.  
Both devices subscribe to realtime database updates.

---

# Functional Requirements

## Authentication

The application supports two authorized users.

Features:

- Email + password login
- Two authorized accounts only
- Each account mapped to a unique `user_id`

---

# Application Screens

The app contains **three primary screens**.

Navigation is done via a **bottom navigation bar**.

Home  
Personal  
Shared

---

# Home Screen

The Home Screen provides a **financial overview for the current month**.

## Displayed Information

### Pool Balance

The total current balance of the shared pool.

Example

Pool Balance: $2,450

---

### Monthly Summary

Shows financial activity for the selected month.

Example

Inflow: $500  
Outflow: $320

---

### Money Owed to the Pool

Personal withdrawals create a debt that the user owes back.

Example

User A owes: $80  
User B owes: $0

---

### Leave Tracking

Each user has a leave counter.

Displayed per user:

- Leave used this month
- Remaining leave balance

Example

User A  
Leave used: 2  
Balance: 6  

User B  
Leave used: 1  
Balance: 7  

---

### Floating Action Button

A floating **+ button** exists on the Home screen.

This button opens the **Add Transaction interface** similar to Splitwise.

---

# Personal Expenses Screen

This screen tracks **temporary withdrawals from the pool used for personal expenses**.

These expenses represent **money owed back to the pool**.

## Display Format

Monthly grouped list.

Each entry contains:

- Description
- Amount
- User
- Date
- Optional notes

Example

March 2026

Coffee Beans  
$20  
User A

Taxi  
$15  
User B

---

## Effect on Pool

When a personal expense is added:

- Pool balance decreases
- User's debt to pool increases

---

# Combined Expenses Screen

This screen tracks **expenses meant to be paid using the shared pool**.

Examples include:

- Groceries
- Rent
- Dining
- Subscriptions
- Household purchases

## Display Fields

Each expense contains:

- Description
- Amount
- Paid by
- Date
- Optional notes

Example

Groceries  
$120  
Paid by User A

Streaming Subscription  
$15  
Paid by User B

---

# Vacation Tracking (Subpage)

Within the Shared Expenses screen, a subpage exists for tracking **trip-related expenses**.

Trips group expenses together for better organization.

Example

Trip: Bali 2026

Expenses

Flight  
Hotel  
Food  
Activities

Trip summary can include:

- Total cost
- Contributions by each user
- Pool usage

---

# Add Transaction Flow

The floating **+ button** opens a modal allowing the user to choose:

- Add Personal Expense
- Add Shared Expense
- Add Deposit

---

## Add Personal Expense

Fields:

- Description
- Amount
- Person (default current user)
- Date
- Notes (optional)

Default date is **current date**.

A calendar icon allows changing the date.

---

## Add Shared Expense

Fields:

- Description
- Amount
- Paid by
- Date
- Notes

---

## Add Deposit

Fields:

- Amount
- Deposited by
- Date
- Notes

Effects:

- Pool balance increases
- Monthly inflow increases

---

# Database Design

## Users

| Field | Type |
|-----|-----|
| id | uuid |
| name | text |
| email | text |
| created_at | timestamp |

---

## Deposits

| Field | Type |
|-----|-----|
| id | uuid |
| amount | numeric |
| user_id | uuid |
| date | date |
| notes | text |
| created_at | timestamp |

---

## Expenses

| Field | Type |
|-----|-----|
| id | uuid |
| description | text |
| amount | numeric |
| expense_type | personal/shared |
| paid_by | uuid |
| date | date |
| trip_id | uuid (optional) |
| notes | text |
| created_at | timestamp |

---

## Trips

| Field | Type |
|-----|-----|
| id | uuid |
| name | text |
| start_date | date |
| end_date | date |
| created_at | timestamp |

---

## Leave Tracking

| Field | Type |
|-----|-----|
| id | uuid |
| user_id | uuid |
| used | integer |
| balance | integer |
| month | integer |
| year | integer |

---

# Non-Functional Requirements

## Real-Time Synchronization

Changes made on one device must appear **instantly on the other device**.

Supabase realtime subscriptions will monitor:

- deposits
- expenses
- leave records

---

## Performance

The application must:

- Load initial data in under 2 seconds
- Reflect remote updates in under 500 milliseconds

---

## Data Consistency

The Supabase database acts as the **single source of truth**.

Conflict handling strategy:

Last write wins.

All records contain timestamps.

---

## Offline Support (Future)

Optional offline caching using:

- Hive
- SQLite

Data will sync once connectivity returns.

---

# Security

Security measures include:

- Email/password authentication
- Supabase row level security
- Only authorized users can access database records

---

# Future Enhancements

Potential future features:

- Expense analytics and charts
- Monthly spending breakdown
- Export reports (CSV / PDF)
- Notifications for repayments
- iOS home screen widgets
- Budget alerts
- Smart summaries

---

# Development Phases

## Phase 1 — MVP

Core features:

- Flutter UI
- Supabase backend
- Deposits
- Personal expenses
- Shared expenses
- Pool balance calculation
- Real-time synchronization

---

## Phase 2

Enhancements:

- Leave tracking
- Vacation grouping

---

## Phase 3

Advanced features:

- Offline support
- Analytics dashboard
- Charts and reports

---

# Success Criteria

FUNd will be considered successful when:

- Both users see identical data in real time
- Expenses can be added within 10 seconds
- Pool balance updates instantly
- No manual syncing is required
- Both users have full visibility of all transactions

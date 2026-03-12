# FUNd – Software Requirements Specification (SRS)

## 1. Project Overview

### 1.1 Project Name
FUNd

### 1.2 Purpose

FUNd is a mobile application designed for **two users to manage a shared pool of money** for expenses such as household spending, travel, subscriptions, or shared activities.

The application provides a **clear and simple interface to track money moving between:**

- User A
- User B
- The shared FUNd pool

Users can:

- Add money to the pool
- Borrow from the pool temporarily
- Record shared expenses
- Track pool balance and debts
- View monthly financial summaries

The app runs on **two iOS devices with real-time synchronization**, ensuring both users always see identical data.

---

# 2. System Architecture

## 2.1 High-Level Architecture

Flutter iOS App (User A)  
↕ Realtime Sync  
Backend Database (Supabase / PostgreSQL)  
↕ Realtime Sync  
Flutter iOS App (User B)

The backend database acts as the **single source of truth**, and both devices subscribe to realtime updates.

---

# 3. Technology Stack

## Frontend

Flutter  
Dart

## Backend

Supabase

Reasons:

- PostgreSQL database
- Real-time subscriptions
- Free tier availability
- Works well with Flutter

Alternative options:

- Appwrite
- PocketBase (self-hosted)

---

# 4. User Roles

The system supports **two users only**.

User roles:

- User A
- User B

Both users have identical permissions:

- View all transactions
- Add transactions
- Edit transactions
- Delete transactions

All data is visible to both users.

---

# 5. Core Financial Model

FUNd tracks money flowing between:

User A  
User B  
FUNd Pool

The pool balance changes depending on the transaction type.

---

# 6. Application Screens

The application contains three primary screens.

Navigation is done using a **bottom navigation bar**.

Home  
Personal  
Shared

A **floating + button** is available on all screens to add transactions.

---

# 7. Home Screen

The Home Screen provides a **financial overview of the pool**.

## Displayed Information

### Pool Balance

The total available balance of the FUNd pool.

Example:

Pool Balance: $2,450

---

### Monthly Summary

Displays the current month's inflow and outflow.

Example:

Inflow: $500  
Outflow: $320

---

### Money Owed to the Pool

Shows how much each user has borrowed from the pool.

Example:

User A owes: $80  
User B owes: $0

---

### Leave Tracking

Each user has a leave counter displayed on the home screen.

Fields displayed:

- Leave used this month
- Remaining leave balance

Example:

User A  
Used: 2  
Remaining: 6  

User B  
Used: 1  
Remaining: 7  

---

# 8. Personal Screen

The Personal screen shows **Borrow transactions**.

These represent **personal withdrawals from the FUNd pool**.

## Information Displayed

Each entry shows:

- Description
- Amount
- User
- Date
- Optional notes

Example:

Coffee Beans  
User A  
$20  
Mar 8

Taxi  
User B  
$15  
Mar 10

---

# 9. Shared Screen

The Shared screen displays **Shared Expense transactions**.

These represent expenses used by both users.

Examples include:

- Groceries
- Dining
- Subscriptions
- Travel expenses

Each entry displays:

- Description
- Amount
- Paid by
- Date

Example:

Groceries  
Paid by User A  
$120

Streaming Subscription  
Paid by User B  
$15

---

# 10. Trip Tracking (Optional Subpage)

Trips allow grouping shared expenses under a specific trip.

Example:

Trip: Bali 2026

Expenses may include:

Flight  
Hotel  
Food  
Activities

The trip page shows:

- Total trip cost
- Expense breakdown

---

# 11. Add Transaction Flow

The **floating + button** opens the Add Transaction menu.

Users select one of three transaction types:

Borrow from FUNd  
Add Money to FUNd  
Shared Expense

Each option opens the same transaction form with different defaults.

---

# 12. Transaction Types

## 12.1 Borrow from FUNd

Definition:

A user temporarily takes money from the FUNd pool for personal use.

Default configuration:

Paid by: FUNd Pool  
Received by: You

Example:

Coffee Beans  
$20  
FUNd → User A

Effects:

- Pool balance decreases
- User owes money back to the pool

---

## 12.2 Add Money to FUNd

Definition:

A user deposits money into the FUNd pool.

Default configuration:

Paid by: You  
Received by: FUNd Pool

Example:

Deposit  
$200  
User A → FUNd

Effects:

- Pool balance increases
- Monthly inflow increases

---

## 12.3 Shared Expense

Definition:

A user pays for a shared expense used by both users.

Default configuration:

Paid by: You  
Split with: Other user

Example:

Groceries  
$120  
Paid by User A  
Shared with User B

Effects:

- Pool balance decreases
- Expense recorded as shared usage

---

# 13. Pool Expense Option

Shared expenses may also be **paid directly from the FUNd pool**.

Example:

Streaming subscription  
$15  
Paid from FUNd pool

Effects:

- Pool balance decreases
- No personal balance adjustment required

---

# 14. Transaction Entry Form

All transaction types use the same base form.

Fields include:

Description  
Amount  
Paid by  
Recipient / Split With  
Date  
Notes (optional)

Default date is **Today**.

Users may change the date using a calendar picker.

---

# 15. Database Design

## Users

id  
name  
email  
created_at

---

## Transactions

id  
description  
amount  
transaction_type  
paid_by  
received_by  
split_with  
date  
trip_id (optional)  
notes  
created_at

Transaction types:

borrow  
deposit  
shared_expense  
pool_expense

---

## Trips

id  
name  
start_date  
end_date  
created_at

---

## Leave Tracking

id  
user_id  
used  
balance  
month  
year

---

# 16. Real-Time Synchronization

All changes must appear instantly on both devices.

Realtime subscriptions monitor:

- transactions
- trips
- leave records

---

# 17. Performance Requirements

The system must:

Load initial data in under 2 seconds  
Update UI after remote changes within 500ms

---

# 18. Data Consistency

The database acts as the **single source of truth**.

Conflict handling strategy:

Last write wins.

All records contain timestamps.

---

# 19. Security

Security features include:

Email/password authentication  
Row level security in backend  
Only authorized users can access data

---

# 20. Future Enhancements

Potential future features:

Expense analytics and charts  
Monthly spending breakdown  
Export reports (CSV / PDF)  
Notifications for repayments  
iOS widgets showing pool balance  
Budget alerts

---

# 21. Development Phases

## Phase 1 – MVP

Core features:

Flutter UI  
Supabase backend  
Borrow transactions  
Deposit transactions  
Shared expenses  
Pool balance calculations  
Real-time synchronization

---

## Phase 2

Additional features:

Trip grouping  
Leave tracking improvements

---

## Phase 3

Advanced features:

Offline support  
Analytics dashboard  
Charts and spending insights

---

# 22. Success Criteria

FUNd will be considered successful when:

Both users see identical data in real time  
Transactions can be added in under 10 seconds  
Pool balance updates instantly  
No manual syncing is required  
Both users have full visibility of all transactions

class DemoData {
  static const String userAId = 'uuid-user-a';
  static const String userBId = 'uuid-user-b';

  // 13.2 Transactions Table Mock
  static const List<Map<String, dynamic>> mockTransactions = [
    {
      'id': '1',
      'type': 'deposit',
      'amount': 3000.0,
      'paid_by': userAId, // User A puts money in
      'received_by': 'pool',
      'date': '2026-03-01T10:00:00Z',
    },
    {
      'id': '2',
      'type': 'borrow',
      'amount': 80.0,
      'paid_by': 'pool',
      'received_by': userAId, // User A takes money out (Debt!)
      'date': '2026-03-05T12:00:00Z',
    },
    {
      'id': '3',
      'type': 'shared_expense',
      'amount': 100.0,
      'paid_by': userBId, // User B paid for both
      'received_by': 'shared',
      'split_type': 'equal',
      'date': '2026-03-10T09:00:00Z',
    },
    {
      'id': '4',
      'type': 'borrow',
      'amount': 2000.0,
      'paid_by': 'pool',
      'received_by': userBId, // User A takes money out (Debt!)
      'date': '2026-03-05T12:00:00Z',
    },
    {
      'id': '6',
      'type': 'borrow',
      'amount': 200.0,
      'paid_by': 'pool',
      'received_by': userAId, // User A takes money out (Debt!)
      'date': '2026-02-15T12:00:00Z',
    },
    {
      'id': '5',
      'type': 'borrow',
      'amount': 20000.0,
      'paid_by': 'pool',
      'received_by': userAId, // User A takes money out (Debt!)
      'date': '2026-01-15T12:00:00Z',
    },
    {
      'id': '6',
      'type': 'borrow',
      'amount': 280.0,
      'paid_by': 'pool',
      'received_by': userBId, // User A takes money out (Debt!)
      'date': '2025-11-15T12:00:00Z',
    },
    {
      'id': 't4',
      'type': 'shared_expense',
      'description': 'Flight Tickets',
      'amount': 1200.0,
      'paid_by': userAId,
      'received_by': 'shared',
      'date': '2026-01-10T10:00:00Z',
      'trip_id': 'trip-1', // Linked to Bali 2026
    },
    {
      'id': 't5',
      'type': 'shared_expense',
      'description': 'Hotel Booking',
      'amount': 1640.0,
      'paid_by': userBId,
      'received_by': 'shared',
      'date': '2026-01-12T10:00:00Z',
      'trip_id': 'trip-1', // Linked to Bali 2026
    },
    {
      'id': 't6',
      'type': 'shared_expense',
      'description': 'Airbnb Cabin',
      'amount': 380.0,
      'paid_by': userAId,
      'received_by': 'shared',
      'date': '2026-02-05T10:00:00Z',
      'trip_id': 'trip-2', // Linked to Weekend Getaway
    },
    {

      'id': 't7',
      'type': 'shared_expense',
      'description': 'Airbnb Cabin - 2',
      'amount': 380.0,
      'paid_by': userAId,
      'received_by': 'shared',
      'date': '2026-02-05T10:00:00Z',
      'trip_id': 'trip-2', // Linked to Weekend Getaway
    },
  ];

  // 13.3 Trips Table Mock
  static const List<Map<String, dynamic>> mockTrips = [
    {
      'id': 'trip-1',
      'name': 'Bali 2026',
      'start_date': '2026-01-15T00:00:00Z',
      'end_date': '2026-01-22T00:00:00Z',
      'created_at': '2026-01-01T10:00:00Z',
    },
    {
      'id': 'trip-2',
      'name': 'Weekend Getaway',
      'start_date': '2026-02-08T00:00:00Z',
      'end_date': '2026-02-09T00:00:00Z',
      'created_at': '2026-02-01T12:00:00Z',
    },
  ];

  // 13.4 Leave Tracking Table Mock
  static const List<Map<String, dynamic>> mockLeaveTable = [
    {'id': 'l1', 'user_id': userAId, 'used': 2, 'balance': 20, 'month': 3, 'year': 2026},
    {'id': 'l2', 'user_id': userBId, 'used': 1, 'balance': 30, 'month': 3, 'year': 2026},
  ];

}
class DemoData {
  static const String userAId = 'uuid-user-a';
  static const String userBId = 'uuid-user-b';

  static const String currentMonthName = "March";

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
      'id': '4',
      'type': 'borrow',
      'amount': 200.0,
      'paid_by': 'pool',
      'received_by': userBId, // User A takes money out (Debt!)
      'date': '2026-02-15T12:00:00Z',
    },
  ];

  // 13.4 Leave Tracking Table Mock
  static const List<Map<String, dynamic>> mockLeaveTable = [
    {'id': 'l1', 'user_id': userAId, 'used': 2, 'balance': 20, 'month': 3, 'year': 2026},
    {'id': 'l2', 'user_id': userBId, 'used': 1, 'balance': 30, 'month': 3, 'year': 2026},
  ];

}
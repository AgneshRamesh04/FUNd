import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fund_app/core/models/transaction_model.dart';
import 'package:fund_app/core/repositories/transaction_repository.dart';
import 'package:fund_app/core/services/transaction_service.dart';
import 'package:fund_app/core/services/supabase_service.dart';

class AddTransactionState {
  final TransactionType? selectedType;
  final String description;
  final double amount;
  final String? paidBy;
  final String? receivedBy;
  final SplitType splitType;
  final Map<String, dynamic>? splitData;
  final DateTime selectedDate;
  final String? notes;
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  AddTransactionState({
    this.selectedType,
    this.description = '',
    this.amount = 0,
    this.paidBy,
    this.receivedBy,
    this.splitType = SplitType.equal,
    this.splitData,
    required this.selectedDate,
    this.notes,
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  AddTransactionState copyWith({
    TransactionType? selectedType,
    String? description,
    double? amount,
    String? paidBy,
    String? receivedBy,
    SplitType? splitType,
    Map<String, dynamic>? splitData,
    DateTime? selectedDate,
    String? notes,
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return AddTransactionState(
      selectedType: selectedType ?? this.selectedType,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      paidBy: paidBy ?? this.paidBy,
      receivedBy: receivedBy ?? this.receivedBy,
      splitType: splitType ?? this.splitType,
      splitData: splitData ?? this.splitData,
      selectedDate: selectedDate ?? this.selectedDate,
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class AddTransactionNotifier extends StateNotifier<AddTransactionState> {
  final TransactionRepository _transactionRepository;

  AddTransactionNotifier(this._transactionRepository)
      : super(AddTransactionState(selectedDate: DateTime.now()));

  void setTransactionType(TransactionType type) {
    state = state.copyWith(selectedType: type);
    // Reset split data for non-shared expenses
    if (type != TransactionType.sharedExpense) {
      state = state.copyWith(splitData: null, splitType: SplitType.equal);
    }
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void setAmount(double amount) {
    state = state.copyWith(amount: amount);
  }

  void setPaidBy(String userId) {
    state = state.copyWith(paidBy: userId);
  }

  void setReceivedBy(String userId) {
    state = state.copyWith(receivedBy: userId);
  }

  void setSplitType(SplitType splitType) {
    state = state.copyWith(splitType: splitType);
  }

  void setSplitData(Map<String, dynamic> splitData) {
    state = state.copyWith(splitData: splitData);
  }

  void setDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void setNotes(String notes) {
    state = state.copyWith(notes: notes.isEmpty ? null : notes);
  }

  Future<void> submitTransaction() async {
    if (!_validateForm()) {
      state = state.copyWith(error: 'Please fill all required fields');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _transactionRepository.createTransaction(
        type: state.selectedType!,
        description: state.description,
        amount: state.amount,
        paidBy: state.paidBy!,
        receivedBy: state.receivedBy,
        splitType: state.splitType,
        splitData: state.splitData,
        date: state.selectedDate,
        notes: state.notes,
      );

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
      );
      _resetForm();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  bool _validateForm() {
    if (state.selectedType == null) return false;
    if (state.description.isEmpty) return false;
    if (state.amount <= 0) return false;
    if (state.paidBy == null) return false;

    if (state.selectedType == TransactionType.borrow && state.receivedBy == null) {
      return false;
    }

    return true;
  }

  void _resetForm() {
    state = AddTransactionState(selectedDate: DateTime.now());
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void resetSuccess() {
    state = state.copyWith(isSuccess: false);
  }
}

final addTransactionProvider =
    StateNotifierProvider<AddTransactionNotifier, AddTransactionState>((ref) {
  final transactionRepository = ref.watch(_addTxnTransactionRepositoryProvider);
  return AddTransactionNotifier(transactionRepository);
});

// Internal providers to avoid circular imports
final _addTxnTransactionRepositoryProvider = Provider((ref) {
  final transactionService = ref.watch(_addTxnTransactionServiceProvider);
  return TransactionRepository(transactionService);
});

final _addTxnTransactionServiceProvider = Provider((ref) {
  final supabaseService = ref.watch(_addTxnSupabaseServiceProvider);
  return TransactionService(supabaseService);
});

final _addTxnSupabaseServiceProvider = Provider((ref) {
  return SupabaseService();
});

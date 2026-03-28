// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shared_expenses_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SharedTransaction _$SharedTransactionFromJson(Map<String, dynamic> json) {
  return _SharedTransaction.fromJson(json);
}

/// @nodoc
mixin _$SharedTransaction {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // 'user_paid_for_pool' | 'pool_expense'
  double get amount => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'month_key')
  String? get monthKey => throw _privateConstructorUsedError;

  /// Serializes this SharedTransaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SharedTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SharedTransactionCopyWith<SharedTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SharedTransactionCopyWith<$Res> {
  factory $SharedTransactionCopyWith(
    SharedTransaction value,
    $Res Function(SharedTransaction) then,
  ) = _$SharedTransactionCopyWithImpl<$Res, SharedTransaction>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    String type,
    double amount,
    String? description,
    DateTime date,
    String? notes,
    @JsonKey(name: 'month_key') String? monthKey,
  });
}

/// @nodoc
class _$SharedTransactionCopyWithImpl<$Res, $Val extends SharedTransaction>
    implements $SharedTransactionCopyWith<$Res> {
  _$SharedTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SharedTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? amount = null,
    Object? description = freezed,
    Object? date = null,
    Object? notes = freezed,
    Object? monthKey = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            monthKey: freezed == monthKey
                ? _value.monthKey
                : monthKey // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SharedTransactionImplCopyWith<$Res>
    implements $SharedTransactionCopyWith<$Res> {
  factory _$$SharedTransactionImplCopyWith(
    _$SharedTransactionImpl value,
    $Res Function(_$SharedTransactionImpl) then,
  ) = __$$SharedTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    String type,
    double amount,
    String? description,
    DateTime date,
    String? notes,
    @JsonKey(name: 'month_key') String? monthKey,
  });
}

/// @nodoc
class __$$SharedTransactionImplCopyWithImpl<$Res>
    extends _$SharedTransactionCopyWithImpl<$Res, _$SharedTransactionImpl>
    implements _$$SharedTransactionImplCopyWith<$Res> {
  __$$SharedTransactionImplCopyWithImpl(
    _$SharedTransactionImpl _value,
    $Res Function(_$SharedTransactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SharedTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? amount = null,
    Object? description = freezed,
    Object? date = null,
    Object? notes = freezed,
    Object? monthKey = freezed,
  }) {
    return _then(
      _$SharedTransactionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        monthKey: freezed == monthKey
            ? _value.monthKey
            : monthKey // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SharedTransactionImpl extends _SharedTransaction {
  const _$SharedTransactionImpl({
    required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    required this.type,
    required this.amount,
    this.description,
    required this.date,
    this.notes,
    @JsonKey(name: 'month_key') this.monthKey,
  }) : super._();

  factory _$SharedTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SharedTransactionImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String type;
  // 'user_paid_for_pool' | 'pool_expense'
  @override
  final double amount;
  @override
  final String? description;
  @override
  final DateTime date;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'month_key')
  final String? monthKey;

  @override
  String toString() {
    return 'SharedTransaction(id: $id, userId: $userId, type: $type, amount: $amount, description: $description, date: $date, notes: $notes, monthKey: $monthKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SharedTransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.monthKey, monthKey) ||
                other.monthKey == monthKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    type,
    amount,
    description,
    date,
    notes,
    monthKey,
  );

  /// Create a copy of SharedTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SharedTransactionImplCopyWith<_$SharedTransactionImpl> get copyWith =>
      __$$SharedTransactionImplCopyWithImpl<_$SharedTransactionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SharedTransactionImplToJson(this);
  }
}

abstract class _SharedTransaction extends SharedTransaction {
  const factory _SharedTransaction({
    required final String id,
    @JsonKey(name: 'user_id') required final String userId,
    required final String type,
    required final double amount,
    final String? description,
    required final DateTime date,
    final String? notes,
    @JsonKey(name: 'month_key') final String? monthKey,
  }) = _$SharedTransactionImpl;
  const _SharedTransaction._() : super._();

  factory _SharedTransaction.fromJson(Map<String, dynamic> json) =
      _$SharedTransactionImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get type; // 'user_paid_for_pool' | 'pool_expense'
  @override
  double get amount;
  @override
  String? get description;
  @override
  DateTime get date;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'month_key')
  String? get monthKey;

  /// Create a copy of SharedTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SharedTransactionImplCopyWith<_$SharedTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TripSummary _$TripSummaryFromJson(Map<String, dynamic> json) {
  return _TripSummary.fromJson(json);
}

/// @nodoc
mixin _$TripSummary {
  @JsonKey(name: 'trip_id')
  String? get tripId => throw _privateConstructorUsedError;
  @JsonKey(name: 'trip_name')
  String? get tripName => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  DateTime? get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  DateTime? get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_days')
  int? get durationDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_expense')
  double? get totalExpense => throw _privateConstructorUsedError;

  /// Serializes this TripSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TripSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TripSummaryCopyWith<TripSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripSummaryCopyWith<$Res> {
  factory $TripSummaryCopyWith(
    TripSummary value,
    $Res Function(TripSummary) then,
  ) = _$TripSummaryCopyWithImpl<$Res, TripSummary>;
  @useResult
  $Res call({
    @JsonKey(name: 'trip_id') String? tripId,
    @JsonKey(name: 'trip_name') String? tripName,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'duration_days') int? durationDays,
    @JsonKey(name: 'total_expense') double? totalExpense,
  });
}

/// @nodoc
class _$TripSummaryCopyWithImpl<$Res, $Val extends TripSummary>
    implements $TripSummaryCopyWith<$Res> {
  _$TripSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TripSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tripId = freezed,
    Object? tripName = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? durationDays = freezed,
    Object? totalExpense = freezed,
  }) {
    return _then(
      _value.copyWith(
            tripId: freezed == tripId
                ? _value.tripId
                : tripId // ignore: cast_nullable_to_non_nullable
                      as String?,
            tripName: freezed == tripName
                ? _value.tripName
                : tripName // ignore: cast_nullable_to_non_nullable
                      as String?,
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            endDate: freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            durationDays: freezed == durationDays
                ? _value.durationDays
                : durationDays // ignore: cast_nullable_to_non_nullable
                      as int?,
            totalExpense: freezed == totalExpense
                ? _value.totalExpense
                : totalExpense // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TripSummaryImplCopyWith<$Res>
    implements $TripSummaryCopyWith<$Res> {
  factory _$$TripSummaryImplCopyWith(
    _$TripSummaryImpl value,
    $Res Function(_$TripSummaryImpl) then,
  ) = __$$TripSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'trip_id') String? tripId,
    @JsonKey(name: 'trip_name') String? tripName,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'duration_days') int? durationDays,
    @JsonKey(name: 'total_expense') double? totalExpense,
  });
}

/// @nodoc
class __$$TripSummaryImplCopyWithImpl<$Res>
    extends _$TripSummaryCopyWithImpl<$Res, _$TripSummaryImpl>
    implements _$$TripSummaryImplCopyWith<$Res> {
  __$$TripSummaryImplCopyWithImpl(
    _$TripSummaryImpl _value,
    $Res Function(_$TripSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TripSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tripId = freezed,
    Object? tripName = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? durationDays = freezed,
    Object? totalExpense = freezed,
  }) {
    return _then(
      _$TripSummaryImpl(
        tripId: freezed == tripId
            ? _value.tripId
            : tripId // ignore: cast_nullable_to_non_nullable
                  as String?,
        tripName: freezed == tripName
            ? _value.tripName
            : tripName // ignore: cast_nullable_to_non_nullable
                  as String?,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        durationDays: freezed == durationDays
            ? _value.durationDays
            : durationDays // ignore: cast_nullable_to_non_nullable
                  as int?,
        totalExpense: freezed == totalExpense
            ? _value.totalExpense
            : totalExpense // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TripSummaryImpl extends _TripSummary {
  const _$TripSummaryImpl({
    @JsonKey(name: 'trip_id') this.tripId,
    @JsonKey(name: 'trip_name') this.tripName,
    @JsonKey(name: 'start_date') this.startDate,
    @JsonKey(name: 'end_date') this.endDate,
    @JsonKey(name: 'duration_days') this.durationDays,
    @JsonKey(name: 'total_expense') this.totalExpense,
  }) : super._();

  factory _$TripSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripSummaryImplFromJson(json);

  @override
  @JsonKey(name: 'trip_id')
  final String? tripId;
  @override
  @JsonKey(name: 'trip_name')
  final String? tripName;
  @override
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @override
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  @override
  @JsonKey(name: 'duration_days')
  final int? durationDays;
  @override
  @JsonKey(name: 'total_expense')
  final double? totalExpense;

  @override
  String toString() {
    return 'TripSummary(tripId: $tripId, tripName: $tripName, startDate: $startDate, endDate: $endDate, durationDays: $durationDays, totalExpense: $totalExpense)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripSummaryImpl &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.tripName, tripName) ||
                other.tripName == tripName) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.durationDays, durationDays) ||
                other.durationDays == durationDays) &&
            (identical(other.totalExpense, totalExpense) ||
                other.totalExpense == totalExpense));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    tripId,
    tripName,
    startDate,
    endDate,
    durationDays,
    totalExpense,
  );

  /// Create a copy of TripSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TripSummaryImplCopyWith<_$TripSummaryImpl> get copyWith =>
      __$$TripSummaryImplCopyWithImpl<_$TripSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripSummaryImplToJson(this);
  }
}

abstract class _TripSummary extends TripSummary {
  const factory _TripSummary({
    @JsonKey(name: 'trip_id') final String? tripId,
    @JsonKey(name: 'trip_name') final String? tripName,
    @JsonKey(name: 'start_date') final DateTime? startDate,
    @JsonKey(name: 'end_date') final DateTime? endDate,
    @JsonKey(name: 'duration_days') final int? durationDays,
    @JsonKey(name: 'total_expense') final double? totalExpense,
  }) = _$TripSummaryImpl;
  const _TripSummary._() : super._();

  factory _TripSummary.fromJson(Map<String, dynamic> json) =
      _$TripSummaryImpl.fromJson;

  @override
  @JsonKey(name: 'trip_id')
  String? get tripId;
  @override
  @JsonKey(name: 'trip_name')
  String? get tripName;
  @override
  @JsonKey(name: 'start_date')
  DateTime? get startDate;
  @override
  @JsonKey(name: 'end_date')
  DateTime? get endDate;
  @override
  @JsonKey(name: 'duration_days')
  int? get durationDays;
  @override
  @JsonKey(name: 'total_expense')
  double? get totalExpense;

  /// Create a copy of TripSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TripSummaryImplCopyWith<_$TripSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

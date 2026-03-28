// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserDebt _$UserDebtFromJson(Map<String, dynamic> json) {
  return _UserDebt.fromJson(json);
}

/// @nodoc
mixin _$UserDebt {
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'username')
  String get userName => throw _privateConstructorUsedError;
  @JsonKey(name: 'debt')
  double get amount => throw _privateConstructorUsedError;

  /// Serializes this UserDebt to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserDebt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserDebtCopyWith<UserDebt> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserDebtCopyWith<$Res> {
  factory $UserDebtCopyWith(UserDebt value, $Res Function(UserDebt) then) =
      _$UserDebtCopyWithImpl<$Res, UserDebt>;
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'username') String userName,
    @JsonKey(name: 'debt') double amount,
  });
}

/// @nodoc
class _$UserDebtCopyWithImpl<$Res, $Val extends UserDebt>
    implements $UserDebtCopyWith<$Res> {
  _$UserDebtCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserDebt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? amount = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserDebtImplCopyWith<$Res>
    implements $UserDebtCopyWith<$Res> {
  factory _$$UserDebtImplCopyWith(
    _$UserDebtImpl value,
    $Res Function(_$UserDebtImpl) then,
  ) = __$$UserDebtImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'username') String userName,
    @JsonKey(name: 'debt') double amount,
  });
}

/// @nodoc
class __$$UserDebtImplCopyWithImpl<$Res>
    extends _$UserDebtCopyWithImpl<$Res, _$UserDebtImpl>
    implements _$$UserDebtImplCopyWith<$Res> {
  __$$UserDebtImplCopyWithImpl(
    _$UserDebtImpl _value,
    $Res Function(_$UserDebtImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserDebt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? amount = null,
  }) {
    return _then(
      _$UserDebtImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserDebtImpl implements _UserDebt {
  const _$UserDebtImpl({
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'username') required this.userName,
    @JsonKey(name: 'debt') required this.amount,
  });

  factory _$UserDebtImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserDebtImplFromJson(json);

  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'username')
  final String userName;
  @override
  @JsonKey(name: 'debt')
  final double amount;

  @override
  String toString() {
    return 'UserDebt(userId: $userId, userName: $userName, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserDebtImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, userName, amount);

  /// Create a copy of UserDebt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserDebtImplCopyWith<_$UserDebtImpl> get copyWith =>
      __$$UserDebtImplCopyWithImpl<_$UserDebtImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserDebtImplToJson(this);
  }
}

abstract class _UserDebt implements UserDebt {
  const factory _UserDebt({
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'username') required final String userName,
    @JsonKey(name: 'debt') required final double amount,
  }) = _$UserDebtImpl;

  factory _UserDebt.fromJson(Map<String, dynamic> json) =
      _$UserDebtImpl.fromJson;

  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'username')
  String get userName;
  @override
  @JsonKey(name: 'debt')
  double get amount;

  /// Create a copy of UserDebt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserDebtImplCopyWith<_$UserDebtImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Debt _$DebtFromJson(Map<String, dynamic> json) {
  return _Debt.fromJson(json);
}

/// @nodoc
mixin _$Debt {
  String get userName => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;

  /// Serializes this Debt to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Debt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DebtCopyWith<Debt> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DebtCopyWith<$Res> {
  factory $DebtCopyWith(Debt value, $Res Function(Debt) then) =
      _$DebtCopyWithImpl<$Res, Debt>;
  @useResult
  $Res call({String userName, double amount});
}

/// @nodoc
class _$DebtCopyWithImpl<$Res, $Val extends Debt>
    implements $DebtCopyWith<$Res> {
  _$DebtCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Debt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userName = null, Object? amount = null}) {
    return _then(
      _value.copyWith(
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DebtImplCopyWith<$Res> implements $DebtCopyWith<$Res> {
  factory _$$DebtImplCopyWith(
    _$DebtImpl value,
    $Res Function(_$DebtImpl) then,
  ) = __$$DebtImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userName, double amount});
}

/// @nodoc
class __$$DebtImplCopyWithImpl<$Res>
    extends _$DebtCopyWithImpl<$Res, _$DebtImpl>
    implements _$$DebtImplCopyWith<$Res> {
  __$$DebtImplCopyWithImpl(_$DebtImpl _value, $Res Function(_$DebtImpl) _then)
    : super(_value, _then);

  /// Create a copy of Debt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userName = null, Object? amount = null}) {
    return _then(
      _$DebtImpl(
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DebtImpl implements _Debt {
  const _$DebtImpl({required this.userName, required this.amount});

  factory _$DebtImpl.fromJson(Map<String, dynamic> json) =>
      _$$DebtImplFromJson(json);

  @override
  final String userName;
  @override
  final double amount;

  @override
  String toString() {
    return 'Debt(userName: $userName, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DebtImpl &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userName, amount);

  /// Create a copy of Debt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DebtImplCopyWith<_$DebtImpl> get copyWith =>
      __$$DebtImplCopyWithImpl<_$DebtImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DebtImplToJson(this);
  }
}

abstract class _Debt implements Debt {
  const factory _Debt({
    required final String userName,
    required final double amount,
  }) = _$DebtImpl;

  factory _Debt.fromJson(Map<String, dynamic> json) = _$DebtImpl.fromJson;

  @override
  String get userName;
  @override
  double get amount;

  /// Create a copy of Debt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DebtImplCopyWith<_$DebtImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserLeave _$UserLeaveFromJson(Map<String, dynamic> json) {
  return _UserLeave.fromJson(json);
}

/// @nodoc
mixin _$UserLeave {
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'username')
  String get userName => throw _privateConstructorUsedError;
  int get used => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;

  /// Serializes this UserLeave to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserLeave
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserLeaveCopyWith<UserLeave> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserLeaveCopyWith<$Res> {
  factory $UserLeaveCopyWith(UserLeave value, $Res Function(UserLeave) then) =
      _$UserLeaveCopyWithImpl<$Res, UserLeave>;
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'username') String userName,
    int used,
    int total,
    int year,
  });
}

/// @nodoc
class _$UserLeaveCopyWithImpl<$Res, $Val extends UserLeave>
    implements $UserLeaveCopyWith<$Res> {
  _$UserLeaveCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserLeave
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? used = null,
    Object? total = null,
    Object? year = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            used: null == used
                ? _value.used
                : used // ignore: cast_nullable_to_non_nullable
                      as int,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            year: null == year
                ? _value.year
                : year // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserLeaveImplCopyWith<$Res>
    implements $UserLeaveCopyWith<$Res> {
  factory _$$UserLeaveImplCopyWith(
    _$UserLeaveImpl value,
    $Res Function(_$UserLeaveImpl) then,
  ) = __$$UserLeaveImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'username') String userName,
    int used,
    int total,
    int year,
  });
}

/// @nodoc
class __$$UserLeaveImplCopyWithImpl<$Res>
    extends _$UserLeaveCopyWithImpl<$Res, _$UserLeaveImpl>
    implements _$$UserLeaveImplCopyWith<$Res> {
  __$$UserLeaveImplCopyWithImpl(
    _$UserLeaveImpl _value,
    $Res Function(_$UserLeaveImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserLeave
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? used = null,
    Object? total = null,
    Object? year = null,
  }) {
    return _then(
      _$UserLeaveImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        used: null == used
            ? _value.used
            : used // ignore: cast_nullable_to_non_nullable
                  as int,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        year: null == year
            ? _value.year
            : year // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserLeaveImpl implements _UserLeave {
  const _$UserLeaveImpl({
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'username') required this.userName,
    required this.used,
    required this.total,
    required this.year,
  });

  factory _$UserLeaveImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserLeaveImplFromJson(json);

  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'username')
  final String userName;
  @override
  final int used;
  @override
  final int total;
  @override
  final int year;

  @override
  String toString() {
    return 'UserLeave(userId: $userId, userName: $userName, used: $used, total: $total, year: $year)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserLeaveImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.used, used) || other.used == used) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.year, year) || other.year == year));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, userName, used, total, year);

  /// Create a copy of UserLeave
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserLeaveImplCopyWith<_$UserLeaveImpl> get copyWith =>
      __$$UserLeaveImplCopyWithImpl<_$UserLeaveImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserLeaveImplToJson(this);
  }
}

abstract class _UserLeave implements UserLeave {
  const factory _UserLeave({
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'username') required final String userName,
    required final int used,
    required final int total,
    required final int year,
  }) = _$UserLeaveImpl;

  factory _UserLeave.fromJson(Map<String, dynamic> json) =
      _$UserLeaveImpl.fromJson;

  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'username')
  String get userName;
  @override
  int get used;
  @override
  int get total;
  @override
  int get year;

  /// Create a copy of UserLeave
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserLeaveImplCopyWith<_$UserLeaveImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

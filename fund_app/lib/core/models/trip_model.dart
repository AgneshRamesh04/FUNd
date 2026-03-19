import 'package:json_annotation/json_annotation.dart';

part 'trip_model.g.dart';

@JsonSerializable()
class Trip {
  final String id;
  final String name;
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @JsonKey(name: 'end_date')
  final DateTime endDate;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Trip({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
  Map<String, dynamic> toJson() => _$TripToJson(this);

  Trip copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
  }) {
    return Trip(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

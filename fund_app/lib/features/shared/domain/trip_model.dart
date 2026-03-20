class TripModel {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final double totalCost;

  TripModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.totalCost = 0.0,
  });

  factory TripModel.fromMap(Map<String, dynamic> map, double cost) {
    return TripModel(
      id: map['id'],
      name: map['name'],
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      totalCost: cost,
    );
  }
}
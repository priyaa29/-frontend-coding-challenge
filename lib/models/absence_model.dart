// Created By Priya Bangera
class Absence {
  final int? admitterId;
  final String admitterNote;
  final DateTime? confirmedAt;
  final DateTime createdAt;
  final int crewId;
  final DateTime endDate;
  final int id;
  final String memberNote;
  final DateTime? rejectedAt;
  final DateTime startDate;
  final String type;
  final int userId;

  Absence({
    this.admitterId,
    required this.admitterNote,
    this.confirmedAt,
    required this.createdAt,
    required this.crewId,
    required this.endDate,
    required this.id,
    required this.memberNote,
    this.rejectedAt,
    required this.startDate,
    required this.type,
    required this.userId,
  });

  // Factory method to create an Absence object from JSON data
  factory Absence.fromJson(Map<String, dynamic> json) {
    return Absence(
      admitterId: json['admitterId'] as int?,
      admitterNote: json['admitterNote'] != null
          ? json['admitterNote'].toString()
          : "",
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      crewId: json['crewId'] as int,
      endDate: DateTime.parse(json['endDate']),
      id: json['id'] as int,
      memberNote: json['memberNote'] != null
          ? json['memberNote'].toString()
          : "",
      rejectedAt: json['rejectedAt'] != null
          ? DateTime.parse(json['rejectedAt'])
          : null,
      startDate: DateTime.parse(json['startDate']),
      type: json['type'].toString(), // Ensure type is a string
      userId: json['userId'] as int,
    );
  }

  // Overriding toString method to log Absence object details
  @override
  String toString() {
    return '''
    Absence(
      id: $id, 
      userId: $userId, 
      type: $type, 
      startDate: $startDate, 
      endDate: $endDate, 
      admitterId: $admitterId, 
      crewId: $crewId, 
      memberNote: $memberNote, 
      admitterNote: $admitterNote, 
      createdAt: $createdAt, 
      confirmedAt: $confirmedAt, 
      rejectedAt: $rejectedAt
    )
    ''';
  }
}

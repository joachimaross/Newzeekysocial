import 'package:cloud_firestore/cloud_firestore.dart';

enum EventType { meeting, social, reminder, task, celebration }
enum EventStatus { draft, published, cancelled, completed }
enum RSVPStatus { none, going, maybe, notGoing }

class Event {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final String? virtualLink;
  final EventType type;
  final EventStatus status;
  final String organizerId;
  final List<String> invitedUserIds;
  final Map<String, RSVPStatus> rsvps;
  final bool isRecurring;
  final Map<String, dynamic> recurrenceRule;
  final List<DateTime> reminders;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.startTime,
    required this.endTime,
    this.location,
    this.virtualLink,
    required this.type,
    this.status = EventStatus.draft,
    required this.organizerId,
    this.invitedUserIds = const [],
    this.rsvps = const {},
    this.isRecurring = false,
    this.recurrenceRule = const {},
    this.reminders = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromMap(String id, Map<String, dynamic> map) {
    return Event(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      location: map['location'],
      virtualLink: map['virtualLink'],
      type: EventType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => EventType.meeting,
      ),
      status: EventStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => EventStatus.draft,
      ),
      organizerId: map['organizerId'] ?? '',
      invitedUserIds: List<String>.from(map['invitedUserIds'] ?? []),
      rsvps: Map<String, RSVPStatus>.from(
        (map['rsvps'] as Map<String, dynamic>? ?? {}).map(
          (key, value) => MapEntry(
            key,
            RSVPStatus.values.firstWhere(
              (e) => e.toString().split('.').last == value,
              orElse: () => RSVPStatus.none,
            ),
          ),
        ),
      ),
      isRecurring: map['isRecurring'] ?? false,
      recurrenceRule: Map<String, dynamic>.from(map['recurrenceRule'] ?? {}),
      reminders: (map['reminders'] as List<dynamic>? ?? [])
          .map((e) => (e as Timestamp).toDate())
          .toList(),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'location': location,
      'virtualLink': virtualLink,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'organizerId': organizerId,
      'invitedUserIds': invitedUserIds,
      'rsvps': rsvps.map(
        (key, value) => MapEntry(key, value.toString().split('.').last),
      ),
      'isRecurring': isRecurring,
      'recurrenceRule': recurrenceRule,
      'reminders': reminders.map((e) => Timestamp.fromDate(e)).toList(),
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  int get goingCount =>
      rsvps.values.where((status) => status == RSVPStatus.going).length;

  int get maybeCount =>
      rsvps.values.where((status) => status == RSVPStatus.maybe).length;

  bool get isUpcoming => startTime.isAfter(DateTime.now());
  bool get isActive =>
      DateTime.now().isAfter(startTime) && DateTime.now().isBefore(endTime);
  bool get isPast => endTime.isBefore(DateTime.now());

  Duration get duration => endTime.difference(startTime);

  Event copyWith({
    String? title,
    String? description,
    String? imageUrl,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? virtualLink,
    EventType? type,
    EventStatus? status,
    List<String>? invitedUserIds,
    Map<String, RSVPStatus>? rsvps,
    bool? isRecurring,
    Map<String, dynamic>? recurrenceRule,
    List<DateTime>? reminders,
    Map<String, dynamic>? metadata,
  }) {
    return Event(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      virtualLink: virtualLink ?? this.virtualLink,
      type: type ?? this.type,
      status: status ?? this.status,
      organizerId: organizerId,
      invitedUserIds: invitedUserIds ?? this.invitedUserIds,
      rsvps: rsvps ?? this.rsvps,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      reminders: reminders ?? this.reminders,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
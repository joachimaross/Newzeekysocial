import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zeeky_social/models/event_model.dart';
import 'package:zeeky_social/services/notification_service.dart';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  Timer? _reminderTimer;

  void initialize() {
    // Start periodic reminder check
    _reminderTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      _processEventReminders();
    });
  }

  void dispose() {
    _reminderTimer?.cancel();
  }

  // Create a new event
  Future<String?> createEvent({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    String? virtualLink,
    EventType type = EventType.meeting,
    List<String> invitedUserIds = const [],
    bool isRecurring = false,
    Map<String, dynamic> recurrenceRule = const {},
    List<DateTime> reminders = const [],
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final now = DateTime.now();
      final event = Event(
        id: '', // Will be set by Firestore
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        location: location,
        virtualLink: virtualLink,
        type: type,
        organizerId: user.uid,
        invitedUserIds: invitedUserIds,
        isRecurring: isRecurring,
        recurrenceRule: recurrenceRule,
        reminders: reminders,
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await _db.collection('events').add(event.toMap());

      // Send invitations to invited users
      if (invitedUserIds.isNotEmpty) {
        await _sendEventInvitations(docRef.id, invitedUserIds, event);
      }

      // Schedule reminders
      if (reminders.isNotEmpty) {
        await _scheduleEventReminders(docRef.id, reminders, event);
      }

      return docRef.id;
    } catch (e) {
      print('Error creating event: $e');
      return null;
    }
  }

  // Get event by ID
  Future<Event?> getEvent(String eventId) async {
    try {
      final doc = await _db.collection('events').doc(eventId).get();
      if (doc.exists) {
        return Event.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting event: $e');
      return null;
    }
  }

  // Get user's events
  Stream<List<Event>> getUserEvents({
    DateTime? startDate,
    DateTime? endDate,
    bool includeInvited = true,
  }) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    Query query = _db.collection('events');

    // Date filtering
    if (startDate != null) {
      query = query.where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    return query
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
      final events = snapshot.docs
          .map((doc) => Event.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .where((event) {
        // Filter events user is involved in
        return event.organizerId == user.uid ||
               (includeInvited && event.invitedUserIds.contains(user.uid));
      }).toList();

      return events;
    });
  }

  // Get events for a specific date
  Future<List<Event>> getEventsForDate(DateTime date) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final snapshot = await _db
          .collection('events')
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('startTime')
          .get();

      return snapshot.docs
          .map((doc) => Event.fromMap(doc.id, doc.data()))
          .where((event) =>
              event.organizerId == user.uid ||
              event.invitedUserIds.contains(user.uid))
          .toList();
    } catch (e) {
      print('Error getting events for date: $e');
      return [];
    }
  }

  // RSVP to an event
  Future<void> rsvpToEvent(String eventId, RSVPStatus status) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _db.collection('events').doc(eventId).update({
        'rsvps.${user.uid}': status.toString().split('.').last,
      });

      // Notify event organizer
      final event = await getEvent(eventId);
      if (event != null && event.organizerId != user.uid) {
        await _notificationService.sendNotification(
          userId: event.organizerId,
          title: 'RSVP Update',
          body: '${user.displayName} ${_getRSVPText(status)} to "${event.title}"',
          type: 'event_rsvp',
          data: {'eventId': eventId, 'status': status.toString().split('.').last},
        );
      }
    } catch (e) {
      print('Error RSVP to event: $e');
    }
  }

  // Update event
  Future<void> updateEvent(String eventId, Map<String, dynamic> updates) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final event = await getEvent(eventId);
      if (event == null || event.organizerId != user.uid) return;

      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _db.collection('events').doc(eventId).update(updates);

      // Notify attendees of changes
      await _notifyAttendeesOfUpdate(eventId, event, updates);
    } catch (e) {
      print('Error updating event: $e');
    }
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final event = await getEvent(eventId);
      if (event == null || event.organizerId != user.uid) return;

      // Delete the event
      await _db.collection('events').doc(eventId).delete();

      // Delete related reminders
      await _deleteEventReminders(eventId);

      // Notify attendees of cancellation
      await _notifyAttendeesOfCancellation(event);
    } catch (e) {
      print('Error deleting event: $e');
    }
  }

  // Get upcoming events
  Stream<List<Event>> getUpcomingEvents({int limit = 10}) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('events')
        .where('startTime', isGreaterThan: Timestamp.now())
        .orderBy('startTime')
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromMap(doc.id, doc.data()))
            .where((event) =>
                event.organizerId == user.uid ||
                event.invitedUserIds.contains(user.uid))
            .toList());
  }

  // Search events
  Future<List<Event>> searchEvents(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final snapshot = await _db
          .collection('events')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => Event.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error searching events: $e');
      return [];
    }
  }

  // Get public events (for discovery)
  Stream<List<Event>> getPublicEvents({int limit = 20}) {
    return _db
        .collection('events')
        .where('status', isEqualTo: 'published')
        .where('startTime', isGreaterThan: Timestamp.now())
        .orderBy('startTime')
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Smart scheduling - find optimal time slot
  Future<List<DateTime>> suggestOptimalTimes({
    required Duration eventDuration,
    required List<String> participantIds,
    DateTime? preferredStart,
    DateTime? preferredEnd,
    int suggestions = 3,
  }) async {
    try {
      final startDate = preferredStart ?? DateTime.now();
      final endDate = preferredEnd ?? DateTime.now().add(const Duration(days: 7));

      // Get all participants' events in the time range
      final conflictingEvents = await _getConflictingEvents(
        participantIds,
        startDate,
        endDate,
      );

      // Find free time slots
      final suggestions = _findFreeTimeSlots(
        conflictingEvents,
        startDate,
        endDate,
        eventDuration,
        suggestions,
      );

      return suggestions;
    } catch (e) {
      print('Error suggesting optimal times: $e');
      return [];
    }
  }

  // Generate recurring events
  Future<List<String>> createRecurringEvents({
    required Event baseEvent,
    required Map<String, dynamic> recurrenceRule,
    DateTime? endDate,
    int? maxOccurrences,
  }) async {
    try {
      final eventIds = <String>[];
      final occurrences = _generateRecurrenceOccurrences(
        baseEvent.startTime,
        baseEvent.endTime,
        recurrenceRule,
        endDate: endDate,
        maxOccurrences: maxOccurrences,
      );

      for (final occurrence in occurrences) {
        final recurringEvent = baseEvent.copyWith(
          startTime: occurrence['start'],
          endTime: occurrence['end'],
        );

        final docRef = await _db.collection('events').add(recurringEvent.toMap());
        eventIds.add(docRef.id);
      }

      return eventIds;
    } catch (e) {
      print('Error creating recurring events: $e');
      return [];
    }
  }

  // Private helper methods

  Future<void> _sendEventInvitations(
    String eventId,
    List<String> invitedUserIds,
    Event event,
  ) async {
    for (final userId in invitedUserIds) {
      await _notificationService.sendNotification(
        userId: userId,
        title: 'Event Invitation',
        body: 'You\'re invited to "${event.title}"',
        type: 'event_invitation',
        data: {
          'eventId': eventId,
          'eventTitle': event.title,
          'startTime': event.startTime.toIso8601String(),
        },
      );
    }
  }

  Future<void> _scheduleEventReminders(
    String eventId,
    List<DateTime> reminders,
    Event event,
  ) async {
    for (final reminderTime in reminders) {
      await _db.collection('event_reminders').add({
        'eventId': eventId,
        'userId': event.organizerId,
        'reminderTime': Timestamp.fromDate(reminderTime),
        'eventTitle': event.title,
        'eventStartTime': Timestamp.fromDate(event.startTime),
        'isProcessed': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _processEventReminders() async {
    try {
      final now = DateTime.now();
      final reminderWindow = now.add(const Duration(minutes: 15));

      final remindersQuery = await _db
          .collection('event_reminders')
          .where('reminderTime', isLessThanOrEqualTo: Timestamp.fromDate(reminderWindow))
          .where('isProcessed', isEqualTo: false)
          .get();

      for (final doc in remindersQuery.docs) {
        final data = doc.data();
        await _notificationService.sendNotification(
          userId: data['userId'],
          title: 'Event Reminder',
          body: 'Reminder: "${data['eventTitle']}" starts soon',
          type: 'event_reminder',
          data: {
            'eventId': data['eventId'],
            'eventTitle': data['eventTitle'],
          },
        );

        // Mark as processed
        await doc.reference.update({'isProcessed': true});
      }
    } catch (e) {
      print('Error processing event reminders: $e');
    }
  }

  Future<void> _notifyAttendeesOfUpdate(
    String eventId,
    Event event,
    Map<String, dynamic> updates,
  ) async {
    final attendeeIds = <String>[...event.invitedUserIds];
    if (!attendeeIds.contains(event.organizerId)) {
      attendeeIds.add(event.organizerId);
    }

    for (final userId in attendeeIds) {
      await _notificationService.sendNotification(
        userId: userId,
        title: 'Event Updated',
        body: 'Event "${event.title}" has been updated',
        type: 'event_update',
        data: {'eventId': eventId, 'updates': updates},
      );
    }
  }

  Future<void> _notifyAttendeesOfCancellation(Event event) async {
    final attendeeIds = <String>[...event.invitedUserIds];

    for (final userId in attendeeIds) {
      await _notificationService.sendNotification(
        userId: userId,
        title: 'Event Cancelled',
        body: 'Event "${event.title}" has been cancelled',
        type: 'event_cancelled',
        data: {'eventId': event.id},
      );
    }
  }

  Future<void> _deleteEventReminders(String eventId) async {
    final remindersQuery = await _db
        .collection('event_reminders')
        .where('eventId', isEqualTo: eventId)
        .get();

    final batch = _db.batch();
    for (final doc in remindersQuery.docs) {
      batch.delete(doc.reference);
    }

    if (remindersQuery.docs.isNotEmpty) {
      await batch.commit();
    }
  }

  Future<List<Event>> _getConflictingEvents(
    List<String> participantIds,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final events = <Event>[];

    for (final participantId in participantIds) {
      final snapshot = await _db
          .collection('events')
          .where('organizerId', isEqualTo: participantId)
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      events.addAll(snapshot.docs
          .map((doc) => Event.fromMap(doc.id, doc.data()))
          .toList());

      final invitedSnapshot = await _db
          .collection('events')
          .where('invitedUserIds', arrayContains: participantId)
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      events.addAll(invitedSnapshot.docs
          .map((doc) => Event.fromMap(doc.id, doc.data()))
          .toList());
    }

    return events;
  }

  List<DateTime> _findFreeTimeSlots(
    List<Event> conflicts,
    DateTime startDate,
    DateTime endDate,
    Duration eventDuration,
    int maxSuggestions,
  ) {
    final suggestions = <DateTime>[];
    final workingHours = [9, 17]; // 9 AM to 5 PM

    var currentTime = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      workingHours[0],
    );

    while (suggestions.length < maxSuggestions && currentTime.isBefore(endDate)) {
      final proposedEndTime = currentTime.add(eventDuration);

      // Check if this time slot conflicts with any existing events
      final hasConflict = conflicts.any((event) =>
          (currentTime.isBefore(event.endTime) && proposedEndTime.isAfter(event.startTime)));

      if (!hasConflict &&
          currentTime.hour >= workingHours[0] &&
          proposedEndTime.hour <= workingHours[1]) {
        suggestions.add(currentTime);
      }

      currentTime = currentTime.add(const Duration(minutes: 30));

      // Skip to next day if outside working hours
      if (currentTime.hour >= workingHours[1]) {
        currentTime = DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day + 1,
          workingHours[0],
        );
      }
    }

    return suggestions;
  }

  List<Map<String, DateTime>> _generateRecurrenceOccurrences(
    DateTime startTime,
    DateTime endTime,
    Map<String, dynamic> recurrenceRule,
    {DateTime? endDate,
    int? maxOccurrences}
  ) {
    final occurrences = <Map<String, DateTime>>[];
    final duration = endTime.difference(startTime);

    var currentStart = startTime;
    int count = 0;

    final frequency = recurrenceRule['frequency'] ?? 'weekly';
    final interval = recurrenceRule['interval'] ?? 1;
    final until = endDate ?? DateTime.now().add(const Duration(days: 365));
    final max = maxOccurrences ?? 100;

    while (currentStart.isBefore(until) && count < max) {
      occurrences.add({
        'start': currentStart,
        'end': currentStart.add(duration),
      });

      count++;

      switch (frequency) {
        case 'daily':
          currentStart = currentStart.add(Duration(days: interval));
          break;
        case 'weekly':
          currentStart = currentStart.add(Duration(days: 7 * interval));
          break;
        case 'monthly':
          currentStart = DateTime(
            currentStart.year,
            currentStart.month + interval,
            currentStart.day,
            currentStart.hour,
            currentStart.minute,
          );
          break;
        case 'yearly':
          currentStart = DateTime(
            currentStart.year + interval,
            currentStart.month,
            currentStart.day,
            currentStart.hour,
            currentStart.minute,
          );
          break;
      }
    }

    return occurrences;
  }

  String _getRSVPText(RSVPStatus status) {
    switch (status) {
      case RSVPStatus.going:
        return 'is going';
      case RSVPStatus.maybe:
        return 'might go';
      case RSVPStatus.notGoing:
        return 'can\'t attend';
      case RSVPStatus.none:
        return 'hasn\'t responded';
    }
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zeeky_social/services/event_service.dart';
import 'package:zeeky_social/services/auth_service.dart';
import 'package:zeeky_social/models/event_model.dart';
import 'package:intl/intl.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  EventsScreenState createState() => EventsScreenState();
}

class EventsScreenState extends State<EventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Calendar'),
            Tab(text: 'Discover'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createEvent,
            tooltip: 'Create Event',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUpcomingEvents(),
          _buildCalendarView(),
          _buildDiscoverEvents(),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    final eventService = Provider.of<EventService>(context, listen: false);
    
    return StreamBuilder<List<Event>>(
      stream: eventService.getUpcomingEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final events = snapshot.data ?? [];
        
        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.event, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No upcoming events',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create an event to get started',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _createEvent,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Event'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return _buildEventCard(event);
          },
        );
      },
    );
  }

  Widget _buildCalendarView() {
    return Column(
      children: [
        // Simple calendar header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(
                      _selectedDate.year,
                      _selectedDate.month - 1,
                      _selectedDate.day,
                    );
                  });
                },
              ),
              Text(
                DateFormat.yMMMM().format(_selectedDate),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(
                      _selectedDate.year,
                      _selectedDate.month + 1,
                      _selectedDate.day,
                    );
                  });
                },
              ),
            ],
          ),
        ),
        
        // Calendar grid (simplified)
        Expanded(
          child: _buildSimpleCalendar(),
        ),
      ],
    );
  }

  Widget _buildSimpleCalendar() {
    final eventService = Provider.of<EventService>(context, listen: false);
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    return StreamBuilder<List<Event>>(
      stream: eventService.getUserEvents(
        startDate: firstDayOfMonth,
        endDate: lastDayOfMonth,
      ),
      builder: (context, snapshot) {
        final events = snapshot.data ?? [];
        final eventsByDay = <int, List<Event>>{};
        
        for (final event in events) {
          final day = event.startTime.day;
          eventsByDay[day] = [...(eventsByDay[day] ?? []), event];
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: daysInMonth + (firstDayOfMonth.weekday - 1),
          itemBuilder: (context, index) {
            if (index < firstDayOfMonth.weekday - 1) {
              return const SizedBox(); // Empty cells for days before month starts
            }

            final day = index - (firstDayOfMonth.weekday - 1) + 1;
            final dayEvents = eventsByDay[day] ?? [];
            final isToday = _isToday(DateTime(_selectedDate.year, _selectedDate.month, day));
            final isSelected = _selectedDate.day == day;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, day);
                });
                if (dayEvents.isNotEmpty) {
                  _showDayEvents(dayEvents);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : isToday
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                  borderRadius: BorderRadius.circular(8),
                  border: dayEvents.isNotEmpty
                      ? Border.all(color: Theme.of(context).colorScheme.secondary)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: isToday ? FontWeight.bold : null,
                      ),
                    ),
                    if (dayEvents.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDiscoverEvents() {
    final eventService = Provider.of<EventService>(context, listen: false);
    
    return StreamBuilder<List<Event>>(
      stream: eventService.getPublicEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data ?? [];
        
        if (events.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.explore, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No public events',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return _buildEventCard(event, showRSVP: true);
          },
        );
      },
    );
  }

  Widget _buildEventCard(Event event, {bool showRSVP = false}) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    final userRSVP = currentUser != null ? event.rsvps[currentUser.uid] : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getEventIcon(event.type),
                    color: Theme.of(context).colorScheme.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat.yMMMEd().add_jm().format(event.startTime),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (event.isUpcoming)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Upcoming',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            if (event.description.isNotEmpty)
              Text(
                event.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            
            if (event.location != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                // RSVP counts
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${event.goingCount} going',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    if (event.maybeCount > 0) ...[
                      const Text(' • ', style: TextStyle(color: Colors.grey)),
                      Text(
                        '${event.maybeCount} maybe',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ],
                ),
                
                const Spacer(),
                
                // RSVP buttons or status
                if (showRSVP && currentUser != null) ...[
                  if (userRSVP == null) ...[
                    TextButton(
                      onPressed: () => _rsvpToEvent(event, RSVPStatus.going),
                      child: const Text('Going'),
                    ),
                    TextButton(
                      onPressed: () => _rsvpToEvent(event, RSVPStatus.maybe),
                      child: const Text('Maybe'),
                    ),
                  ] else ...[
                    Chip(
                      label: Text(_getRSVPText(userRSVP)),
                      backgroundColor: _getRSVPColor(userRSVP),
                      onDeleted: () => _rsvpToEvent(event, RSVPStatus.none),
                      deleteIcon: const Icon(Icons.close, size: 16),
                    ),
                  ],
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDayEvents(List<Event> events) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Events on ${DateFormat.MMMEd().format(_selectedDate)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return ListTile(
                      leading: Icon(_getEventIcon(event.type)),
                      title: Text(event.title),
                      subtitle: Text(DateFormat.jm().format(event.startTime)),
                      trailing: Text(event.duration.inHours < 24
                          ? '${event.duration.inHours}h ${event.duration.inMinutes % 60}m'
                          : '${event.duration.inDays}d'),
                      onTap: () {
                        Navigator.pop(context);
                        _viewEvent(event);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createEvent() {
    // TODO: Implement event creation UI
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event creation coming soon!')),
    );
  }

  void _viewEvent(Event event) {
    // TODO: Implement event detail view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing event: ${event.title}')),
    );
  }

  void _rsvpToEvent(Event event, RSVPStatus status) {
    final eventService = Provider.of<EventService>(context, listen: false);
    eventService.rsvpToEvent(event.id, status);
    
    String message = status == RSVPStatus.none
        ? 'RSVP cancelled'
        : 'RSVP updated to ${_getRSVPText(status)}';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.meeting:
        return Icons.business;
      case EventType.social:
        return Icons.celebration;
      case EventType.reminder:
        return Icons.notifications;
      case EventType.task:
        return Icons.task;
      case EventType.celebration:
        return Icons.cake;
    }
  }

  String _getRSVPText(RSVPStatus status) {
    switch (status) {
      case RSVPStatus.going:
        return 'Going';
      case RSVPStatus.maybe:
        return 'Maybe';
      case RSVPStatus.notGoing:
        return 'Not going';
      case RSVPStatus.none:
        return 'No response';
    }
  }

  Color _getRSVPColor(RSVPStatus status) {
    switch (status) {
      case RSVPStatus.going:
        return Colors.green.shade100;
      case RSVPStatus.maybe:
        return Colors.orange.shade100;
      case RSVPStatus.notGoing:
        return Colors.red.shade100;
      case RSVPStatus.none:
        return Colors.grey.shade100;
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
class Organization {
  final String id;
  final String code;
  final String name;
  final bool isActive;

  Organization({
    required this.id,
    required this.code,
    required this.name,
    required this.isActive,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      isActive: json['is_active'],
    );
  }
}

class Program {
  final String id;
  final String name;
  final Organization organization;
  final bool isActive;
  final DateTime createdAt;

  Program({
    required this.id,
    required this.name,
    required this.organization,
    required this.isActive,
    required this.createdAt,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['id'],
      name: json['name'],
      organization: Organization.fromJson(json['organization']),
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class Event {
  final String id;
  final String title;
  final String description;
  final String shortCode;
  final Program program;
  final bool isArchived;
  final bool isConcluded;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.shortCode,
    required this.program,
    required this.isArchived,
    required this.isConcluded,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      shortCode: json['short_code'],
      program: Program.fromJson(json['program']),
      isArchived: json['is_archived'],
      isConcluded: json['is_concluded'],
    );
  }
}

class Attendee {
  final String id;
  final String email;
  final String phone;
  final String name;

  Attendee({
    required this.id,
    required this.email,
    required this.phone,
    required this.name,
  });

  factory Attendee.fromJson(Map<String, dynamic> json) {
    return Attendee(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      name: json['name'],
    );
  }
}

class Attendance {
  final String id;
  final Event event;
  final Attendee attendee;
  final String displayName;
  final bool valid;
  final DateTime createdAt;

  Attendance({
    required this.id,
    required this.event,
    required this.attendee,
    required this.displayName,
    required this.valid,
    required this.createdAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      event: Event.fromJson(json['event']),
      attendee: Attendee.fromJson(json['attendee']),
      displayName: json['display_name'],
      valid: json['valid'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class AttendanceResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<Attendance> results;

  AttendanceResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List)
          .map((item) => Attendance.fromJson(item))
          .toList(),
    );
  }
}
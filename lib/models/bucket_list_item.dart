import 'package:hive/hive.dart';

part 'bucket_list_item.g.dart';

@HiveType(typeId: 0)
class Expense {
  @HiveField(0)
  String name;

  @HiveField(1)
  double amount;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String category;

  Expense({
    required this.name,
    required this.amount,
    required this.date,
    required this.category,
  });
}

@HiveType(typeId: 1)
class Goal {
  @HiveField(0)
  final String description;

  @HiveField(1)
  bool isCompleted;

  Goal({required this.description, this.isCompleted = false});
}

@HiveType(typeId: 2) // Ensure this typeId is unique
class BucketListItem {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final String category; // "Upcoming", "Dream Trips", "Visited", etc.

  @HiveField(3)
  final DateTime? startDate; // Start date for "Visited" trips

  @HiveField(4)
  final DateTime? targetedDate; // Target date for "Upcoming" trips

  @HiveField(5)
  final List<String> packingList; // Packing list for "Upcoming" trips

  @HiveField(6)
  final double? estimatedBudget; // Budget for "Dream Trips"

  @HiveField(7)
  final String? dreamingTimeSpan; // Time span for "Dream Trips"

  @HiveField(8)
  final DateTime? endDate; // End date for "Visited" trips

  @HiveField(9)
  final double? spentBudget; // Amount spent on "Visited" trips

  @HiveField(10)
  final List<Expense> expenses; // Expense tracking for all trips

  @HiveField(11)
  final List<Map<String, dynamic>> activities; // Activities tracking

  @HiveField(12)
  final String? tripNotes; // Trip notes

  @HiveField(13)
  final List<String> mediaFiles; // File paths for images/videos

  @HiveField(14)
  final String? tripDiary; // 📝 New field for trip diary

  @HiveField(15)
  final String? endLocation; // 📍 New field for end location

  @HiveField(16)
  final String startLocation; // Added start location field

  @HiveField(17)
  final List<Goal> goals; // Added goals field

  BucketListItem({
    required this.name,
    required this.description,
    required this.category,
    this.startDate,
    this.targetedDate,
    List<String>? packingList,
    this.estimatedBudget,
    this.dreamingTimeSpan,
    this.endDate,
    this.spentBudget,
    List<Expense>? expenses,
    List<Map<String, dynamic>>? activities,
    this.tripNotes,
    List<String>? mediaFiles,
    this.tripDiary, // Added trip diary field
    this.endLocation,
    required this.startLocation,
    List<Goal>? goals, // Added goals parameter
  })  : packingList = packingList ?? [],
        expenses = expenses ?? [],
        activities = activities ?? [],
        mediaFiles = mediaFiles ?? [],
        goals = goals ?? []; // Initialize goals
}

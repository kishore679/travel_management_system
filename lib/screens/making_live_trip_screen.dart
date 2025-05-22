import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:travel_bucket_list/providers/trip_provider.dart';
import '../models/bucket_list_item.dart';

class MakingLiveTripScreen extends StatefulWidget {
  final BucketListItem trip;

  const MakingLiveTripScreen({super.key, required this.trip});

  @override
  _MakingLiveTripScreenState createState() => _MakingLiveTripScreenState();
}

class _MakingLiveTripScreenState extends State<MakingLiveTripScreen> {
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController startLocationController = TextEditingController();
  final TextEditingController expenseTitleController = TextEditingController();
  final TextEditingController expenseAmountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController goalController = TextEditingController();
  final TextEditingController tripDiaryController = TextEditingController();
  final TextEditingController endLocationController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  List<Expense> expenses = [];
  List<Map<String, dynamic>> activities = [];
  List<File> mediaFiles = [];
  bool isAddingExpense = false;
  bool isAddingGoal = false;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  List<Goal> goals = [];

  double get totalExpenses =>
      expenses.fold(0, (sum, item) => sum + item.amount);
  double get targetBudget => double.tryParse(budgetController.text) ?? 0.0;
  double get budgetUsage =>
      targetBudget > 0 ? totalExpenses / targetBudget : 0.0;

  final ImagePicker _picker = ImagePicker();
  late Box<BucketListItem> _tripBox;

  @override
  void initState() {
    super.initState();
    _tripBox = Hive.box<BucketListItem>('live_trips');

    // Pre-fill the fields with the trip data
    destinationController.text = widget.trip.name;
    descriptionController.text = widget.trip.description;
    startLocationController.text = widget.trip.startLocation;
    endLocationController.text = widget.trip.endLocation ?? '';
    selectedStartDate = widget.trip.startDate;
    selectedEndDate = widget.trip.endDate;
    notesController.text = widget.trip.tripNotes ?? '';
    tripDiaryController.text = widget.trip.tripDiary ?? '';
    expenses = List<Expense>.from(widget.trip.expenses);
    activities = widget.trip.activities;
    mediaFiles = widget.trip.mediaFiles.map((path) => File(path)).toList();

    // Populate the start and end date controllers
    startDateController.text = selectedStartDate != null
        ? "${selectedStartDate!.toLocal()}".split(' ')[0]
        : '';
    endDateController.text = selectedEndDate != null
        ? "${selectedEndDate!.toLocal()}".split(' ')[0]
        : '';

    // Set the budget controller text
    budgetController.text = widget.trip.estimatedBudget?.toString() ?? '';

    // Initialize goals
    goals = List<Goal>.from(widget.trip.goals);
  }

  void _pickStartDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedStartDate = pickedDate;
        startDateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  void _pickEndDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedEndDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedEndDate = pickedDate;
        endDateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  void _addExpense() {
    setState(() {
      isAddingExpense = true;
    });
  }

  void _saveExpense() {
    if (expenseTitleController.text.isNotEmpty &&
        expenseAmountController.text.isNotEmpty) {
      setState(() {
        expenses.add(Expense(
          name: expenseTitleController.text,
          amount: double.tryParse(expenseAmountController.text) ?? 0.0,
          date: DateTime.now(),
          category: "General",
        ));
        expenseTitleController.clear();
        expenseAmountController.clear();
        isAddingExpense = false;
      });
    }
  }

  void _deleteExpense(int index) {
    setState(() {
      expenses.removeAt(index);
    });
  }

  void _saveTrip() {
    if (destinationController.text.isNotEmpty) {
      final trip = BucketListItem(
        name: destinationController.text,
        description: descriptionController.text,
        category: 'Ongoing',
        startDate: selectedStartDate,
        endDate: selectedEndDate,
        expenses: expenses,
        activities: activities,
        tripNotes: notesController.text,
        mediaFiles: mediaFiles.map((file) => file.path).toList(),
        tripDiary: tripDiaryController.text,
        endLocation: endLocationController.text,
        startLocation: startLocationController.text,
        goals: goals,
        estimatedBudget: targetBudget,
      );

      // Add the trip to the ongoing trips list using the provider
      Provider.of<TripProvider>(context, listen: false).addOngoingTrip(trip);

      // Close the screen
      Navigator.pop(context);
    }
  }

  void _endTrip() {
    if (destinationController.text.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("End Trip"),
        content: const Text("Are you sure you want to end the trip?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              final trip = BucketListItem(
                name: destinationController.text,
                description: descriptionController.text,
                category: 'Completed',
                startDate: selectedStartDate,
                endDate: selectedEndDate,
                expenses: expenses,
                activities: activities,
                tripNotes: notesController.text,
                mediaFiles: mediaFiles.map((file) => file.path).toList(),
                tripDiary: tripDiaryController.text,
                endLocation: endLocationController.text,
                startLocation: startLocationController.text,
                goals: goals,
                estimatedBudget: targetBudget,
              );

              // Save the trip to the Hive box
              _tripBox.add(trip);

              // Remove the trip from ongoing trips in the provider
              Provider.of<TripProvider>(context, listen: false)
                  .deleteOngoingTrip(trip);

              // Close the screen
              Navigator.pop(context); // Close the dialog
              Navigator.pop(context); // Close the MakingLiveTripScreen
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  void _addGoal() {
    setState(() {
      isAddingGoal = true;
    });
  }

  void _saveGoal() {
    if (goalController.text.isNotEmpty) {
      setState(() {
        goals.add(Goal(description: goalController.text, isCompleted: false));
        goalController.clear();
        isAddingGoal = false;
      });
    }
  }

  void _toggleGoalCompletion(int index) {
    setState(() {
      goals[index].isCompleted = !goals[index].isCompleted;
    });
  }

  Future<void> _pickMedia() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        mediaFiles.add(File(pickedFile.path));
      });
    }
  }

  void _deleteMedia(int index) {
    setState(() {
      mediaFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Making Live Trip"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
                controller: destinationController,
                decoration: const InputDecoration(labelText: "Destination")),
            TextField(
                controller: descriptionController,
                decoration:
                    const InputDecoration(labelText: "Trip Description")),
            TextField(
                controller: startLocationController,
                decoration:
                    const InputDecoration(labelText: "Starting Location")),
            const SizedBox(height: 16),
            TextField(
              controller: startDateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Start Date",
                suffixIcon: Icon(Icons.calendar_today, color: Colors.blue),
              ),
              onTap: _pickStartDate,
            ),
            const SizedBox(height: 16),
            const Text("💰 Expense Tracker",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: budgetController,
              decoration:
                  const InputDecoration(labelText: "Target Budget (\$)"),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Text("Total Expenses: \$${totalExpenses.toStringAsFixed(2)}"),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: budgetUsage.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(
                budgetUsage > 1 ? Colors.red : Colors.green,
              ),
            ),
            Text(
              "${(budgetUsage * 100).clamp(0, 100).toStringAsFixed(1)}% of Budget Used",
              style: TextStyle(
                color: budgetUsage > 1 ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (isAddingExpense) ...[
              TextField(
                  controller: expenseTitleController,
                  decoration:
                      const InputDecoration(labelText: "Expense Title")),
              TextField(
                  controller: expenseAmountController,
                  decoration: const InputDecoration(labelText: "Amount"),
                  keyboardType: TextInputType.number),
              IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: _saveExpense),
            ] else ...[
              TextButton(
                  onPressed: _addExpense, child: const Text("+ Add Expense")),
            ],
            Column(
              children: expenses.map((expense) {
                return ListTile(
                  title: Text("${expense.name} - \$${expense.amount}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteExpense(expenses.indexOf(expense)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text("🎯 Goals",
                style: TextStyle(fontWeight: FontWeight.bold)),
            if (isAddingGoal) ...[
              TextField(
                  controller: goalController,
                  decoration: const InputDecoration(labelText: "Goal")),
              IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: _saveGoal),
            ] else ...[
              TextButton(onPressed: _addGoal, child: const Text("+ Add Goal")),
            ],
            Column(
              children: goals.map((goal) {
                return ListTile(
                  title: Text(goal.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () =>
                            _toggleGoalCompletion(goals.indexOf(goal)),
                        child: Text(
                            goal.isCompleted ? "Completed" : "Not Completed",
                            style: TextStyle(
                                color: goal.isCompleted
                                    ? Colors.green
                                    : Colors.red)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text("📸 Upload Photos/Videos",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: List.generate(mediaFiles.length, (index) {
                    return GestureDetector(
                      onLongPress: () async {
                        final result = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Delete Image"),
                            content: const Text(
                                "Are you sure you want to delete this image?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("No"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                  _deleteMedia(index);
                                },
                                child: const Text("Yes"),
                              ),
                            ],
                          ),
                        );
                        if (result != null && result) {
                          _deleteMedia(index);
                        }
                      },
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: Image.file(mediaFiles[index]),
                          ),
                        );
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(mediaFiles[index]),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    );
                  }) +
                  [
                    GestureDetector(
                      onTap: _pickMedia,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            const Icon(Icons.add, size: 40, color: Colors.grey),
                      ),
                    ),
                  ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: endDateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "End Date",
                suffixIcon: Icon(Icons.calendar_today, color: Colors.blue),
              ),
              onTap: _pickEndDate,
            ),
            const SizedBox(height: 16),
            TextField(
                controller: endLocationController,
                decoration: const InputDecoration(labelText: "End Location")),
            const SizedBox(height: 16),
            const Text("📝 Trip Diary",
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: tripDiaryController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Write about your trip",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: _saveTrip, child: const Text("Save Trip")),
                ElevatedButton(
                  onPressed: _endTrip,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("End Trip"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

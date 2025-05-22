import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../models/bucket_list_item.dart';
import 'dart:io';
import 'making_live_trip_screen.dart'; // Import the new screen

class AddDestinationScreen extends StatefulWidget {
  final BucketListItem? existingTrip;
  final int? tripIndex;

  const AddDestinationScreen({super.key, this.existingTrip, this.tripIndex});

  @override
  _AddDestinationScreenState createState() => _AddDestinationScreenState();
}

class _AddDestinationScreenState extends State<AddDestinationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _timeSpanController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _packingItemController = TextEditingController();

  String _selectedCategory = 'Upcoming';
  DateTime? _selectedDate;
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _packingList = [];
  List<File> _mediaFiles = [];
  late Box<BucketListItem> bucketListBox;

  @override
  void initState() {
    super.initState();
    bucketListBox = Hive.box<BucketListItem>('bucket_list');
    if (widget.existingTrip != null) {
      final trip = widget.existingTrip!;
      _nameController.text = trip.name;
      _descriptionController.text = trip.description ?? '';
      _selectedCategory = trip.category;
      _selectedDate = trip.targetedDate;
      _dateController.text = _selectedDate != null
          ? DateFormat.yMMMd().format(_selectedDate!)
          : '';
      _packingList = List.from(trip.packingList);
      _budgetController.text = trip.estimatedBudget?.toString() ??
          trip.spentBudget?.toString() ??
          '';
      _timeSpanController.text = trip.dreamingTimeSpan ?? '';
      _startDate = trip.startDate;
      _endDate = trip.endDate;
      _notesController.text = trip.tripNotes ?? '';
      _mediaFiles = trip.mediaFiles.map((path) => File(path)).toList();
    }
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String selectedItem,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedItem,
        items: items.map((String category) {
          return DropdownMenuItem<String>(
              value: category, child: Text(category));
        }).toList(),
        onChanged: onChanged,
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
    );
  }

  Widget _buildDatePicker(
      String label, DateTime? date, Function(DateTime) onSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        readOnly: true,
        controller: TextEditingController(
            text: date != null ? DateFormat.yMMMd().format(date) : ''),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            onSelected(picked);
          }
        },
      ),
    );
  }

  Widget _buildBudgetField(String label) {
    return _buildTextField(_budgetController, label);
  }

  Widget _buildDreamTripsSection() {
    return Column(
      children: [
        _buildTextField(_timeSpanController, 'Time Span (e.g., 3 years)'),
        _buildBudgetField('Estimated Budget'),
      ],
    );
  }

  Widget _buildVisitedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDatePicker('Trip Start Date', _startDate,
            (date) => setState(() => _startDate = date)),
        _buildDatePicker('Trip End Date', _endDate,
            (date) => setState(() => _endDate = date)),
        _buildBudgetField('Budget Spent'),
        _buildTextField(_notesController, 'Trip Notes'),
        _buildMediaUploadSection(),
      ],
    );
  }

  Widget _buildUpcomingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDatePicker(
            'Targeted Date',
            _selectedDate,
            (date) => setState(() {
                  _selectedDate = date;
                  _dateController.text = DateFormat.yMMMd().format(date);
                })),
        _buildPackingListSection(),
        _buildMakeLiveTripButton(), // Add the "Make it Live Trip" button
      ],
    );
  }

  Widget _buildPackingListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Packing List',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
                child: _buildTextField(_packingItemController, 'Add item')),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                if (_packingItemController.text.isNotEmpty) {
                  setState(() {
                    _packingList.add(_packingItemController.text);
                    _packingItemController.clear();
                  });
                }
              },
            ),
          ],
        ),
        Wrap(
          children: _packingList.map((item) {
            return Chip(
              label: Text(item),
              onDeleted: () {
                setState(() {
                  _packingList.remove(item);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMediaUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Upload Photos/Videos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            ..._mediaFiles.map((file) {
              return GestureDetector(
                onTap: () => _viewMediaInFullScreen(context, file),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(file),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.cancel, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _mediaFiles.remove(file);
                        });
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
            GestureDetector(
              onTap: _pickMedia,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, size: 40, color: Colors.grey),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? files = await picker.pickMultipleMedia();
    if (files != null) {
      setState(() {
        _mediaFiles.addAll(files.map((file) => File(file.path)));
      });
    }
  }

  void _viewMediaInFullScreen(BuildContext context, File file) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Image.file(file, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildMakeLiveTripButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (_nameController.text.isNotEmpty) {
            final trip = BucketListItem(
              name: _nameController.text,
              description: _descriptionController.text,
              category: 'Ongoing',
              startDate: _selectedDate,
              targetedDate: _selectedDate,
              packingList: _packingList,
              estimatedBudget: double.tryParse(_budgetController.text),
              dreamingTimeSpan: _timeSpanController.text,
              startLocation:
                  '', // You can add a field for start location if needed
              mediaFiles: _mediaFiles.map((file) => file.path).toList(),
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MakingLiveTripScreen(trip: trip),
              ),
            ).then((_) {
              // Remove the trip from the upcoming list if it's made live
              if (widget.tripIndex != null) {
                bucketListBox.deleteAt(widget.tripIndex!);
              }
              Navigator.pop(context); // Go back to the previous screen
            });
          }
        },
        child: const Text("Make it Live Trip"),
      ),
    );
  }

  void _saveDestination() {
    final newDestination = BucketListItem(
      name: _nameController.text,
      description: _descriptionController.text,
      category: _selectedCategory,
      targetedDate: _selectedCategory == 'Upcoming' ? _selectedDate : null,
      packingList: _selectedCategory == 'Upcoming' ? _packingList : [],
      estimatedBudget: _selectedCategory == 'Dream Trips'
          ? double.tryParse(_budgetController.text)
          : null,
      dreamingTimeSpan:
          _selectedCategory == 'Dream Trips' ? _timeSpanController.text : null,
      startDate: _selectedCategory == 'Visited' ? _startDate : null,
      endDate: _selectedCategory == 'Visited' ? _endDate : null,
      spentBudget: _selectedCategory == 'Visited'
          ? double.tryParse(_budgetController.text)
          : null,
      tripNotes: _selectedCategory == 'Visited' ? _notesController.text : null,
      mediaFiles: _mediaFiles.map((file) => file.path).toList(),
      startLocation: '',
    );

    if (widget.tripIndex != null) {
      bucketListBox.putAt(widget.tripIndex!, newDestination);
    } else {
      bucketListBox.add(newDestination);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.existingTrip == null
              ? 'Add Destination'
              : 'Edit Destination')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(_nameController, 'Destination Name'),
            _buildTextField(_descriptionController, 'Description'),
            _buildDropdown(
                ['Upcoming', 'Dream Trips', 'Visited'],
                _selectedCategory,
                (value) => setState(() => _selectedCategory = value!)),
            if (_selectedCategory == 'Upcoming') _buildUpcomingSection(),
            if (_selectedCategory == 'Dream Trips') _buildDreamTripsSection(),
            if (_selectedCategory == 'Visited') _buildVisitedSection(),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveDestination,
                child: Text(widget.existingTrip == null
                    ? 'Save Destination'
                    : 'Update Destination'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

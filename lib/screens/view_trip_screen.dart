import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/bucket_list_item.dart';

class ViewTripScreen extends StatelessWidget {
  final BucketListItem trip;

  const ViewTripScreen({Key? key, required this.trip}) : super(key: key);

  void _viewMediaInFullScreen(BuildContext context, String mediaPath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: mediaPath.endsWith('.mp4') || mediaPath.endsWith('.mov')
                ? const Center(
                    child: Text(
                    "Video playback not implemented",
                    style: TextStyle(color: Colors.white),
                  ))
                : kIsWeb
                    ? Image.network(mediaPath, fit: BoxFit.cover)
                    : Image.file(File(mediaPath), fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade700.withOpacity(0.85),
                Colors.purple.shade600.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.2))),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeIn,
              child: Text(
                trip.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                  color: Colors.white,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 6,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  // Add share functionality here if needed
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.95),
              Colors.grey.shade200.withOpacity(0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCard(
                    "Description",
                    Icons.description,
                    _buildContent(
                        trip.description ?? 'No description available'),
                    iconColor: Colors.blue,
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    "Location",
                    Icons.location_on,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildContent("Start: ${trip.startLocation}"),
                        const SizedBox(height: 8),
                        _buildContent("End: ${trip.endLocation ?? 'N/A'}"),
                      ],
                    ),
                    iconColor: Colors.green,
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    "Dates",
                    Icons.calendar_today,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildContent(
                            "Start: ${trip.startDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}"),
                        const SizedBox(height: 8),
                        _buildContent(
                            "End: ${trip.endDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}"),
                      ],
                    ),
                    iconColor: Colors.orange,
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    "Budget",
                    Icons.attach_money,
                    _buildContent(
                        "Target: \$${trip.estimatedBudget?.toStringAsFixed(2) ?? 'N/A'}"),
                    iconColor: Colors.purple,
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    "Expenses",
                    Icons.receipt,
                    trip.expenses.isEmpty
                        ? _buildContent("No expenses recorded.")
                        : Column(
                            children: trip.expenses.map((expense) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.arrow_right,
                                        size: 16, color: Colors.black54),
                                    const SizedBox(width: 8),
                                    Text(
                                      "${expense.name}: \$${expense.amount.toStringAsFixed(2)}",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                    iconColor: Colors.red,
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    "Trip Diary",
                    Icons.book,
                    _buildContent(trip.tripDiary ?? 'No diary entries.'),
                    iconColor: Colors.teal,
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    "Media Files",
                    Icons.photo_library,
                    trip.mediaFiles.isEmpty
                        ? _buildContent("No media files uploaded.")
                        : Wrap(
                            spacing: 12.0,
                            runSpacing: 12.0,
                            children: trip.mediaFiles.map((file) {
                              return GestureDetector(
                                onTap: () =>
                                    _viewMediaInFullScreen(context, file),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 110,
                                    height: 110,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.grey.shade200,
                                          Colors.grey.shade300,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(2, 2),
                                        ),
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.7),
                                          blurRadius: 8,
                                          offset: const Offset(-2, -2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: file.endsWith('.mp4') ||
                                              file.endsWith('.mov')
                                          ? const Center(
                                              child: Icon(Icons.videocam,
                                                  size: 40,
                                                  color: Colors.black54))
                                          : kIsWeb
                                              ? Image.network(file,
                                                  fit: BoxFit.cover)
                                              : Image.file(File(file),
                                                  fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                    iconColor: Colors.indigo,
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    "Goals",
                    Icons.flag,
                    trip.goals.isEmpty
                        ? _buildContent("No goals set.")
                        : Column(
                            children: trip.goals.map((goal) {
                              return ListTile(
                                leading: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Icon(
                                    goal.isCompleted
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    key: ValueKey(goal.isCompleted),
                                    color: goal.isCompleted
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                                title: Text(
                                  goal.description,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              );
                            }).toList(),
                          ),
                    iconColor: Colors.amber,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, Widget content,
      {Color? iconColor}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(-2, -2),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: iconColor ?? Colors.blue),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(
              color: Colors.grey.withOpacity(0.3),
              thickness: 1,
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildContent(String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
          height: 1.5,
          fontFamily: 'Roboto',
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

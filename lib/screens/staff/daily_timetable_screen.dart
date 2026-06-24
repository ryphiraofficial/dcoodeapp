import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/staff_provider.dart';
import '../../constants.dart';
import 'package:intl/intl.dart';

import 'add_student_screen.dart'; // Just in case, but we need batch detail
import 'batch_students_screen.dart';

class DailyTimetableScreen extends StatefulWidget {
  final DateTime selectedDate;
  const DailyTimetableScreen({super.key, required this.selectedDate});

  @override
  State<DailyTimetableScreen> createState() => _DailyTimetableScreenState();
}

class _DailyTimetableScreenState extends State<DailyTimetableScreen> {
  String? _selectedBatch;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
      context.read<StaffProvider>().fetchBatches();
    });
  }

  Future<void> _fetchData() async {
    final dateStr = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
    await context.read<StaffProvider>().fetchTimetable(
      date: dateStr,
      batchId: _selectedBatch,
    );
  }

  @override
  Widget build(BuildContext context) {
    final staffProvider = context.watch<StaffProvider>();
    final manualEntries = staffProvider.timetableList;
    final batches = staffProvider.batchList?.items ?? [];
    final df = DateFormat('EEEE, MMM dd');

    // 1. Calculate Recurring Batch Classes for this date
    final weekdayShort = DateFormat('EEE').format(widget.selectedDate); // e.g. "Tue"
    final weekdayInt = widget.selectedDate.weekday; // 1 = Mon, 7 = Sun
    
    final List<dynamic> calculatedClasses = [];
    
    for (var batch in batches) {
      // Check if date is within batch range
      bool isWithinRange = widget.selectedDate.isAfter(batch.startDate.subtract(const Duration(days: 1))) &&
          (batch.endDate == null || widget.selectedDate.isBefore(batch.endDate!.add(const Duration(days: 1))));
      
      if (!isWithinRange) continue;

      // Check if weekday matches batch schedule
      bool dayMatches = false;
      if (batch.workingDays == 'Monday-Friday' && weekdayInt <= 5) {
        dayMatches = true;
      } else if (batch.workingDays == 'Weekend' && weekdayInt >= 6) {
        dayMatches = true;
      } else if (batch.workingDays == 'Custom' && batch.customWorkingDays.contains(weekdayShort)) {
        dayMatches = true;
      }

      if (dayMatches) {
        // Create a virtual class entry from batch info
        calculatedClasses.add({
          'subject': batch.name, // Using batch name as subject if specific subject not found
          'faculty': batch.facultyInCharge,
          'startTime': batch.startTime ?? 'N/A',
          'endTime': batch.endTime ?? 'N/A',
          'classroom': 'Assigned Room',
          'batchId': batch.id,
          'isRecurring': true,
        });
      }
    }

    // 2. Merge with manual entries from API (manual overrides take priority)
    final Map<String, dynamic> finalSchedule = {};
    
    // Add recurring classes first
    for (var c in calculatedClasses) {
      finalSchedule[c['batchId']] = c;
    }
    
    // Override with manual entries if they exist for the same batch
    for (var m in manualEntries) {
      finalSchedule[m.batch] = {
        'subject': m.subject,
        'faculty': m.faculty,
        'startTime': m.startTime,
        'endTime': m.endTime,
        'classroom': m.classroom,
        'batchId': m.batch,
        'isRecurring': false,
      };
    }

    final displayList = finalSchedule.values.toList();
    // Sort by start time
    displayList.sort((a, b) => a['startTime'].compareTo(b['startTime']));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(df.format(widget.selectedDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedBatch,
              decoration: InputDecoration(
                hintText: 'Filter by Batch',
                prefixIcon: const Icon(Icons.groups_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Batches')),
                ...batches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name, overflow: TextOverflow.ellipsis))),
              ],
              onChanged: (value) {
                setState(() => _selectedBatch = value);
                _fetchData();
              },
            ),
          ),
          Expanded(
            child: staffProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayList.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchData,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: displayList.length,
                          itemBuilder: (context, index) {
                            final entry = displayList[index];
                            if (_selectedBatch != null && entry['batchId'] != _selectedBatch) return const SizedBox.shrink();
                            
                            return InkWell(
                              onTap: () {
                                final batch = batches.firstWhere((b) => b.id == entry['batchId']);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BatchStudentsScreen(
                                      batch: batch,
                                      initialDate: widget.selectedDate,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: _buildTimetableCard(entry),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No classes for this day',
            style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableCard(dynamic entry) {
    final bool isRecurring = entry['isRecurring'] ?? false;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isRecurring ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Column(
              children: [
                Text(entry['startTime'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Icon(Icons.arrow_downward, size: 14, color: Colors.grey),
                Text(entry['endTime'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
            const SizedBox(width: 20),
            Container(width: 1, height: 50, color: AppColors.border),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(entry['subject'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      if (isRecurring)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('RECURRING', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(entry['faculty'], style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(entry['classroom'], style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

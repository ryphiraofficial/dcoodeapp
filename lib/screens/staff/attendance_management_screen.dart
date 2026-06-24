import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/staff_provider.dart';
import '../../constants.dart';
import 'mark_attendance_screen.dart';
import 'package:intl/intl.dart';

class AttendanceManagementScreen extends StatefulWidget {
  const AttendanceManagementScreen({super.key});

  @override
  State<AttendanceManagementScreen> createState() => _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState extends State<AttendanceManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().fetchBatches();
    });
  }

  Future<void> _showLeaveDialog(BuildContext context, {String? batchId, String? batchName}) async {
    DateTime selectedDate = DateTime.now();
    final TextEditingController reasonController = TextEditingController();
    final staffProvider = context.read<StaffProvider>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(batchId == null ? 'Mark Global Holiday' : 'Mark Batch Holiday'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(batchId == null 
                ? 'Declare a holiday for all batches on this date.' 
                : 'Declare a holiday for $batchName.'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason (e.g. Public Holiday)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setDialogState(() => selectedDate = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            TextButton(
              onPressed: staffProvider.isLoading ? null : () async {
                final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
                final reason = reasonController.text.isEmpty ? 'Holiday' : reasonController.text;
                
                final success = await staffProvider.createHoliday(
                  date: dateStr, 
                  reason: reason,
                  batchId: batchId
                );
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Holiday marked successfully' : 'Failed to mark holiday'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: staffProvider.isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('CONFIRM'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final staffProvider = context.watch<StaffProvider>();
    final batches = staffProvider.batchList?.items ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Batch',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => _showLeaveDialog(context),
                  icon: const Icon(Icons.beach_access_outlined, size: 18),
                  label: const Text('MARK GLOBAL HOLIDAY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange,
                    backgroundColor: Colors.orange.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextButton.icon(
              onPressed: () => _showHolidaysList(context),
              icon: const Icon(Icons.list_alt, size: 18),
              label: const Text('VIEW ALL HOLIDAYS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(foregroundColor: Colors.blueGrey),
            ),
          ),
          Expanded(
            child: staffProvider.isLoading && batches.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : batches.isEmpty
                    ? const Center(child: Text('No batches available'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: batches.length,
                        itemBuilder: (context, index) {
                          final batch = batches[index];
                          final df = DateFormat('MMM dd');
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: AppColors.border),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MarkAttendanceScreen(batch: batch),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.groups, color: AppColors.primary),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(child: Text(batch.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                                                GestureDetector(
                                                  onTap: () => _showLeaveDialog(context, batchId: batch.id, batchName: batch.name),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.orange.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: const Text('HOLIDAY', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${batch.courseName ?? "N/A"} | Duration: ${batch.duration ?? "N/A"}',
                                              style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
                                            ),
                                            Text('Faculty: ${batch.facultyInCharge}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                            Text(
                                              '${batch.startTime ?? "N/A"} - ${batch.endTime ?? "N/A"} | ${batch.workingDays == "Custom" ? batch.customWorkingDays.join(", ") : batch.workingDays}',
                                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${df.format(batch.startDate)}${batch.endDate != null ? " - " + df.format(batch.endDate!) : ""}',
                                              style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showHolidaysList(BuildContext context) {
    final staffProvider = context.read<StaffProvider>();
    staffProvider.fetchHolidays();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Consumer<StaffProvider>(
          builder: (context, provider, child) {
            final holidays = provider.holidays;
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Marked Holidays', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (provider.isLoading)
                    const CircularProgressIndicator()
                  else if (holidays.isEmpty)
                    const Text('No holidays marked yet.')
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: holidays.length,
                        itemBuilder: (context, index) {
                          final h = holidays[index];
                          return ListTile(
                            title: Text(h.reason),
                            subtitle: Text('${DateFormat('MMM dd, yyyy').format(h.date)} ${h.batchId == null ? "(Global)" : "(Batch)"}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => provider.deleteHoliday(h.id),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

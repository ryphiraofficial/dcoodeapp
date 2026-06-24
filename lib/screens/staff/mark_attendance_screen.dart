import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/staff_provider.dart';
import '../../constants.dart';
import '../../data/models/batch_models.dart';
import 'package:intl/intl.dart';

class MarkAttendanceScreen extends StatefulWidget {
  final Batch batch;
  final DateTime? initialDate;
  const MarkAttendanceScreen({super.key, required this.batch, this.initialDate});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  late DateTime _selectedDate;
  Map<String, String> _attendanceMap = {}; // studentId -> status
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<String> _attachedFiles = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _loadData();
  }

  @override
  void dispose() {
    _taskController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = context.read<StaffProvider>();
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    
    // 1. Fetch students for this batch
    await provider.fetchStudents(batchId: widget.batch.id);
    
    // 2. Fetch existing attendance if any
    await provider.fetchAttendance(batchId: widget.batch.id, date: dateStr);

    // 3. Fetch holidays to check if this date is blocked
    await provider.fetchHolidays(batchId: widget.batch.id);

    // 4. Initialize attendance map
    if (mounted) {
      final students = provider.studentList?.items ?? [];
      final existingRecords = provider.attendanceRecords;
      
      final Map<String, String> initialMap = {};
      for (var student in students) {
        // Find existing record for this student
        final existing = existingRecords.where((r) => r.studentId == student.id).firstOrNull;
        initialMap[student.id] = existing?.status ?? 'Absent'; // Default to Absent
      }
      
      setState(() {
        _attendanceMap = initialMap;
        // Pre-fill task and description if they exist in records
        if (existingRecords.isNotEmpty) {
          _taskController.text = existingRecords.first.task ?? '';
          _descriptionController.text = existingRecords.first.description ?? '';
          _attachedFiles = List.from(existingRecords.first.files);
        } else {
          _taskController.clear();
          _descriptionController.clear();
          _attachedFiles = [];
        }
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: widget.batch.startDate,
      lastDate: widget.batch.endDate ?? DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary, onPrimary: Colors.black),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadData();
    }
  }

  Future<void> _saveAttendance() async {
    if (_attendanceMap.isEmpty) return;

    setState(() => _isSaving = true);
    
    final List<Map<String, String>> records = _attendanceMap.entries.map((e) => {
      'student': e.key,
      'status': e.value,
    }).toList();

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final success = await context.read<StaffProvider>().markBulkAttendance(
      batchId: widget.batch.id,
      date: dateStr,
      records: records,
      task: _taskController.text,
      description: _descriptionController.text,
      files: _attachedFiles,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance saved successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save attendance'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffProvider = context.watch<StaffProvider>();
    final students = staffProvider.studentList?.items ?? [];
    final df = DateFormat('EEEE, MMM dd, yyyy');

    // Check if selected date is a holiday
    final holiday = staffProvider.holidays.where((h) {
      return h.date.year == _selectedDate.year &&
             h.date.month == _selectedDate.month &&
             h.date.day == _selectedDate.day;
    }).firstOrNull;

    final bool isHoliday = holiday != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.batch.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text('Mark Attendance', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildDateHeader(df),
          if (isHoliday)
            _buildHolidayBanner(holiday),
          _buildCollapsibleDetailsSection(),
          Expanded(
            child: staffProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : students.isEmpty
                    ? const Center(child: Text('No students found in this batch'))
                    : Opacity(
                        opacity: isHoliday ? 0.5 : 1.0,
                        child: IgnorePointer(
                          ignoring: isHoliday,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final student = students[index];
                              return _buildStudentAttendanceCard(student);
                            },
                          ),
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(isHoliday),
    );
  }

  Widget _buildDateHeader(DateFormat df) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(df.format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.bold)),
              if (_attendanceMap.isNotEmpty)
                Text('${_attendanceMap.values.where((v) => v == 'Present').length} Present, ${_attendanceMap.values.where((v) => v == 'Absent').length} Absent', 
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          TextButton.icon(
            onPressed: _selectDate,
            icon: const Icon(Icons.calendar_month, size: 18),
            label: const Text('Change Date'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildHolidayBanner(dynamic holiday) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.block, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ATTENDANCE BLOCKED',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  'This date is marked as a holiday: ${holiday.reason}',
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleDetailsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ExpansionTile(
        title: const Text('Assignment & Notes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: const Text('Task, description and files for this session', style: TextStyle(fontSize: 11, color: Colors.grey)),
        leading: const Icon(Icons.assignment_outlined, color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _taskController,
            decoration: const InputDecoration(
              labelText: 'Task / Title',
              hintText: 'e.g. Complete MERN assignment',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Summary of what was covered today...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          _buildFileUploader(),
        ],
      ),
    );
  }

  Widget _buildFileUploader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Attachments (Links)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        ..._attachedFiles.asMap().entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.link, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(child: Text(entry.value, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
              IconButton(
                icon: const Icon(Icons.close, size: 16, color: Colors.red),
                onPressed: () => setState(() => _attachedFiles.removeAt(entry.key)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        )),
        TextButton.icon(
          onPressed: _showAddFileLinkDialog,
          icon: const Icon(Icons.add_link, size: 18),
          label: const Text('Add File Link'),
          style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: Colors.blue),
        ),
      ],
    );
  }

  void _showAddFileLinkDialog() {
    final TextEditingController linkController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add File Link'),
        content: TextField(
          controller: linkController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'https://...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              if (linkController.text.isNotEmpty) {
                setState(() => _attachedFiles.add(linkController.text));
              }
              Navigator.pop(context);
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentAttendanceCard(dynamic student) {
    final status = _attendanceMap[student.id] ?? 'Absent';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(student.fullName[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(student.registerNumber, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              _buildStatusToggle(student.id, status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusToggle(String studentId, String currentStatus) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _statusButton(studentId, 'Present', currentStatus == 'Present', Colors.green),
        const SizedBox(width: 8),
        _statusButton(studentId, 'Absent', currentStatus == 'Absent', Colors.redAccent),
        const SizedBox(width: 8),
        _statusButton(studentId, 'Late', currentStatus == 'Late', Colors.orange),
      ],
    );
  }

  Widget _statusButton(String studentId, String status, bool isSelected, Color color) {
    return InkWell(
      onTap: () => setState(() => _attendanceMap[studentId] = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : Colors.transparent),
        ),
        child: Text(
          status[0], // P, A, L
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isHoliday) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: ElevatedButton(
        onPressed: (_isSaving || isHoliday) ? null : _saveAttendance,
        style: ElevatedButton.styleFrom(
          backgroundColor: isHoliday ? Colors.grey : AppColors.primary,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.black)
            : Text(isHoliday ? 'HOLIDAY - ATTENDANCE BLOCKED' : 'SUBMIT ATTENDANCE', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

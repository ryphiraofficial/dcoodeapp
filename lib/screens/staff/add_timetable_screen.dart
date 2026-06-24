import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/staff_provider.dart';
import '../../constants.dart';
import 'package:intl/intl.dart';

class AddTimetableScreen extends StatefulWidget {
  const AddTimetableScreen({super.key});

  @override
  State<AddTimetableScreen> createState() => _AddTimetableScreenState();
}

class _AddTimetableScreenState extends State<AddTimetableScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _subjectController = TextEditingController();
  final _facultyController = TextEditingController();
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _classroomController = TextEditingController();

  String? _selectedBatch;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().fetchBatches();
    });
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _facultyController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _classroomController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        final now = DateTime.now();
        final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
        controller.text = DateFormat('HH:mm').format(dt);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBatch == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a batch')));
      return;
    }

    setState(() => _isSubmitting = true);

    final data = {
      'batch': _selectedBatch,
      'subject': _subjectController.text.trim(),
      'faculty': _facultyController.text.trim(),
      'date': _dateController.text.trim(),
      'startTime': _startTimeController.text.trim(),
      'endTime': _endTimeController.text.trim(),
      'classroom': _classroomController.text.trim(),
    };

    final success = await context.read<StaffProvider>().createTimetableEntry(data);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Timetable entry created!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create entry'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final batches = context.watch<StaffProvider>().batchList?.items ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Timetable Entry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Class Information'),
              _buildBatchDropdown(batches),
              const SizedBox(height: 16),
              _buildTextField(_subjectController, 'Subject Name', Icons.book_outlined, required: true),
              const SizedBox(height: 16),
              _buildTextField(_facultyController, 'Faculty Name', Icons.person_outline, required: true),
              const SizedBox(height: 24),
              _buildSectionTitle('Schedule & Venue'),
              _buildDateField(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTimeField(_startTimeController, 'Start Time')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTimeField(_endTimeController, 'End Time')),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(_classroomController, 'Classroom / Lab', Icons.location_on_outlined, required: true),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('CREATE ENTRY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary, letterSpacing: 1)),
    );
  }

  Widget _buildBatchDropdown(List<dynamic> batches) {
    return DropdownButtonFormField<String>(
      value: _selectedBatch,
      decoration: InputDecoration(
        labelText: 'Select Batch',
        prefixIcon: const Icon(Icons.groups_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      items: batches.map<DropdownMenuItem<String>>((b) => DropdownMenuItem<String>(
        value: b.id,
        child: Text(b.name, overflow: TextOverflow.ellipsis),
      )).toList(),
      onChanged: (value) => setState(() => _selectedBatch = value),
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool required = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator: (value) {
        if (required && (value == null || value.isEmpty)) return 'Required';
        return null;
      },
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      onTap: _selectDate,
      decoration: InputDecoration(
        labelText: 'Select Date',
        prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }

  Widget _buildTimeField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => _selectTime(controller),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.access_time_outlined, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }
}

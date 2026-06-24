import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/staff_provider.dart';
import '../../constants.dart';
import '../../data/models/batch_models.dart';
import '../../data/models/course_models.dart';
import 'package:intl/intl.dart';

class AddBatchScreen extends StatefulWidget {
  final Batch? batch;
  const AddBatchScreen({super.key, this.batch});

  @override
  State<AddBatchScreen> createState() => _AddBatchScreenState();
}

class _AddBatchScreenState extends State<AddBatchScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _facultyController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  late final TextEditingController _startTimeController;
  late final TextEditingController _endTimeController;

  String? _selectedCollege;
  String? _selectedCourse;
  String? _selectedDuration;
  String _workingDays = 'Monday-Friday';
  bool _isSubmitting = false;
  final List<String> _customDays = [];
  final Map<String, String> _dayMap = {
    'Monday': 'Mon',
    'Tuesday': 'Tue',
    'Wednesday': 'Wed',
    'Thursday': 'Thu',
    'Friday': 'Fri',
    'Saturday': 'Sat',
    'Sunday': 'Sun'
  };

  @override
  void initState() {
    super.initState();
    final b = widget.batch;
    final df = DateFormat('yyyy-MM-dd');
    
    _nameController = TextEditingController(text: b?.name);
    _facultyController = TextEditingController(text: b?.facultyInCharge);
    _startDateController = TextEditingController(text: b != null ? df.format(b.startDate) : '');
    _endDateController = TextEditingController(text: b?.endDate != null ? df.format(b!.endDate!) : '');
    _startTimeController = TextEditingController(text: b?.startTime);
    _endTimeController = TextEditingController(text: b?.endTime);
    
    _selectedCollege = b?.college;
    _selectedCourse = b?.course;
    _selectedDuration = b?.duration;

    if (b != null) {
      _workingDays = b.workingDays;
      if (b.workingDays == 'Custom') {
        _customDays.addAll(b.customWorkingDays);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().fetchColleges();
      if (_selectedCollege != null) {
        context.read<StaffProvider>().fetchCourses(collegeId: _selectedCollege);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _facultyController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary, onPrimary: Colors.black),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary, onPrimary: Colors.black),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final now = DateTime.now();
        final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
        controller.text = DateFormat('hh:mm a').format(dt);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCollege == null || _selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select college and course')));
      return;
    }

    if (_workingDays == 'Custom' && _customDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one day for custom schedule')));
      return;
    }

    setState(() => _isSubmitting = true);

    final batchData = {
      'name': _nameController.text.trim(),
      'college': _selectedCollege,
      'course': _selectedCourse,
      'facultyInCharge': _facultyController.text.trim(),
      'startDate': _startDateController.text.trim(),
      'endDate': _endDateController.text.trim(),
      'startTime': _startTimeController.text.trim(),
      'endTime': _endTimeController.text.trim(),
      'workingDays': _workingDays,
      'customWorkingDays': _workingDays == 'Custom' ? _customDays : [],
      'duration': _selectedDuration,
    };

    bool success;
    if (widget.batch != null) {
      success = await context.read<StaffProvider>().updateBatch(widget.batch!.id, batchData);
    } else {
      success = await context.read<StaffProvider>().createBatch(batchData);
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.batch != null ? 'Batch updated successfully!' : 'Batch created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Operation failed. Please try again.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffProvider = context.watch<StaffProvider>();
    final isEdit = widget.batch != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Batch' : 'Add New Batch', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
              _buildSectionTitle('General Information'),
              _buildTextField(_nameController, 'Batch Name (e.g. BCA 2024-2027)', Icons.groups_outlined, required: true),
              const SizedBox(height: 16),
              _buildTextField(_facultyController, 'Faculty In-Charge', Icons.person_outline, required: true),
              const SizedBox(height: 24),
              _buildSectionTitle('Academic Association'),
              _buildCollegeDropdown(staffProvider),
              const SizedBox(height: 16),
              _buildCourseDropdown(staffProvider),
              const SizedBox(height: 16),
              _buildDurationDropdown(staffProvider),
              const SizedBox(height: 24),
              _buildSectionTitle('Schedule & Duration'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startDateController,
                      readOnly: true,
                      onTap: () => _selectDate(_startDateController),
                      decoration: InputDecoration(
                        labelText: 'Start Date',
                        prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _endDateController,
                      readOnly: true,
                      onTap: () => _selectDate(_endDateController),
                      decoration: InputDecoration(
                        labelText: 'End Date',
                        prefixIcon: const Icon(Icons.calendar_month_outlined, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startTimeController,
                      readOnly: true,
                      onTap: () => _selectTime(_startTimeController),
                      decoration: InputDecoration(
                        labelText: 'Start Time',
                        prefixIcon: const Icon(Icons.access_time_outlined, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _endTimeController,
                      readOnly: true,
                      onTap: () => _selectTime(_endTimeController),
                      decoration: InputDecoration(
                        labelText: 'End Time',
                        prefixIcon: const Icon(Icons.access_time_filled_outlined, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildWorkingDaysSelector(),
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
                    : Text(isEdit ? 'UPDATE BATCH' : 'CREATE BATCH', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool required = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
      validator: (value) {
        if (required && (value == null || value.isEmpty)) return 'Please enter $label';
        return null;
      },
    );
  }

  Widget _buildCollegeDropdown(StaffProvider provider) {
    final colleges = provider.collegeList?.items ?? [];
    return DropdownButtonFormField<String>(
      value: _selectedCollege,
      decoration: InputDecoration(
        labelText: 'Select College',
        prefixIcon: const Icon(Icons.school_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      items: colleges.map<DropdownMenuItem<String>>((c) => DropdownMenuItem<String>(
        value: c.id,
        child: Text(c.name, overflow: TextOverflow.ellipsis),
      )).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCollege = value;
          _selectedCourse = null;
          _selectedDuration = null;
        });
        provider.fetchCourses(collegeId: value);
      },
      validator: (v) => v == null ? 'Please select a college' : null,
    );
  }

  Widget _buildCourseDropdown(StaffProvider provider) {
    final courses = provider.dropdownCourses;
    return DropdownButtonFormField<String>(
      value: _selectedCourse,
      decoration: InputDecoration(
        labelText: 'Select Course',
        prefixIcon: const Icon(Icons.book_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      items: courses.map<DropdownMenuItem<String>>((c) => DropdownMenuItem<String>(
        value: c.id,
        child: Text(c.name, overflow: TextOverflow.ellipsis),
      )).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCourse = value;
          _selectedDuration = null;
        });
      },
      validator: (v) => v == null ? 'Please select a course' : null,
    );
  }

  Widget _buildWorkingDaysSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _workingDays,
          decoration: InputDecoration(
            labelText: 'Working Days',
            prefixIcon: const Icon(Icons.work_history_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          items: ['Monday-Friday', 'Weekend', 'Custom'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => _workingDays = v!),
        ),
        if (_workingDays == 'Custom') ...[
          const SizedBox(height: 16),
          const Text('Select Individual Days:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _dayMap.keys.map((day) {
              final shortDay = _dayMap[day]!;
              final isSelected = _customDays.contains(shortDay);
              return FilterChip(
                label: Text(shortDay, style: TextStyle(color: isSelected ? Colors.black : Colors.grey[600], fontWeight: FontWeight.bold)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _customDays.add(shortDay);
                    } else {
                      _customDays.remove(shortDay);
                    }
                  });
                },
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
                checkmarkColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildDurationDropdown(StaffProvider provider) {
    final courses = provider.dropdownCourses;
    Course? selectedCourseObj;
    try {
      selectedCourseObj = courses.firstWhere((c) => c.id == _selectedCourse);
    } catch (_) {
      selectedCourseObj = null;
    }

    final durations = selectedCourseObj?.durations ?? [];

    return DropdownButtonFormField<String>(
      value: _selectedDuration,
      decoration: InputDecoration(
        labelText: 'Select Duration',
        prefixIcon: const Icon(Icons.timer_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      items: durations.map<DropdownMenuItem<String>>((d) => DropdownMenuItem<String>(
        value: d,
        child: Text(d),
      )).toList(),
      onChanged: (value) => setState(() => _selectedDuration = value),
      validator: (v) => v == null ? 'Please select a duration' : null,
    );
  }
}

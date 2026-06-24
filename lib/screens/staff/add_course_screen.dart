import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/staff_provider.dart';
import '../../constants.dart';
import '../../data/models/course_models.dart';

class AddCourseScreen extends StatefulWidget {
  final Course? course;
  const AddCourseScreen({super.key, this.course});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _durationController;
  late final TextEditingController _descriptionController;

  String? _selectedCollege;
  bool _isSubmitting = false;
  final List<String> _durations = [];

  @override
  void initState() {
    super.initState();
    final c = widget.course;
    _nameController = TextEditingController(text: c?.name);
    _codeController = TextEditingController(text: c?.code);
    _durationController = TextEditingController();
    _descriptionController = TextEditingController(text: c?.description);
    _selectedCollege = c?.college;

    if (c != null && c.durations.isNotEmpty) {
      _durations.addAll(c.durations);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().fetchColleges();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCollege == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a college')));
      return;
    }
    if (_durations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one duration')));
      return;
    }

    setState(() => _isSubmitting = true);

    final courseData = {
      'name': _nameController.text.trim(),
      'code': _codeController.text.trim(),
      'durations': _durations,
      'description': _descriptionController.text.trim(),
      'college': _selectedCollege,
    };

    bool success;
    if (widget.course != null) {
      success = await context.read<StaffProvider>().updateCourse(widget.course!.id, courseData);
    } else {
      success = await context.read<StaffProvider>().createCourse(courseData);
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.course != null ? 'Course updated successfully!' : 'Course created successfully!'),
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
    final isEdit = widget.course != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Course' : 'Add New Course', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
              _buildSectionTitle('Basic Information'),
              _buildTextField(_nameController, 'Course Name', Icons.book_outlined, required: true),
              const SizedBox(height: 16),
              _buildTextField(_codeController, 'Course Code', Icons.qr_code_outlined, required: true),
              const SizedBox(height: 24),
              _buildSectionTitle('Academic Details'),
              _buildCollegeDropdown(staffProvider),
              const SizedBox(height: 16),
              _buildDurationInput(),
              const SizedBox(height: 24),
              _buildSectionTitle('Description'),
              _buildTextField(_descriptionController, 'Description', Icons.description_outlined, maxLines: 4),
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
                    : Text(isEdit ? 'UPDATE COURSE' : 'CREATE COURSE', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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
      onChanged: (value) => setState(() => _selectedCollege = value),
      validator: (v) => v == null ? 'Please select a college' : null,
    );
  }

  Widget _buildDurationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _durationController,
                decoration: InputDecoration(
                  labelText: 'Add Duration (e.g. 1 Month)',
                  prefixIcon: const Icon(Icons.timer_outlined, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_circle, color: AppColors.primary),
                    onPressed: _addDuration,
                  ),
                ),
                onFieldSubmitted: (_) => _addDuration(),
              ),
            ),
          ],
        ),
        if (_durations.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _durations.map((d) => Chip(
              label: Text(d, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              side: const BorderSide(color: AppColors.primary),
              onDeleted: () => setState(() => _durations.remove(d)),
              deleteIcon: const Icon(Icons.close, size: 14),
            )).toList(),
          ),
        ],
      ],
    );
  }

  void _addDuration() {
    final text = _durationController.text.trim();
    if (text.isNotEmpty && !_durations.contains(text)) {
      setState(() {
        _durations.add(text);
        _durationController.clear();
      });
    }
  }
}

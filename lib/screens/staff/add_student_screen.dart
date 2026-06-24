import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/staff_provider.dart';
import '../../constants.dart';
import '../../data/models/student_models.dart';
import '../../data/models/college_models.dart';
import '../../data/models/course_models.dart';
import '../../data/models/batch_models.dart';

class AddStudentScreen extends StatefulWidget {
  final Student? student;
  const AddStudentScreen({super.key, this.student});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _regController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _dobController;
  late final TextEditingController _addressController;

  String? _selectedCollege;
  String? _selectedCourse;
  String? _selectedBatch;
  String _gender = 'Male';
  
  File? _photoFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _nameController = TextEditingController(text: s?.fullName);
    _regController = TextEditingController(text: s?.registerNumber);
    _emailController = TextEditingController(text: s?.email);
    _phoneController = TextEditingController(text: s?.phone);
    _dobController = TextEditingController(text: s?.dateOfBirth);
    _addressController = TextEditingController(text: s?.address);
    
    _gender = s?.gender ?? 'Male';
    _selectedCollege = s?.college?.id;
    _selectedCourse = s?.course?.id;
    _selectedBatch = s?.batch?.id;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().fetchColleges();
      if (_selectedCollege != null) {
        context.read<StaffProvider>().fetchCourses(collegeId: _selectedCollege);
      }
      if (_selectedCourse != null) {
        context.read<StaffProvider>().fetchBatches(courseId: _selectedCourse);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photoFile = File(image.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCollege == null || _selectedCourse == null || _selectedBatch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select College, Course and Batch')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final formData = {
      'fullName': _nameController.text.trim(),
      'registerNumber': _regController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'dateOfBirth': _dobController.text.trim(),
      'gender': _gender,
      'address': _addressController.text.trim(),
      'college': _selectedCollege,
      'course': _selectedCourse,
      'batch': _selectedBatch,
    };

    bool success;
    String? tempPassword;

    if (widget.student != null) {
      success = await context.read<StaffProvider>().updateStudent(
        widget.student!.id,
        formData,
        _photoFile?.path,
      );
    } else {
      final result = await context.read<StaffProvider>().createStudent(
        formData,
        _photoFile?.path,
      );
      success = result != null;
      tempPassword = result?['temporaryPassword'];
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        if (tempPassword != null) {
          _showPasswordDialog(tempPassword);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.student != null ? 'Student updated!' : 'Student added!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Operation failed. Please check logs.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showPasswordDialog(String password) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Student Created'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('An email with login credentials has been sent to the student.'),
            const SizedBox(height: 16),
            const Text('Temporary password (one-time only):'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      password,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: password));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password copied to clipboard'), duration: Duration(seconds: 2)),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('Please share this with the student manually if they don\'t receive the email.', 
              style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(this.context, true);
            },
            child: const Text('DONE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final staffProvider = context.watch<StaffProvider>();
    final isEdit = widget.student != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Student' : 'Add New Student', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
              _buildPhotoPicker(),
              const SizedBox(height: 32),
              _buildSectionTitle('Basic Information'),
              _buildTextField(_nameController, 'Full Name', Icons.person_outline, required: true),
              const SizedBox(height: 16),
              _buildTextField(_emailController, 'Email Address', Icons.email_outlined, required: true, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField(_regController, 'Register Number', Icons.badge_outlined),
              const SizedBox(height: 24),
              _buildSectionTitle('Academic Details'),
              _buildCollegeDropdown(staffProvider),
              const SizedBox(height: 16),
              _buildCourseDropdown(staffProvider),
              const SizedBox(height: 16),
              _buildBatchDropdown(staffProvider),
              const SizedBox(height: 24),
              _buildSectionTitle('Personal Details'),
              _buildTextField(_phoneController, 'Phone Number', Icons.phone_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextField(_dobController, 'Date of Birth (YYYY-MM-DD)', Icons.calendar_today_outlined, hint: 'e.g. 2002-05-15'),
              const SizedBox(height: 16),
              _buildGenderSelector(),
              const SizedBox(height: 16),
              _buildTextField(_addressController, 'Address', Icons.location_on_outlined, maxLines: 2),
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
                    : Text(isEdit ? 'UPDATE STUDENT' : 'CREATE STUDENT', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
    );
  }

  Widget _buildPhotoPicker() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              backgroundImage: _photoFile != null ? FileImage(_photoFile!) : 
                (widget.student?.photo != null ? NetworkImage(widget.student!.photo!) as ImageProvider : null),
              child: _photoFile == null && widget.student?.photo == null
                  ? const Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 32)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.edit, color: Colors.black, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollegeDropdown(StaffProvider provider) {
    final colleges = provider.collegeList?.items ?? [];
    return DropdownButtonFormField<String>(
      value: _selectedCollege,
      decoration: InputDecoration(
        labelText: 'College',
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
          _selectedBatch = null;
        });
        provider.fetchCourses(collegeId: value);
      },
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _buildCourseDropdown(StaffProvider provider) {
    final courses = provider.dropdownCourses;
    return DropdownButtonFormField<String>(
      value: _selectedCourse,
      decoration: InputDecoration(
        labelText: 'Course',
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
          _selectedBatch = null;
        });
        provider.fetchBatches(courseId: value);
      },
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _buildBatchDropdown(StaffProvider provider) {
    final batches = provider.batchList?.items ?? [];
    return DropdownButtonFormField<String>(
      value: _selectedBatch,
      decoration: InputDecoration(
        labelText: 'Batch',
        prefixIcon: const Icon(Icons.group_outlined),
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

  Widget _buildGenderSelector() {
    return Row(
      children: [
        const Text('Gender: ', style: TextStyle(fontWeight: FontWeight.bold)),
        Radio<String>(value: 'Male', groupValue: _gender, activeColor: AppColors.primary, onChanged: (v) => setState(() => _gender = v!)),
        const Text('Male'),
        Radio<String>(value: 'Female', groupValue: _gender, activeColor: AppColors.primary, onChanged: (v) => setState(() => _gender = v!)),
        const Text('Female'),
        Radio<String>(value: 'Other', groupValue: _gender, activeColor: AppColors.primary, onChanged: (v) => setState(() => _gender = v!)),
        const Text('Other'),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator: (value) {
        if (required && (value == null || value.isEmpty)) return 'Please enter $label';
        if (keyboardType == TextInputType.emailAddress && value != null && value.isNotEmpty) {
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(value)) return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }
}

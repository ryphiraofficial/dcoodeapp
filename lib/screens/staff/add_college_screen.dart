import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/staff_provider.dart';
import '../../constants.dart';

class AddCollegeScreen extends StatefulWidget {
  const AddCollegeScreen({super.key});

  @override
  State<AddCollegeScreen> createState() => _AddCollegeScreenState();
}

class _AddCollegeScreenState extends State<AddCollegeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _principalController = TextEditingController();
  
  String _status = 'active';
  File? _logoFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _principalController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _logoFile = File(image.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final formData = {
      'name': _nameController.text.trim(),
      'code': _codeController.text.trim(),
      'address': _addressController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'principalName': _principalController.text.trim(),
      'status': _status,
    };

    final success = await context.read<StaffProvider>().createCollege(
      formData,
      _logoFile?.path,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('College added successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add college. Please try again.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add New College', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
              _buildImagePicker(),
              const SizedBox(height: 32),
              _buildTextField(_nameController, 'College Name', Icons.school_outlined, required: true),
              const SizedBox(height: 20),
              _buildTextField(_codeController, 'College Code', Icons.qr_code_outlined, required: true),
              const SizedBox(height: 20),
              _buildTextField(_principalController, 'Principal Name', Icons.person_outline),
              const SizedBox(height: 20),
              _buildTextField(_emailController, 'Email Address', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              _buildTextField(_phoneController, 'Phone Number', Icons.phone_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 20),
              _buildTextField(_addressController, 'Address', Icons.location_on_outlined, maxLines: 3),
              const SizedBox(height: 24),
              const Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Row(
                children: [
                  Radio<String>(
                    value: 'active',
                    groupValue: _status,
                    activeColor: AppColors.primary,
                    onChanged: (value) => setState(() => _status = value!),
                  ),
                  const Text('Active'),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'inactive',
                    groupValue: _status,
                    activeColor: AppColors.primary,
                    onChanged: (value) => setState(() => _status = value!),
                  ),
                  const Text('Inactive'),
                ],
              ),
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
                    : const Text('CREATE COLLEGE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                image: _logoFile != null
                    ? DecorationImage(image: FileImage(_logoFile!), fit: BoxFit.cover)
                    : null,
              ),
              child: _logoFile == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 32),
                        SizedBox(height: 8),
                        Text('Add Logo', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    )
                  : null,
            ),
            if (_logoFile != null)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => setState(() => _logoFile = null),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
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
        if (required && (value == null || value.isEmpty)) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}

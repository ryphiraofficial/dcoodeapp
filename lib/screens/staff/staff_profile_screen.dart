import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/staff_provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants.dart';
import '../../data/models/auth_models.dart';

class StaffProfileScreen extends StatefulWidget {
  const StaffProfileScreen({super.key});

  @override
  State<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final staffProvider = context.read<StaffProvider>();
    final authProvider = context.read<AuthProvider>();
    
    // Set initial values from AuthProvider immediately
    if (authProvider.user != null && authProvider.user!.name != 'Unknown') {
      _nameController.text = authProvider.user!.name;
      _emailController.text = authProvider.user!.email;
      _phoneController.text = authProvider.user!.phone;
    }

    // Try fetching fresh data from StaffProvider
    await staffProvider.fetchMyProfile();
    if (mounted && staffProvider.profile != null && staffProvider.profile!.name != 'Unknown') {
      setState(() {
        _nameController.text = staffProvider.profile!.name;
        _emailController.text = staffProvider.profile!.email;
        _phoneController.text = staffProvider.profile!.phone;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      final success = await context.read<StaffProvider>().updateMyProfile({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      if (mounted) {
        if (success) {
          setState(() => _isEditing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffProvider = context.watch<StaffProvider>();
    final authProvider = context.watch<AuthProvider>();
    
    // Use data from staffProvider if available, otherwise fallback to authProvider
    final profile = staffProvider.profile ?? authProvider.user;

    if (staffProvider.isLoading && profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildProfileHeader(profile),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_nameController, 'Full Name', Icons.person_outline),
                  const SizedBox(height: 16),
                  _buildTextField(_emailController, 'Email Address', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _buildTextField(_phoneController, 'Phone Number', Icons.phone_outlined, keyboardType: TextInputType.phone),
                  const SizedBox(height: 32),
                  if (!_isEditing)
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _isEditing = true),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('EDIT PROFILE', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() => _isEditing = false);
                              _loadProfile(); // Reset fields
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('CANCEL'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: staffProvider.isLoading ? null : _handleUpdate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.black,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: staffProvider.isLoading
                                ? const CircularProgressIndicator(color: Colors.black)
                                : const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
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

  Widget _buildProfileHeader(User? profile) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.black,
          child: Text(
            profile?.name[0].toUpperCase() ?? 'A',
            style: const TextStyle(fontSize: 32, color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          profile?.name ?? 'Administrator',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          profile?.role.toUpperCase() ?? 'STAFF',
          style: const TextStyle(color: Colors.grey, fontSize: 14, letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: !_isEditing,
        fillColor: _isEditing ? Colors.transparent : Colors.grey[100],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter $label';
        return null;
      },
    );
  }
}

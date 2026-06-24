import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import 'package:dcoode/features/certificate/certificate_provider.dart';
import 'package:dcoode/features/certificate/certificate_preview_screen.dart';
import '../../constants.dart';
import 'package:intl/intl.dart';

class StudentCertificationsScreen extends StatefulWidget {
  const StudentCertificationsScreen({super.key});

  @override
  State<StudentCertificationsScreen> createState() => _StudentCertificationsScreenState();
}

class _StudentCertificationsScreenState extends State<StudentCertificationsScreen> {
  final _nameController = TextEditingController();
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );

    if (result != null && _nameController.text.isNotEmpty) {
      setState(() => _isUploading = true);
      final success = await context.read<StudentProvider>().uploadCertification(
        _nameController.text.trim(),
        result.files.single.path!,
      );
      
      if (mounted) {
        setState(() => _isUploading = false);
        if (success) {
          _nameController.clear();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Certification uploaded!')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload failed')));
        }
      }
    } else if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter certification name')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<StudentProvider>().profile;
    final certs = profile?.certifications ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildOfficialCertificateSection(),
          _buildUploadSection(),
          Expanded(
            child: certs.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: certs.length,
                    itemBuilder: (context, index) {
                      final cert = certs[index];
                      return _buildCertCard(cert);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficialCertificateSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('OFFICIAL COURSE CERTIFICATE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1)),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CertificatePreviewScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.workspace_premium, color: Colors.amber, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('View Official Certificate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Issued by DCOODE upon completion', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.amber),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('UPLOAD EXTERNAL CERTIFICATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Certification Name (e.g. AWS Certified)',
              prefixIcon: const Icon(Icons.description_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              filled: true,
              fillColor: AppColors.background,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isUploading ? null : _handleUpload,
            icon: const Icon(Icons.upload_file),
            label: Text(_isUploading ? 'UPLOADING...' : 'PICK FILE & UPLOAD'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          Icon(Icons.verified_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No certifications uploaded yet', style: TextStyle(color: Colors.black54, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildCertCard(dynamic cert) {
    final df = DateFormat('MMM dd, yyyy');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.verified_user_outlined, color: AppColors.primary),
        ),
        title: Text(cert.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Uploaded: ${df.format(cert.uploadedAt)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => _confirmDelete(cert.id),
        ),
        onTap: () {
          // TODO: Open certification URL
        },
      ),
    );
  }

  void _confirmDelete(String certId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Certification?'),
        content: const Text('Are you sure you want to remove this document?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              final success = await context.read<StudentProvider>().deleteCertification(certId);
              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed successfully')));
                }
              }
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

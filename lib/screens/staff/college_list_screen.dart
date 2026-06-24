import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/staff_provider.dart';
import '../../constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'add_college_screen.dart';

class StaffCollegeListScreen extends StatefulWidget {
  const StaffCollegeListScreen({super.key});

  @override
  State<StaffCollegeListScreen> createState() => _StaffCollegeListScreenState();
}

class _StaffCollegeListScreenState extends State<StaffCollegeListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().fetchColleges();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staffProvider = context.watch<StaffProvider>();
    final collegeList = staffProvider.collegeList;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search colleges...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (value) => staffProvider.fetchColleges(search: value),
            ),
          ),
          Expanded(
            child: staffProvider.isLoading && collegeList == null
                ? const Center(child: CircularProgressIndicator())
                : collegeList == null || collegeList.items.isEmpty
                    ? const Center(child: Text('No colleges found'))
                    : RefreshIndicator(
                        onRefresh: () => staffProvider.fetchColleges(search: _searchController.text),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: collegeList.items.length,
                          itemBuilder: (context, index) {
                            final college = collegeList.items[index];
                            return _buildCollegeCard(college);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCollegeScreen()),
          );
          if (result == true) {
            if (mounted) context.read<StaffProvider>().fetchColleges();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildCollegeCard(dynamic college) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: college.logo != null
              ? CachedNetworkImage(
                  imageUrl: college.logo,
                  placeholder: (context, url) => const Icon(Icons.school, color: Colors.grey),
                  errorWidget: (context, url, error) => const Icon(Icons.school, color: Colors.grey),
                  fit: BoxFit.cover,
                )
              : const Icon(Icons.school, color: Colors.grey),
        ),
        title: Text(college.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Code: ${college.code} | Principal: ${college.principalName ?? "N/A"}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: college.status == 'active' ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                college.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: college.status == 'active' ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _confirmDelete(college.id),
        ),
        onTap: () {
          // TODO: Navigate to details/courses
        },
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete College?'),
        content: const Text('Are you sure you want to delete this college? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              final staffProvider = context.read<StaffProvider>();
              final navigator = Navigator.of(context);
              final rootNavigator = Navigator.of(this.context);
              final messenger = ScaffoldMessenger.of(this.context);
              
              final success = await staffProvider.deleteCollege(id);
              
              if (mounted) {
                navigator.pop(); // Close dialog
                if (!success) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Failed to delete college')),
                  );
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

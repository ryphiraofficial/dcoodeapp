import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/staff_provider.dart';
import '../../constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'add_student_screen.dart';

class StaffStudentListScreen extends StatefulWidget {
  const StaffStudentListScreen({super.key});

  @override
  State<StaffStudentListScreen> createState() => _StaffStudentListScreenState();
}

class _StaffStudentListScreenState extends State<StaffStudentListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().fetchStudents();
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
    final studentList = staffProvider.studentList;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (value) => staffProvider.fetchStudents(search: value),
            ),
          ),
          Expanded(
            child: staffProvider.isLoading && studentList == null
                ? const Center(child: CircularProgressIndicator())
                : studentList == null || studentList.items.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => staffProvider.fetchStudents(search: _searchController.text),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: studentList.items.length,
                          itemBuilder: (context, index) {
                            final student = studentList.items[index];
                            return _buildStudentCard(student);
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
            MaterialPageRoute(builder: (context) => const AddStudentScreen()),
          );
          if (result == true) {
            if (mounted) context.read<StaffProvider>().fetchStudents();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No students found',
            style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first student using the + button',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(dynamic student) {
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
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage: student.photo != null ? CachedNetworkImageProvider(student.photo) : null,
            child: student.photo == null
                ? Text(student.fullName[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 20))
                : null,
          ),
          title: Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('ID: ${student.studentId} | Reg: ${student.registerNumber}', style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 2),
              Text('${student.course?.name ?? "N/A"} - ${student.batch?.name ?? "N/A"}', 
                style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddStudentScreen(student: student)),
                  );
                  if (result == true) {
                    if (mounted) context.read<StaffProvider>().fetchStudents();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: () => _confirmDelete(student.id, student.fullName),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student?'),
        content: Text('Are you sure you want to delete $name? This action will also remove all their certifications and photos.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              final staffProvider = context.read<StaffProvider>();
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(this.context);
              
              final success = await staffProvider.deleteStudent(id);
              
              if (mounted) {
                navigator.pop();
                if (success) {
                  messenger.showSnackBar(const SnackBar(content: Text('Student deleted successfully')));
                } else {
                  messenger.showSnackBar(const SnackBar(content: Text('Failed to delete student')));
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

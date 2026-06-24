import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/staff_provider.dart';
import '../../constants.dart';
import 'add_course_screen.dart';

class StaffCourseListScreen extends StatefulWidget {
  const StaffCourseListScreen({super.key});

  @override
  State<StaffCourseListScreen> createState() => _StaffCourseListScreenState();
}

class _StaffCourseListScreenState extends State<StaffCourseListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().fetchCourses();
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
    final courseList = staffProvider.courseList;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search courses...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (value) => staffProvider.fetchCourses(search: value),
            ),
          ),
          Expanded(
            child: staffProvider.isLoading && courseList == null
                ? const Center(child: CircularProgressIndicator())
                : (courseList == null || courseList.items.isEmpty)
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => staffProvider.fetchCourses(search: _searchController.text),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: courseList!.items.length,
                          itemBuilder: (context, index) {
                            final course = courseList.items[index];
                            return _buildCourseCard(course);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final staffProvider = context.read<StaffProvider>();
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCourseScreen()),
          );
          if (result == true) {
            staffProvider.fetchCourses();
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
          Icon(Icons.book_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No courses found',
            style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first course using the + button',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(dynamic course) {
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
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.book_outlined, color: AppColors.primary),
        ),
        title: Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Code: ${course.code}', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 2),
            Text('Durations: ${course.durations.join(", ")}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
              onPressed: () async {
                final staffProvider = context.read<StaffProvider>();
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCourseScreen(course: course)),
                );
                if (result == true) {
                  staffProvider.fetchCourses();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: () => _confirmDelete(course.id, course.name),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course?'),
        content: Text('Are you sure you want to delete $name? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              final staffProvider = context.read<StaffProvider>();
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(this.context);
              
              final success = await staffProvider.deleteCourse(id);
              
              if (mounted) {
                navigator.pop();
                if (success) {
                  messenger.showSnackBar(const SnackBar(content: Text('Course deleted successfully')));
                } else {
                  messenger.showSnackBar(const SnackBar(content: Text('Failed to delete course')));
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/staff_provider.dart';
import '../../constants.dart';
import 'add_batch_screen.dart';
import 'batch_students_screen.dart';
import 'package:intl/intl.dart';

class StaffBatchListScreen extends StatefulWidget {
  const StaffBatchListScreen({super.key});

  @override
  State<StaffBatchListScreen> createState() => _StaffBatchListScreenState();
}

class _StaffBatchListScreenState extends State<StaffBatchListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().fetchBatches();
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
    final batchList = staffProvider.batchList;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search batches...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (value) => staffProvider.fetchBatches(search: value),
            ),
          ),
          Expanded(
            child: staffProvider.isLoading && batchList == null
                ? const Center(child: CircularProgressIndicator())
                : (batchList == null || batchList.items.isEmpty)
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => staffProvider.fetchBatches(search: _searchController.text),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: batchList.items.length,
                          itemBuilder: (context, index) {
                            final batch = batchList.items[index];
                            return _buildBatchCard(batch);
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
            MaterialPageRoute(builder: (context) => const AddBatchScreen()),
          );
          if (result == true) {
            if (mounted) context.read<StaffProvider>().fetchBatches();
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
          Icon(Icons.groups_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No batches found',
            style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first batch using the + button',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchCard(dynamic batch) {
    final df = DateFormat('MMM dd, yyyy');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BatchStudentsScreen(batch: batch),
              ),
            );
          },
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.groups_outlined, color: AppColors.primary),
          ),
          title: Text(batch.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('Faculty: ${batch.facultyInCharge}', style: const TextStyle(fontSize: 13)),
              Text('Time: ${batch.startTime ?? "N/A"} - ${batch.endTime ?? "N/A"}', style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
              Text('Days: ${batch.workingDays == "Custom" ? batch.customWorkingDays.join(", ") : batch.workingDays}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 2),
              Text('${df.format(batch.startDate)}${batch.endDate != null ? " - " + df.format(batch.endDate!) : ""}', 
                style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
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
                    MaterialPageRoute(builder: (context) => AddBatchScreen(batch: batch)),
                  );
                  if (result == true) {
                    if (mounted) context.read<StaffProvider>().fetchBatches();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: () => _confirmDelete(batch.id, batch.name),
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
        title: const Text('Delete Batch?'),
        content: Text('Are you sure you want to delete $name? All student associations will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              final staffProvider = context.read<StaffProvider>();
              final messenger = ScaffoldMessenger.of(this.context);
              final navigator = Navigator.of(context);
              
              final success = await staffProvider.deleteBatch(id);
              
              if (mounted) {
                navigator.pop();
                if (success) {
                  messenger.showSnackBar(const SnackBar(content: Text('Batch deleted successfully')));
                } else {
                  messenger.showSnackBar(const SnackBar(content: Text('Failed to delete batch')));
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

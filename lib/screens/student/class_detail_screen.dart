import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/attendance_models.dart';
import '../../data/models/timetable_models.dart';
import '../../providers/student_provider.dart';
import '../../constants.dart';

class SessionDetailScreen extends StatefulWidget {
  final TimetableEntry entry;
  final AttendanceRecord? attendanceRecord;

  const SessionDetailScreen({
    super.key,
    required this.entry,
    this.attendanceRecord,
  });

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  AttendanceRecord? _currentRecord;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentRecord = widget.attendanceRecord;
    _fetchLatestDetails();
  }

  Future<void> _fetchLatestDetails() async {
    setState(() => _isLoading = true);
    final latestRecord = await context.read<StudentProvider>().fetchAttendanceByDate(widget.entry.date);
    if (mounted) {
      setState(() {
        _currentRecord = latestRecord;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEEE, MMMM dd, yyyy');
    
    Color statusColor = Colors.grey;
    String statusText = 'Scheduled';
    
    if (_currentRecord != null) {
      statusText = _currentRecord!.status;
      if (statusText == 'Present') statusColor = Colors.green;
      if (statusText == 'Absent') statusColor = Colors.red;
      if (statusText == 'Late') statusColor = Colors.orange;
      if (statusText == 'Leave') statusColor = Colors.blue;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SESSION DETAILS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLatestDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(df, statusText, statusColor),
              const SizedBox(height: 24),
              _buildClassInfoSection(),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
              else if (_currentRecord != null && (_currentRecord!.task != null || _currentRecord!.description != null || _currentRecord!.files.isNotEmpty))
                _buildTasksSection()
              else
                _buildEmptyStateSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(DateFormat df, String status, Color statusColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            df.format(widget.entry.date),
            style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            widget.entry.subject,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassInfoSection() {
    return _buildSectionContainer(
      title: 'Session Info',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _buildInfoRow(Icons.person_outline, 'Faculty', widget.entry.faculty),
          const Divider(height: 24),
          _buildInfoRow(Icons.access_time, 'Timing', '${widget.entry.startTime} - ${widget.entry.endTime}'),
          const Divider(height: 24),
          _buildInfoRow(Icons.location_on_outlined, 'Classroom', widget.entry.classroom),
        ],
      ),
    );
  }

  Widget _buildTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_currentRecord!.task != null && _currentRecord!.task!.isNotEmpty) ...[
          _buildSectionContainer(
            title: 'Today\'s Task',
            icon: Icons.assignment_turned_in_outlined,
            iconColor: Colors.blue,
            child: Text(
              _currentRecord!.task!,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (_currentRecord!.description != null && _currentRecord!.description!.isNotEmpty) ...[
          _buildSectionContainer(
            title: 'Description',
            icon: Icons.description_outlined,
            child: Text(
              _currentRecord!.description!,
              style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (_currentRecord!.files.isNotEmpty)
          _buildSectionContainer(
            title: 'Attachments',
            icon: Icons.attach_file,
            iconColor: Colors.orange,
            child: Column(
              children: _currentRecord!.files.map((file) => _buildFileItem(file)).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyStateSection() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.auto_awesome_motion_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No additional tasks or files uploaded for this session yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required String title, required IconData icon, required Widget child, Color? iconColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor ?? AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildFileItem(String url) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf_outlined, color: Colors.redAccent, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Session Material',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_for_offline_outlined, color: Colors.blue),
            onPressed: () {
              // Logic to open URL
            },
          ),
        ],
      ),
    );
  }
}

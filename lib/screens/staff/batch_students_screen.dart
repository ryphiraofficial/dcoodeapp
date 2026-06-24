import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import '../../providers/staff_provider.dart';
import '../../constants.dart';
import '../../data/models/batch_models.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'mark_attendance_screen.dart';
import 'package:dcoode/features/certificate/certificate_preview_screen.dart';
import 'package:dcoode/features/certificate/certificate_provider.dart';
import 'package:dcoode/features/certificate/certificate_model.dart';
import 'package:dcoode/features/certificate/certificate_service.dart';
import '../../core/services/pdf_service.dart';
import '../../data/models/attendance_models.dart';
import 'package:intl/intl.dart';

enum ReportType { daily, weekly, custom }

class BatchStudentsScreen extends StatefulWidget {
  final Batch batch;
  final DateTime? initialDate;
  const BatchStudentsScreen({super.key, required this.batch, this.initialDate});

  @override
  State<BatchStudentsScreen> createState() => _BatchStudentsScreenState();
}

class _BatchStudentsScreenState extends State<BatchStudentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().fetchStudents(batchId: widget.batch.id);
    });
  }

  void _showReportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Batch Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _optionItem(Icons.today, 'Daily Attendance Report', 'Generate PDF for selected date', () {
              Navigator.pop(context);
              _generateReport(ReportType.daily);
            }),
            _optionItem(Icons.date_range, 'Weekly Attendance Report', 'Last 7 days summary', () {
              Navigator.pop(context);
              _generateReport(ReportType.weekly);
            }),
            _optionItem(Icons.calendar_month, 'Custom Attendance Range', 'Select start and end dates', () {
              Navigator.pop(context);
              _selectCustomRange();
            }),
            const Divider(height: 32),
            _optionItem(Icons.auto_awesome, 'Generate All Certificates', 'Issue certificates to all students', () {
              Navigator.pop(context);
              _handleBulkGenerate();
            }, iconColor: Colors.amber),
          ],
        ),
      ),
    );
  }

  Widget _optionItem(IconData icon, String title, String sub, VoidCallback onTap, {Color? iconColor}) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, size: 20),
    );
  }

  Future<void> _handleBulkGenerate() async {
    final certificateProvider = context.read<CertificateProvider>();
    final descriptionController = TextEditingController();

    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Generate Certificates'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter a common description for all certificates in this batch (optional):'),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. has successfully completed...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('GENERATE')),
        ],
      ),
    );

    if (proceed != true) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await certificateProvider.bulkGenerateCertificates(
      widget.batch.id,
      description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
    );

    if (mounted) {
      Navigator.pop(context); // Close loading
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All certificates issued successfully!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to issue certificates.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _selectCustomRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: widget.batch.startDate,
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary, onPrimary: Colors.black),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _generateReport(ReportType.custom, range: picked);
    }
  }

  Future<void> _generateReport(ReportType type, {DateTimeRange? range}) async {
    final staffProvider = context.read<StaffProvider>();
    final messenger = ScaffoldMessenger.of(context);
    
    List<DateTime> dates = [];
    if (type == ReportType.daily) {
      dates = [widget.initialDate ?? DateTime.now()];
    } else if (type == ReportType.weekly) {
      final today = DateTime.now();
      for (int i = 6; i >= 0; i--) {
        dates.add(today.subtract(Duration(days: i)));
      }
    } else if (type == ReportType.custom && range != null) {
      DateTime current = range.start;
      while (current.isBefore(range.end) || isSameDay(current, range.end)) {
        dates.add(current);
        current = current.add(const Duration(days: 1));
      }
    }

    if (dates.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final Map<DateTime, List<AttendanceRecord>> allRecords = {};
      for (var date in dates) {
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        await staffProvider.fetchAttendance(batchId: widget.batch.id, date: dateStr);
        allRecords[date] = List.from(staffProvider.attendanceRecords);
      }

      if (mounted) {
        Navigator.pop(context);
        await PdfService.generateAttendanceReport(
          batch: widget.batch,
          dates: dates,
          students: staffProvider.studentList?.items ?? [],
          dateRecords: allRecords,
          title: '${type == ReportType.daily ? "Daily" : (type == ReportType.weekly ? "Weekly" : "Custom")} Attendance Report',
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        messenger.showSnackBar(SnackBar(content: Text('Failed to generate report: $e')));
      }
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _handleCertificate(String studentId) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CertificatePreviewScreen(studentId: studentId)),
    );
  }

  void _showGenerateDialog(String studentId) {
    final descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Certificate?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('An official Certificate ID will be assigned and logged for this student.'),
            const SizedBox(height: 16),
            const Text('Description (Optional):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. has successfully completed...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              final success = await context.read<CertificateProvider>().generateCertificate(
                studentId,
                description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
              );
              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CertificatePreviewScreen(studentId: studentId)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to generate certificate')));
                }
              }
            },
            child: const Text('GENERATE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final staffProvider = context.watch<StaffProvider>();
    final studentList = staffProvider.studentList;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.batch.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Students Enrolled', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () async {
              final certificateProvider = context.read<CertificateProvider>();
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );

              try {
                final List<CertificateData> certificates = await certificateProvider.fetchBatchCertificates(widget.batch.id);
                
                if (certificates.isNotEmpty) {
                  final String html = await CertificateService.generateBulkHtml(certificates);
                  final Uint8List pdfBytes = await Printing.convertHtml(
                    html: html, 
                    format: PdfPageFormat.a4.landscape
                  );
                  await Printing.sharePdf(bytes: pdfBytes, filename: 'certificates_${widget.batch.name}.pdf');
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No certificates generated for this batch yet.')),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error generating bulk certificates: $e')),
                  );
                }
              } finally {
                if (mounted) Navigator.pop(context); // Close loading
              }
            },
            icon: const Icon(Icons.collections_bookmark_outlined, color: Colors.amber),
            tooltip: 'Download All Certificates',
          ),
          IconButton(
            onPressed: _showReportOptions,
            icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.redAccent),
            tooltip: 'Attendance Reports',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MarkAttendanceScreen(
                    batch: widget.batch,
                    initialDate: widget.initialDate,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.how_to_reg, color: AppColors.primary),
            tooltip: 'Mark Attendance',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildBatchInfoCard(),
          Expanded(
            child: staffProvider.isLoading && studentList == null
                ? const Center(child: CircularProgressIndicator())
                : studentList == null || studentList.items.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => staffProvider.fetchStudents(batchId: widget.batch.id),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: studentList.items.length,
                          itemBuilder: (context, index) {
                            final student = studentList.items[index];
                            return _buildStudentTile(student);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchInfoCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.groups_outlined, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.batch.courseName ?? 'Course Name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Duration: ${widget.batch.duration ?? "N/A"}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.person_outline, 'Faculty', widget.batch.facultyInCharge),
          _buildInfoRow(Icons.access_time, 'Timing', '${widget.batch.startTime ?? "N/A"} - ${widget.batch.endTime ?? "N/A"}'),
          _buildInfoRow(Icons.calendar_month_outlined, 'Schedule', widget.batch.workingDays == "Custom" ? widget.batch.customWorkingDays.join(", ") : widget.batch.workingDays),
          _buildInfoRow(Icons.event_available, 'Start Date', DateFormat('MMM dd, yyyy').format(widget.batch.startDate)),
          if (widget.batch.endDate != null)
            _buildInfoRow(Icons.event_busy, 'End Date', DateFormat('MMM dd, yyyy').format(widget.batch.endDate!)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No students in this batch',
            style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentTile(dynamic student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage: student.photo != null ? CachedNetworkImageProvider(student.photo) : null,
            child: student.photo == null
                ? Text(student.fullName[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))
                : null,
          ),
          title: Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('ID: ${student.studentId}\n${student.email}', style: const TextStyle(fontSize: 12)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.workspace_premium_outlined, color: Colors.amber),
                onPressed: () => _handleCertificate(student.id),
                tooltip: 'Certificate',
              ),
              const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
            ],
          ),
          onTap: () {},
        ),
      ),
    );
  }
}

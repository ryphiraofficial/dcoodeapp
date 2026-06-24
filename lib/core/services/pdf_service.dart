import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/batch_models.dart';
import '../../data/models/student_models.dart';
import '../../data/models/attendance_models.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> generateAttendanceReport({
    required Batch batch,
    required List<DateTime> dates,
    required List<Student> students,
    required Map<DateTime, List<AttendanceRecord>> dateRecords,
    String title = 'Attendance Report',
  }) async {
    final pdf = pw.Document();
    final df = DateFormat('MMM dd, yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape, // Landscape is better for multiple columns
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(title, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.Text('DCOODE System', style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Batch: ${batch.name}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.Text('Course: ${batch.courseName ?? "N/A"}', style: const pw.TextStyle(fontSize: 10)),
                pw.Text('Period: ${df.format(dates.first)} - ${df.format(dates.last)}', 
                    style: pw.TextStyle(color: PdfColors.blue800, fontWeight: pw.FontWeight.bold, fontSize: 10)),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(40), // Reg No
                1: const pw.FlexColumnWidth(3),   // Name
              },
              children: [
                // Header Row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _paddedText('ID', isHeader: true),
                    _paddedText('Student Name', isHeader: true),
                    ...dates.map((date) => _paddedText(DateFormat('dd/MM').format(date), isHeader: true)),
                  ],
                ),
                // Student Rows
                ...students.map((student) {
                  return pw.TableRow(
                    children: [
                      _paddedText(student.registerNumber, fontSize: 8),
                      _paddedText(student.fullName, fontSize: 8),
                      ...dates.map((date) {
                        final records = dateRecords[date] ?? [];
                        final record = records.where((r) => r.studentId == student.id).firstOrNull;
                        final status = record?.status ?? '-';
                        return _paddedStatus(status);
                      }),
                    ],
                  );
                }),
              ],
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 30),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 100,
                        decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5))),
                      ),
                      pw.Text('Verified By', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                  pw.Text('Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}', 
                      style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
                ],
              ),
            ),
          ];
        },
      ),
    );

    final filename = 'attendance_${batch.name}_${DateFormat('yyyyMMdd').format(dates.first)}.pdf';
    await Printing.sharePdf(bytes: await pdf.save(), filename: filename);
  }

  static pw.Widget _paddedText(String text, {bool isHeader = false, double fontSize = 9}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: fontSize,
        ),
      ),
    );
  }

  static pw.Widget _paddedStatus(String status) {
    PdfColor color = PdfColors.black;
    String shortStatus = '-';
    
    if (status == 'Present') {
      color = PdfColors.green;
      shortStatus = 'P';
    } else if (status == 'Absent') {
      color = PdfColors.red;
      shortStatus = 'A';
    } else if (status == 'Late') {
      color = PdfColors.orange;
      shortStatus = 'L';
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        shortStatus,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: color),
      ),
    );
  }
}

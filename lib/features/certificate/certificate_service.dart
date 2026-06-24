import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'certificate_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'dart:convert';

class CertificateService {
  static Future<String> generateHtml(CertificateData data) async {
    try {
      debugPrint('[DEBUG] Service: Loading HTML template...');
      String html = await rootBundle.loadString(
        "assets/templates/certificate.html",
      );
      debugPrint('[DEBUG] Service: Template loaded. Length: ${html.length}');

      // Generate QR Code as Data URI
      String qrDataUri = '';
      try {
        debugPrint('[DEBUG] Service: Generating QR Code for ID: ${data.certificateId}');
        // Using a verification URL. If you have a specific verification page, update this link.
        final qrValidationResult = QrValidator.validate(
          data: 'https://dcoode.com/verify/${data.certificateId}',
          version: QrVersions.auto,
          errorCorrectionLevel: QrErrorCorrectLevel.L,
        );
        if (qrValidationResult.status == QrValidationStatus.valid) {
          final qrCode = qrValidationResult.qrCode!;
          final painter = QrPainter.withQr(
            qr: qrCode,
            color: const ui.Color(0xFF000000),
            emptyColor: const ui.Color(0xFFFFFFFF),
            gapless: true,
          );
          
          final ui.Image qrUiImage = await painter.toImage(200);
          final ByteData? qrByteData = await qrUiImage.toByteData(format: ui.ImageByteFormat.png);
          final Uint8List qrUint8List = qrByteData!.buffer.asUint8List();
          final String base64Qr = base64Encode(qrUint8List);
          qrDataUri = 'data:image/png;base64,$base64Qr';
          debugPrint('[DEBUG] Service: QR Code generated as Data URI');
        }
      } catch (e) {
        debugPrint('[DEBUG] Service: QR generation error: $e');
      }

      // Formatting dates for better display if they are ISO strings
      String formatDate(String dateStr) {
        try {
          if (dateStr.isEmpty) return 'N/A';
          final date = DateTime.parse(dateStr);
          return "${date.day}/${date.month}/${date.year}";
        } catch (_) {
          return dateStr;
        }
      }

      final start = formatDate(data.startDate);
      final end = formatDate(data.endDate);
      final issue = formatDate(data.issueDate);
      
      final String defaultDescription = "has successfully completed an Internship Program in <b>${data.courseName}</b> at <b>DCOODE</b> from <b>$start</b> to <b>$end</b>. He demonstrated dedication, punctuality, hard work and strong expertise in full-stack development.";
      final String description = data.description.isNotEmpty ? data.description : defaultDescription;

      debugPrint('[DEBUG] Service: Replacing placeholders...');
      html = html
          .replaceAll("{{NAME}}", data.studentName)
          .replaceAll("{{COURSE}}", data.courseName)
          .replaceAll("{{START_DATE}}", start)
          .replaceAll("{{END_DATE}}", end)
          .replaceAll("{{QR_CODE}}", qrDataUri)
          .replaceAll("{{REGISTER_NUMBER}}", data.registerNumber)
          .replaceAll("{{COLLEGE}}", data.collegeName)
          .replaceAll("{{CERTIFICATE_ID}}", data.certificateId)
          .replaceAll("{{DESCRIPTION}}", description)
          .replaceAll("{{ISSUE_DATE}}", issue);
      
      debugPrint('[DEBUG] Service: HTML generation complete.');
      return html;
    } catch (e) {
      debugPrint('[DEBUG] Service: HTML generation error: $e');
      rethrow;
    }
  }

  static Future<String> generateBulkHtml(List<CertificateData> dataList) async {
    String fullHtml = await rootBundle.loadString(
      "assets/templates/certificate.html",
    );

    // Extract the template part (everything inside <body>)
    final bodyStart = fullHtml.indexOf('<body>') + 6;
    final bodyEnd = fullHtml.indexOf('</body>');
    final String headAndBodyStart = fullHtml.substring(0, bodyStart);
    final String bodyTemplate = fullHtml.substring(bodyStart, bodyEnd);
    final String bodyEndAndHtmlEnd = fullHtml.substring(bodyEnd);

    String combinedBody = '';

    for (var i = 0; i < dataList.length; i++) {
      String certHtml = bodyTemplate;
      final data = dataList[i];

      // Generate QR Code
      String qrDataUri = '';
      try {
        final qrValidationResult = QrValidator.validate(
          data: 'https://dcoode.com/verify/${data.certificateId}',
          version: QrVersions.auto,
          errorCorrectionLevel: QrErrorCorrectLevel.L,
        );
        if (qrValidationResult.status == QrValidationStatus.valid) {
          final qrCode = qrValidationResult.qrCode!;
          final painter = QrPainter.withQr(
            qr: qrCode,
            color: const ui.Color(0xFF000000),
            emptyColor: const ui.Color(0xFFFFFFFF),
            gapless: true,
          );
          final ui.Image qrUiImage = await painter.toImage(200);
          final ByteData? qrByteData = await qrUiImage.toByteData(format: ui.ImageByteFormat.png);
          final String base64Qr = base64Encode(qrByteData!.buffer.asUint8List());
          qrDataUri = 'data:image/png;base64,$base64Qr';
        }
      } catch (_) {}

      final String defaultDescription = "has successfully completed an Internship Program in <b>${data.courseName}</b> at <b>DCOODE</b> from <b>${data.startDate}</b> to <b>${data.endDate}</b>. He demonstrated dedication, punctuality, hard work and strong expertise in full-stack development.";
      final String description = data.description.isNotEmpty ? data.description : defaultDescription;

      certHtml = certHtml
          .replaceAll("{{NAME}}", data.studentName)
          .replaceAll("{{COURSE}}", data.courseName)
          .replaceAll("{{START_DATE}}", data.startDate)
          .replaceAll("{{END_DATE}}", data.endDate)
          .replaceAll("{{QR_CODE}}", qrDataUri)
          .replaceAll("{{REGISTER_NUMBER}}", data.registerNumber)
          .replaceAll("{{COLLEGE}}", data.collegeName)
          .replaceAll("{{CERTIFICATE_ID}}", data.certificateId)
          .replaceAll("{{DESCRIPTION}}", description)
          .replaceAll("{{ISSUE_DATE}}", data.issueDate);

      // Add page break if not last
      if (i < dataList.length - 1) {
        certHtml = '<div style="page-break-after: always;">$certHtml</div>';
      }

      combinedBody += certHtml;
    }

    return '$headAndBodyStart$combinedBody$bodyEndAndHtmlEnd';
  }
}

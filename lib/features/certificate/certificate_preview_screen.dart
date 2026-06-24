import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import 'certificate_model.dart';
import 'certificate_provider.dart';
import 'certificate_service.dart';
import 'widgets/certificate_webview.dart';

class CertificatePreviewScreen extends StatefulWidget {
  final String? studentId;
  const CertificatePreviewScreen({super.key, this.studentId});

  @override
  State<CertificatePreviewScreen> createState() => _CertificatePreviewScreenState();
}

class _CertificatePreviewScreenState extends State<CertificatePreviewScreen> {
  String? _htmlContent;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCertificate();
  }

  Future<void> _loadCertificate() async {
    try {
      debugPrint('[DEBUG] Loading certificate for student: ${widget.studentId ?? "ME"}');
      final provider = context.read<CertificateProvider>();
      
      if (widget.studentId != null) {
        // Step 1: Try to fetch existing certificate for specific student
        await provider.fetchCertificateData(widget.studentId!);
        
        if (provider.certificateData == null) {
          // Step 2: If not found, try to generate it (Staff action)
          debugPrint('[DEBUG] Certificate not found. Attempting to generate...');
          final success = await provider.generateCertificate(widget.studentId!);
          
          if (success) {
            debugPrint('[DEBUG] Generation successful. Re-fetching...');
            await provider.fetchCertificateData(widget.studentId!);
          } else {
            debugPrint('[DEBUG] Generation failed.');
          }
        }
      } else {
        // Fetch current student's own certificate
        await provider.fetchMyCertificate();
      }
      
      if (provider.certificateData != null) {
        debugPrint('[DEBUG] Data ready. Generating HTML...');
        final html = await CertificateService.generateHtml(provider.certificateData!);
        
        if (mounted) {
          setState(() {
            _htmlContent = html;
            _isLoading = false;
          });
        }
      } else {
        debugPrint('[DEBUG] No certificate data found after generation attempt.');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e, stack) {
      debugPrint('[DEBUG] Error: $e');
      debugPrint('[DEBUG] Stack: $stack');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _exportPdf() async {
    if (_htmlContent == null) return;

    await Printing.layoutPdf(
      onLayout: (format) async => await Printing.convertHtml(
        html: _htmlContent!,
        format: PdfPageFormat.a4.landscape,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Certificate Preview', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          if (_htmlContent != null)
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: _exportPdf,
            ),
        ],
      ),
      body: _isLoading 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text("Fetching Certificate Details...", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            )
          : _htmlContent == null
              ? _buildErrorState()
              : _buildPreviewState(),
    );
  }

  Widget _buildPreviewState() {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _htmlContent != null 
                ? CertificateWebView(htmlContent: _htmlContent!)
                : const Center(child: Text("Waiting for HTML content...")),
            ),
          ),
        ),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _exportPdf,
                  icon: const Icon(Icons.download),
                  label: const Text('DOWNLOAD PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BACK', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
            const SizedBox(height: 24),
            const Text(
              'Certificate Data Not Found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'We couldn\'t fetch the certificate details for this student. Please check if the certificate has been generated on the server.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadCertificate,
              icon: const Icon(Icons.refresh),
              label: const Text('RETRY FETCHING'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                minimumSize: const Size(200, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

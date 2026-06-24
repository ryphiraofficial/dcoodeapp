import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class CertificateWebView extends StatelessWidget {
  final String htmlContent;

  const CertificateWebView({super.key, required this.htmlContent});

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialData: InAppWebViewInitialData(
        data: htmlContent,
      ),
      initialSettings: InAppWebViewSettings(
        supportZoom: true,
        displayZoomControls: true,
        useWideViewPort: true,
        loadWithOverviewMode: true,
        transparentBackground: true,
      ),
      onConsoleMessage: (controller, consoleMessage) {
        debugPrint("WebView Console: ${consoleMessage.message}");
      },
      onLoadStop: (controller, url) {
        debugPrint("WebView Load Finished: $url");
      },
      onReceivedError: (controller, request, error) {
        debugPrint("WebView Error: ${error.description}");
      },
    );
  }
}

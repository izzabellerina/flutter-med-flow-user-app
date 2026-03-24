import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import '../app/theme.dart';

class TeleconsultPage extends StatefulWidget {
  final String sessionToken;
  final String patientName;

  const TeleconsultPage({
    super.key,
    required this.sessionToken,
    required this.patientName,
  });

  @override
  State<TeleconsultPage> createState() => _TeleconsultPageState();
}

class _TeleconsultPageState extends State<TeleconsultPage> {
  bool _isLoading = true;
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    final cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
    final micGranted = statuses[Permission.microphone]?.isGranted ?? false;

    if (mounted) {
      if (cameraGranted && micGranted) {
        setState(() => _permissionGranted = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('กรุณาอนุญาตการใช้กล้องและไมโครโฟน'),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final url =
        'https://med3.medflow.in.th/teleconsult/join/${widget.sessionToken}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.patientName,
          style: AppTheme.generalText(
            18,
            fonWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end, color: Colors.red),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: _permissionGranted
          ? Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(url)),
                  initialSettings: InAppWebViewSettings(
                    mediaPlaybackRequiresUserGesture: false,
                    allowsInlineMediaPlayback: true,
                    javaScriptEnabled: true,
                    domStorageEnabled: true,
                    useWideViewPort: true,
                    supportMultipleWindows: false,
                    useShouldOverrideUrlLoading: false,
                  ),
                  onPermissionRequest: (controller, request) async {
                    return PermissionResponse(
                      resources: request.resources,
                      action: PermissionResponseAction.GRANT,
                    );
                  },
                  onLoadStop: (controller, url) {
                    if (mounted) {
                      setState(() => _isLoading = false);
                    }
                  },
                  onReceivedError: (controller, request, error) {
                    if (mounted) {
                      setState(() => _isLoading = false);
                    }
                  },
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import '../app/theme.dart';

class TelemedOverlayManager {
  static OverlayEntry? _overlayEntry;
  static bool get isActive => _overlayEntry != null;

  static Future<void> show(
    BuildContext context, {
    required String sessionToken,
    required String patientName,
  }) async {
    if (_overlayEntry != null) return;

    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    final cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
    final micGranted = statuses[Permission.microphone]?.isGranted ?? false;

    if (!context.mounted) return;

    if (!cameraGranted || !micGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาอนุญาตการใช้กล้องและไมโครโฟน'),
        ),
      );
      return;
    }

    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => _TelemedOverlayWidget(
        sessionToken: sessionToken,
        patientName: patientName,
        onClose: () => dismiss(),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  static void dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _TelemedOverlayWidget extends StatefulWidget {
  final String sessionToken;
  final String patientName;
  final VoidCallback onClose;

  const _TelemedOverlayWidget({
    required this.sessionToken,
    required this.patientName,
    required this.onClose,
  });

  @override
  State<_TelemedOverlayWidget> createState() => _TelemedOverlayWidgetState();
}

class _TelemedOverlayWidgetState extends State<_TelemedOverlayWidget>
    with SingleTickerProviderStateMixin {
  bool _isMinimized = false;
  bool _isLoading = true;

  // ตำแหน่ง PiP
  double _pipX = 16;
  double _pipY = 100;

  static const double _pipWidth = 160;
  static const double _pipHeight = 120;

  late final AnimationController _animController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _minimize() {
    // คำนวณตำแหน่งกลางจอ
    final screen = MediaQuery.of(context).size;
    // วาง PiP ตรงกลางแนวนอน, ตรงกลางแนวตั้ง (ระหว่าง tab bar กับเนื้อหา)
    _pipX = (screen.width - _pipWidth) / 2;
    _pipY = (screen.height - _pipHeight) / 2;

    setState(() => _isMinimized = true);
    _animController.forward();
  }

  void _maximize() {
    _animController.reverse().then((_) {
      if (mounted) setState(() => _isMinimized = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final safePadding = MediaQuery.of(context).padding;

    final url =
        'https://med3.medflow.in.th/teleconsult/join/${widget.sessionToken}';

    // จำกัดไม่ให้ลอยออกนอกจอ
    _pipX = _pipX.clamp(0.0, screenSize.width - _pipWidth);
    _pipY = _pipY.clamp(safePadding.top, screenSize.height - _pipHeight);

    return AnimatedBuilder(
      listenable: _animation,
      builder: (context, child) {
        final t = _animation.value; // 0 = full, 1 = pip

        // Interpolate ระหว่าง full-screen กับ PiP
        final left = t * _pipX;
        final top = t * _pipY + (1 - t) * safePadding.top;
        final width = screenSize.width + t * (_pipWidth - screenSize.width);
        final height =
            screenSize.height + t * (_pipHeight - screenSize.height);
        final borderRadius = t * 12;

        return Positioned(
          left: left,
          top: top,
          child: GestureDetector(
            onPanUpdate: _isMinimized
                ? (details) {
                    setState(() {
                      _pipX += details.delta.dx;
                      _pipY += details.delta.dy;
                    });
                  }
                : null,
            onTap: _isMinimized ? _maximize : null,
            child: Material(
              elevation: _isMinimized ? 8 : 0,
              borderRadius: BorderRadius.circular(borderRadius),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: width,
                height: height,
                child: Column(
                  children: [
                    // Top bar
                    Container(
                      color: AppTheme.primaryThemeApp,
                      padding: EdgeInsets.symmetric(
                        horizontal: _isMinimized ? 8 : 8,
                        vertical: _isMinimized ? 4 : 4,
                      ),
                      child: Row(
                        children: [
                          if (!_isMinimized)
                            IconButton(
                              icon: const Icon(Icons.picture_in_picture_alt,
                                  color: Colors.white),
                              tooltip: 'ย่อหน้าต่าง',
                              onPressed: _minimize,
                            ),
                          if (!_isMinimized) const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _isMinimized ? 'Telemed' : widget.patientName,
                              style: AppTheme.generalText(
                                _isMinimized ? 11 : 16,
                                fonWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_isMinimized)
                            GestureDetector(
                              onTap: _confirmEndCall,
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.call_end,
                                    color: Colors.red, size: 16),
                              ),
                            )
                          else
                            IconButton(
                              icon:
                                  const Icon(Icons.call_end, color: Colors.red),
                              tooltip: 'วางสาย',
                              onPressed: _confirmEndCall,
                            ),
                        ],
                      ),
                    ),

                    // WebView - อยู่ตลอด ไม่ dispose
                    Expanded(
                      child: Stack(
                        children: [
                          // WebView ที่ไม่เคยถูก remove
                          InAppWebView(
                            initialUrlRequest:
                                URLRequest(url: WebUri(url)),
                            initialSettings: InAppWebViewSettings(
                              mediaPlaybackRequiresUserGesture: false,
                              allowsInlineMediaPlayback: true,
                              javaScriptEnabled: true,
                              domStorageEnabled: true,
                              useWideViewPort: true,
                              supportMultipleWindows: false,
                              useShouldOverrideUrlLoading: false,
                            ),
                            onPermissionRequest:
                                (controller, request) async {
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
                            onReceivedError:
                                (controller, request, error) {
                              if (mounted) {
                                setState(() => _isLoading = false);
                              }
                            },
                          ),
                          if (_isLoading)
                            const Center(
                                child: CircularProgressIndicator()),
                          // ตอนย่อ วาง overlay ใสๆ ทับเพื่อให้ GestureDetector รับ tap/drag ได้
                          if (_isMinimized)
                            Container(color: Colors.transparent),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmEndCall() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('วางสาย'),
        content: const Text('ต้องการวางสายวิดีโอคอลหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onClose();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('วางสาย'),
          ),
        ],
      ),
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}

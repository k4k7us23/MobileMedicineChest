import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medicine_chest/data/barcode_finder/barcode_finder.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MedicinePackScannerPage extends StatefulWidget {
  const MedicinePackScannerPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MedicinePackScannerPageState();
  }
}

class _MedicinePackScannerPageState extends State<MedicinePackScannerPage> {

  bool _isLoading = false;
  final _barcodeFinder = BarcodeFinder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сканировать штрих-код')),
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [ScannerWidget((String barcode) {
            _onBarCodeScanned(context, barcode);
        } )],
      ),
    );
  }

  void _onBarCodeScanned(BuildContext context, String barcode) async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    _showLoaderDialog(context);

    BarcodeFinderResult result = await _barcodeFinder.find(barcode);
    _hideLoaderDialog(context);

    Navigator.of(context).pop(result);
  }

  void _showLoaderDialog(BuildContext context){
    AlertDialog alert=AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 7),child:Text("Получение информации о лекарстве" )),
        ],),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }

  void _hideLoaderDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}

class ScannerWidget extends StatefulWidget {
  final ValueChanged<String>? _barcodeCallback;

  ScannerWidget(this._barcodeCallback, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _ScannerWidgetState(_barcodeCallback);
  }
}

class _ScannerWidgetState extends State<ScannerWidget>
    with WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController();

  StreamSubscription<Object?>? _subscription;

  final ValueChanged<String>? barcodeCallback;

  _ScannerWidgetState(this.barcodeCallback);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscription = controller.barcodes.listen(_handleBarcode);
    unawaited(controller.start());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        _subscription = controller.barcodes.listen(_handleBarcode);

        unawaited(controller.start());
      case AppLifecycleState.inactive:
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(controller.stop());
    }
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    String? barcode = _getBarcodeValue(barcodes);
    if (barcode != null) {
      barcodeCallback?.call(barcode);
    }
  }

  String? _getBarcodeValue(BarcodeCapture barcodes) {
    Barcode? barcode = barcodes.barcodes.firstOrNull;
    return barcode?.rawValue;
  }

  Widget _buildScanWindow(Rect scanWindowRect) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        // Not ready.
        if (!value.isInitialized ||
            !value.isRunning ||
            value.error != null ||
            value.size.isEmpty) {
          return const SizedBox();
        }

        return CustomPaint(
          painter: ScannerOverlay(scanWindowRect),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(Offset.zero),
      width: 200,
      height: 200,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          fit: BoxFit.contain,
          scanWindow: scanWindow,
          controller: controller,
          errorBuilder: (context, error, child) {
            return _ScannerErrorWidget(error: error);
          },
        ),
        _buildScanWindow(scanWindow),
      ],
    );
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await controller.dispose();
  }
}

class ScannerOverlay extends CustomPainter {
  ScannerOverlay(this.scanWindow);

  final Rect scanWindow;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.largest);
    final cutoutPath = Path()..addRect(scanWindow);

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );
    canvas.drawPath(backgroundWithCutout, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _ScannerErrorWidget extends StatelessWidget {
  const _ScannerErrorWidget({super.key, required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    String errorMessage;

    switch (error.errorCode) {
      case MobileScannerErrorCode.controllerUninitialized:
        errorMessage = 'Controller not ready.';
      case MobileScannerErrorCode.permissionDenied:
        errorMessage = 'Permission denied';
      case MobileScannerErrorCode.unsupported:
        errorMessage = 'Scanning is unsupported on this device';
      default:
        errorMessage = 'Generic Error';
        break;
    }

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Icon(Icons.error, color: Colors.white),
            ),
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              error.errorDetails?.message ?? '',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

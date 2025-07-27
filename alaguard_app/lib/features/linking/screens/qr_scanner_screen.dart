import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../providers/linking_provider.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isScanning = true;
  bool _isProcessing = false;

  Future<void> _handleQRCode(String qrData) async {
    if (!_isScanning || _isProcessing) return;

    setState(() {
      _isScanning = false;
      _isProcessing = true;
    });

    try {
      final deviceInfo = DeviceInfoPlugin();
      String deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      
      try {
        if (Theme.of(context).platform == TargetPlatform.android) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceId = androidInfo.androidId ?? deviceId;
        } else if (Theme.of(context).platform == TargetPlatform.iOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor ?? deviceId;
        }
      } catch (e) {
        // Use generated device ID if device info fails
      }

      final linkingProvider = Provider.of<LinkingProvider>(context, listen: false);
      final success = await linkingProvider.verifyAndLinkChild(qrData, deviceId);

      if (success) {
        // Navigate to child dashboard
        Navigator.pushReplacementNamed(context, '/child-dashboard');
      } else {
        // Show error and allow retry
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(linkingProvider.errorMessage ?? 'Failed to link device'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isScanning = true;
          _isProcessing = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isScanning = true;
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Parent QR Code'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (_isScanning && barcode.rawValue != null) {
                  _handleQRCode(barcode.rawValue!);
                }
              }
            },
          ),
          
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Linking device...',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          
          if (_isScanning)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 50),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Point camera at QR code',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

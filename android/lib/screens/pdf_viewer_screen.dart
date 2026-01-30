import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui';
import 'package:pdfx/pdfx.dart';
import '../config/app_colors.dart';
import '../widgets/nanosolve_logo.dart';
import '../l10n/app_localizations.dart';
import '../services/logger_service.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

class PDFViewerScreen extends StatefulWidget {
  final String title;
  final int startPage;
  final int endPage;
  final String description;
  final String? pdfAssetPath; // Optional custom PDF asset path

  const PDFViewerScreen({
    super.key,
    required this.title,
    required this.startPage,
    required this.endPage,
    required this.description,
    this.pdfAssetPath,
  });

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  late PdfController _pdfController;
  late PdfDocument _pdfDocument;
  late TransformationController _transformationController;
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    LoggerService().logScreenNavigation('PDFViewerScreen', params: {
      'title': widget.title,
      'startPage': widget.startPage,
      'endPage': widget.endPage,
    });
    _initializePDF();
  }

  Future<void> _initializePDF() async {
    final startTime = DateTime.now();
    try {
      // Load PDF from assets - use custom path if provided, otherwise default
      final pdfPath = widget.pdfAssetPath ??
          'assets/docs/Nanoplastics_in_the_Biosphere_Report.pdf';
      final document = await PdfDocument.openAsset(pdfPath);

      // Create controller and initialize at start page
      _pdfController = PdfController(
        document: Future.value(document),
        initialPage: widget.startPage,
      );

      _pdfDocument = document;

      final loadTime = DateTime.now().difference(startTime).inMilliseconds;

      setState(() {
        _isLoading = false;
        _currentPage = widget.startPage;
      });

      // Log PDF performance
      LoggerService().logPDFPerformance(
        pages: _pdfDocument.pagesCount,
        durationMs: loadTime,
        fileSizeMB: 11, // Approximate size of compressed PDF
      );
    } catch (e) {
      final loadTime = DateTime.now().difference(startTime).inMilliseconds;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load PDF: $e';
      });

      LoggerService().logError(
        'PDFLoadFailed',
        e,
        null,
        {'title': widget.title, 'loadTime': loadTime},
      );
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    // Close document before disposing controller, only if successfully loaded
    if (!_isLoading && _error == null) {
      _pdfDocument.close();
      _pdfController.dispose();
    }
    super.dispose();
  }

  Future<void> _downloadAndSharePDF() async {
    // Check if running on web - dart:io File doesn't work on web
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'PDF download is not supported on web. Please use a mobile device.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    try {
      final sanitizedTitle =
          widget.title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
      final fileName = 'Nanoplastics_$sanitizedTitle.pdf';

      // Get PDF data from assets
      final data = await rootBundle.load(
        'assets/docs/Nanoplastics_in_the_Biosphere_Report.pdf',
      );
      final bytes = data.buffer.asUint8List();

      // Let user pick directory
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) {
        LoggerService().logUserAction('pdf_download_cancelled', params: {
          'title': widget.title,
        });
        return;
      }

      final savePath = '$selectedDirectory/$fileName';
      final file = File(savePath);
      await file.writeAsBytes(bytes);

      LoggerService().logUserAction('pdf_downloaded', params: {
        'title': widget.title,
        'filePath': savePath,
        'fileName': fileName,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('✓ PDF saved successfully'),
                const SizedBox(height: 4),
                Text(
                  fileName,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  savePath,
                  style: const TextStyle(fontSize: 10, color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      LoggerService().logError('PDFDownloadFailed', e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _openFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File saved successfully and ready to open'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File no longer exists'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      LoggerService().logError('OpenFileFailed', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              AppColors.pastelAqua.withValues(alpha: 0.05),
              AppColors.pastelLavender.withValues(alpha: 0.05),
              const Color(0xFF0A0A12),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildInfoCard(),
              Expanded(
                child: _buildPDFViewer(),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141928).withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.sourcesBack,
                style: TextStyle(
                  color: AppColors.pastelAqua,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ),
            const NanosolveLogo(height: 40),
            SizedBox(
              width: 50,
              child: Text(
                'p. $_currentPage',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppColors.pastelAqua,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.pastelAqua.withValues(alpha: 0.1),
            AppColors.pastelMint.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(color: AppColors.pastelAqua.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.description} • str. ${widget.startPage}-${widget.endPage}',
            style: TextStyle(
              color: AppColors.pastelLavender,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPDFViewer() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.pastelAqua,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading PDF...',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.pastelAqua.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 1.0,
          maxScale: 3.0,
          onInteractionUpdate: (details) {
            setState(() {
              _scale = details.scale.clamp(1.0, 3.0);
            });
          },
          child: PdfView(
            controller: _pdfController,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
              LoggerService().logPDFInteraction(
                'page_changed',
                page: page,
              );
            },
            scrollDirection: Axis.vertical,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF141928).withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (_currentPage > 1) {
                _pdfController.previousPage(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.pastelAqua.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.pastelAqua.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.arrow_back,
                size: 20,
                color: AppColors.pastelAqua,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Page ${_currentPage}/${widget.endPage}',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      final currentScale =
                          _transformationController.value.getMaxScaleOnAxis();
                      final newScale = (currentScale - 0.2).clamp(1.0, 3.0);
                      _transformationController.value = Matrix4.identity()
                        ..scale(newScale);
                      setState(() {
                        _scale = newScale;
                      });
                      LoggerService().logPDFInteraction(
                        'zoom_out',
                        page: _currentPage,
                        zoomLevel: newScale,
                      );
                    },
                    child: Icon(
                      Icons.zoom_out,
                      size: 18,
                      color: AppColors.pastelLavender.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(_scale * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: AppColors.pastelLavender,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      final currentScale =
                          _transformationController.value.getMaxScaleOnAxis();
                      final newScale = (currentScale + 0.2).clamp(1.0, 3.0);
                      _transformationController.value = Matrix4.identity()
                        ..scale(newScale);
                      setState(() {
                        _scale = newScale;
                      });
                      LoggerService().logPDFInteraction(
                        'zoom_in',
                        page: _currentPage,
                        zoomLevel: newScale,
                      );
                    },
                    child: Icon(
                      Icons.zoom_in,
                      size: 18,
                      color: AppColors.pastelLavender.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 20,
                    width: 1,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _downloadAndSharePDF,
                    child: Icon(
                      Icons.download,
                      size: 18,
                      color: AppColors.pastelMint.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              if (_currentPage < widget.endPage) {
                _pdfController.nextPage(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.pastelAqua.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.pastelAqua.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.arrow_forward,
                size: 20,
                color: AppColors.pastelAqua,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../core/extensions/build_context.dart';
import '../../domain/entities/book.dart';

class BookDetailPage extends StatefulWidget {
  final Book book;

  const BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.book.title,
          style: TextStyle(fontSize: 16.sp),
        ),
        backgroundColor: context.theme.appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _isDownloading ? null : _downloadBook,
          ),
        ],
      ),
      body: Column(
        children: [
          // Download Progress
          if (_isDownloading)
            LinearProgressIndicator(
              value: _downloadProgress,
              minHeight: 4.h,
            ),

          // PDF Viewer
          Expanded(
            child: SfPdfViewer.network(
              widget.book.url,
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to load PDF: ${details.description}'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBookInfo(),
    );
  }

  Widget _buildBookInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.book.title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'by ${widget.book.author}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                _buildInfoChip(Icons.library_books, '${widget.book.pages} pages'),
                SizedBox(width: 8.w),
                _buildInfoChip(Icons.language, widget.book.language),
                SizedBox(width: 8.w),
                if (widget.book.downloadsCount != null)
                  _buildInfoChip(Icons.download, '${widget.book.downloadsCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: Colors.blue),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadBook() async {
    // Request storage permission
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Storage permission is required to download books'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      // Get download directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final filePath = '${directory!.path}/${widget.book.title}.pdf';

      // Download file
      final dio = Dio();
      await dio.download(
        widget.book.url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded to: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isDownloading = false;
        _downloadProgress = 0.0;
      });
    }
  }
}

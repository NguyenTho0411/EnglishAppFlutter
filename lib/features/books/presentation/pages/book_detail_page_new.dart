import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../core/extensions/build_context.dart';
import '../../data/datasources/book_comments_data_source.dart';
import '../../data/models/book_comment_model.dart';
import '../../domain/entities/book.dart';

class BookDetailPage extends StatefulWidget {
  final Book book;

  const BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> with SingleTickerProviderStateMixin {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  late TabController _tabController;
  List<BookComment> _comments = [];
  bool _loadingComments = false;
  bool _hasUserReviewed = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadComments();
    _incrementViewCount();
  }

  Future<void> _incrementViewCount() async {
    try {
      final ref = FirebaseDatabase.instance.ref('Books/${widget.book.id}/viewCount');
      final snapshot = await ref.get();
      final currentCount = (snapshot.value as int?) ?? 0;
      await ref.set(currentCount + 1);
    } catch (e) {
      // Silent fail
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _loadingComments = true);
    try {
      final dataSource = BookCommentsDataSource(
        FirebaseDatabase.instance,
      );
      final comments = await dataSource.getBookComments(widget.book.id);
      final currentUser = FirebaseAuth.instance.currentUser;
      final hasReviewed = currentUser != null && 
        comments.any((c) => c.uid == currentUser.uid);
      
      setState(() {
        _comments = comments;
        _hasUserReviewed = hasReviewed;
        _loadingComments = false;
      });
    } catch (e) {
      setState(() => _loadingComments = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load comments: $e')),
        );
      }
    }
  }

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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.picture_as_pdf), text: 'PDF'),
            Tab(icon: Icon(Icons.info_outline), text: 'Details'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Download Progress
          if (_isDownloading)
            LinearProgressIndicator(
              value: _downloadProgress,
              minHeight: 4.h,
            ),

          // Tab Content
          Expanded(
            child: _tabController.length == 2 ? TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // PDF Tab
                SfPdfViewer.network(
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

                // Details Tab
                _buildDetailsTab(),
              ],
            ) : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    // Generate consistent color based on book title
    final colorSeed = widget.book.title.hashCode;
    final colors = [
      [Colors.blue[400]!, Colors.blue[700]!],
      [Colors.purple[400]!, Colors.purple[700]!],
      [Colors.green[400]!, Colors.green[700]!],
      [Colors.orange[400]!, Colors.orange[700]!],
      [Colors.red[400]!, Colors.red[700]!],
      [Colors.teal[400]!, Colors.teal[700]!],
      [Colors.indigo[400]!, Colors.indigo[700]!],
      [Colors.pink[400]!, Colors.pink[700]!],
    ];
    final colorPair = colors[colorSeed.abs() % colors.length];
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Cover & Title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120.w,
                height: 160.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colorPair,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book_rounded, size: 48.sp, color: Colors.white),
                    SizedBox(height: 8.h),
                    Text(
                      'PDF',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.book.title,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'by ${widget.book.author}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        _buildInfoChip(Icons.library_books, '${widget.book.pages} pages'),
                        _buildInfoChip(Icons.language, widget.book.language),
                        if (widget.book.viewCount != null)
                          _buildInfoChip(Icons.visibility, '${widget.book.viewCount} views'),
                        if (widget.book.downloadsCount != null)
                          _buildInfoChip(Icons.download, '${widget.book.downloadsCount} downloads'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),
          Divider(),
          SizedBox(height: 16.h),

          // Description
          _buildSection('Description', widget.book.description),

          // Publisher Info
          _buildSection(
            'Publisher',
            '${widget.book.publisher}\nPublished: ${widget.book.publishDate}',
          ),

          // ISBN
          _buildSection('ISBN', widget.book.isbn),

          SizedBox(height: 24.h),
          Divider(),
          SizedBox(height: 16.h),

          // Reviews Section
          _buildReviewsSection(),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: Colors.blue[700]),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reviews (${_comments.length})',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _hasUserReviewed ? null : _showAddReviewDialog,
              icon: Icon(Icons.add_comment),
              label: Text(_hasUserReviewed ? 'Reviewed' : 'Add Review'),
              style: TextButton.styleFrom(
                foregroundColor: _hasUserReviewed ? Colors.grey : null,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Comments List
        if (_loadingComments)
          const Center(child: CircularProgressIndicator())
        else if (_comments.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(32.h),
              child: Column(
                children: [
                  Icon(Icons.comment_outlined, size: 48.sp, color: Colors.grey),
                  SizedBox(height: 8.h),
                  Text(
                    'No reviews yet. Be the first to review!',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          ..._comments.map((comment) => _buildCommentCard(comment)).toList(),
      ],
    );
  }

  Widget _buildCommentCard(BookComment comment) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isMyComment = currentUser?.uid == comment.uid;
    final dateStr = DateFormat('MMM dd, yyyy').format(comment.dateTime);

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    (comment.userName ?? 'User').substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.userName ?? 'Anonymous User',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isMyComment)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteComment(comment.id),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              comment.comment,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReviewDialog() {
    if (_hasUserReviewed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have already reviewed this book'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Review'),
        content: TextField(
          controller: _commentController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Share your thoughts about this book...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _submitReview,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a review')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to add review')),
        );
        return;
      }

      final dataSource = BookCommentsDataSource(
        FirebaseDatabase.instance,
      );

      await dataSource.addComment(
        bookId: widget.book.id,
        uid: user.uid,
        comment: _commentController.text.trim(),
        userName: user.displayName,
        userAvatar: user.photoURL,
      );

      _commentController.clear();
      Navigator.pop(context);
      await _loadComments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add review: $e')),
      );
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final dataSource = BookCommentsDataSource(
        FirebaseDatabase.instance,
      );
      await dataSource.deleteComment(widget.book.id, commentId);
      await _loadComments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review deleted'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete review: $e')),
      );
    }
  }

  Future<void> _downloadBook() async {
    // Request storage permission for Android 12 and below
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
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
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      // Get download directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final fileName = '${widget.book.title.replaceAll(RegExp(r'[^\w\s]+'), '')}.pdf';
      final filePath = '${directory!.path}/$fileName';

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
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
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

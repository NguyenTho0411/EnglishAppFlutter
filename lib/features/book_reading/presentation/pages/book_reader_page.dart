import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'book_reading_page.dart';

class BookReaderPage extends StatefulWidget {
  final Book book;

  const BookReaderPage({
    Key? key,
    required this.book,
  }) : super(key: key);

  @override
  State<BookReaderPage> createState() => _BookReaderPageState();
}

class _BookReaderPageState extends State<BookReaderPage> {
  late PageController _pageController;
  int _currentPage = 0;
  double _fontSize = 16.0;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = widget.book.content.length;

    return Scaffold(
      body: Stack(
        children: [
          // Book Content
          GestureDetector(
            onTap: () {
              setState(() {
                _showControls = !_showControls;
              });
            },
            child: Container(
              color: Colors.white,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: totalPages,
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      widget.book.content[index],
                      style: TextStyle(
                        fontSize: _fontSize,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  );
                },
              ),
            ),
          ),

          // Top Controls
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: _showControls ? 0 : -100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.book.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.book.author,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.star_border, color: Colors.white),
                    onPressed: () => _showReviewDialog(context),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Controls
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: _showControls ? 0 : -120,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress Bar
                  LinearProgressIndicator(
                    value: (_currentPage + 1) / totalPages,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 8),

                  // Page Info and Controls
                  Row(
                    children: [
                      Text(
                        '${_currentPage + 1} / $totalPages',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.text_decrease, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _fontSize = (_fontSize - 2).clamp(12.0, 24.0);
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.text_increase, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _fontSize = (_fontSize + 2).clamp(12.0, 24.0);
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          _currentPage > 0 ? Icons.arrow_back_ios : Icons.arrow_back_ios,
                          color: _currentPage > 0 ? Colors.white : Colors.white38,
                        ),
                        onPressed: _currentPage > 0
                            ? () => _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                )
                            : null,
                      ),
                      IconButton(
                        icon: Icon(
                          _currentPage < totalPages - 1 ? Icons.arrow_forward_ios : Icons.arrow_forward_ios,
                          color: _currentPage < totalPages - 1 ? Colors.white : Colors.white38,
                        ),
                        onPressed: _currentPage < totalPages - 1
                            ? () => _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                )
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BookReviewDialog(book: widget.book),
    );
  }
}

class BookReviewDialog extends StatefulWidget {
  final Book book;

  const BookReviewDialog({
    Key? key,
    required this.book,
  }) : super(key: key);

  @override
  State<BookReviewDialog> createState() => _BookReviewDialogState();
}

class _BookReviewDialogState extends State<BookReviewDialog> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Review ${widget.book.title}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Star Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
                onPressed: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 16),

          // Review Text
          TextField(
            controller: _reviewController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Write your review...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitReview,
          child: const Text('Submit Review'),
        ),
      ],
    );
  }

  void _submitReview() {
    if (_rating > 0) {
      // TODO: Save review to database
      final review = BookReview(
        bookId: widget.book.id,
        rating: _rating,
        review: _reviewController.text.trim(),
        date: DateTime.now(),
      );

      // For now, just show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
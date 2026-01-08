import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/build_context.dart';
import '../../../../injection_container.dart';
import '../../data/services/book_chatbot_service.dart';
import '../../domain/entities/book.dart';
import '../bloc/books_bloc.dart';
import '../widgets/book_chatbot_dialog.dart';
import 'book_detail_page_new.dart';

class BooksPage extends StatelessWidget {
  const BooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<BooksBloc>()..add(const LoadBooksEvent()),
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Books Library'),
          backgroundColor: context.theme.appBarTheme.backgroundColor,
          elevation: 0,
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 70.h), // Add padding to avoid bottom nav
          child: FloatingActionButton.extended(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => BookChatbotDialog(
                  chatbotService: getIt<BookChatbotService>(),
                ),
              );
            },
            backgroundColor: Colors.blue[700],
            icon: const Icon(Icons.smart_toy, color: Colors.white),
            label: const Text(
              'AI Assistant',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        body: BlocBuilder<BooksBloc, BooksState>(
          builder: (context, state) {
            if (state is BooksLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is BooksError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.sp,
                      color: Colors.red,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Error: ${state.message}',
                      style: TextStyle(fontSize: 16.sp),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        context.read<BooksBloc>().add(const LoadBooksEvent());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is BooksLoaded) {
              if (state.books.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.menu_book,
                        size: 64.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No books available',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<BooksBloc>().add(const LoadBooksEvent());
                },
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: state.books.length,
                  itemBuilder: (context, index) {
                    final book = state.books[index];
                    return _BookCard(book: book);
                  },
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;

  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    // Generate color based on book title for consistent colors
    final colorSeed = book.title.hashCode;
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
    
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.read<BooksBloc>().add(IncrementViewCountEvent(book.id));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailPage(book: book),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Cover Placeholder (PDF doesn't have thumbnail)
              Container(
                width: 80.w,
                height: 110.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colorPair,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Book icon
                    Center(
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 36.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    // PDF badge
                    Positioned(
                      bottom: 6.h,
                      right: 6.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'PDF',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              // Book Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'by ${book.author}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      book.description,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.library_books, size: 16.sp, color: Colors.blue),
                        SizedBox(width: 4.w),
                        Text(
                          '${book.pages} pages',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        if (book.viewCount != null) ...[
                          Icon(Icons.visibility, size: 16.sp, color: Colors.green),
                          SizedBox(width: 4.w),
                          Text(
                            '${book.viewCount}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

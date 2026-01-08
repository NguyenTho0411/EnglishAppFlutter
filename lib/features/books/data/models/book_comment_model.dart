class BookComment {
  final String id;
  final String bookId;
  final String uid;
  final String comment;
  final String timestamp;
  final String? userName;
  final String? userAvatar;

  BookComment({
    required this.id,
    required this.bookId,
    required this.uid,
    required this.comment,
    required this.timestamp,
    this.userName,
    this.userAvatar,
  });

  factory BookComment.fromJson(Map<String, dynamic> json, String id) {
    return BookComment(
      id: id,
      bookId: json['bookId'] as String? ?? '',
      uid: json['uid'] as String? ?? '',
      comment: json['comment'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      userName: json['userName'] as String?,
      userAvatar: json['userAvatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'uid': uid,
      'comment': comment,
      'timestamp': timestamp,
      if (userName != null) 'userName': userName,
      if (userAvatar != null) 'userAvatar': userAvatar,
    };
  }

  DateTime get dateTime {
    try {
      return DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
    } catch (e) {
      return DateTime.now();
    }
  }
}

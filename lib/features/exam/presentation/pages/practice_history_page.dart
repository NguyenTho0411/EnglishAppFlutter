import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/services/firestore_exam_service.dart';
import '../../../authentication/presentation/blocs/auth/auth_bloc.dart';

class PracticeHistoryPage extends StatefulWidget {
  const PracticeHistoryPage({Key? key}) : super(key: key);

  @override
  State<PracticeHistoryPage> createState() => _PracticeHistoryPageState();
}

class _PracticeHistoryPageState extends State<PracticeHistoryPage> {
  final FirestoreExamService _examService = FirestoreExamService();
  List<Map<String, dynamic>> _history = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;
  String? _filterSkill;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = context.read<AuthBloc>().state.user;
    if (user == null) return;

    setState(() => _isLoading = true);

    final history = await _examService.getUserPracticeHistory(
      userId: user.uid,
      skillType: _filterSkill,
    );
    final stats = await _examService.getPracticeStatistics(user.uid);

    if (mounted) {
      setState(() {
        _history = history;
        _statistics = stats;
        _isLoading = false;
      });
    }
  }

  void _filterBySkill(String? skill) {
    setState(() => _filterSkill = skill);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Practice History'), centerTitle: true),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatistics(),
                _buildFilterChips(),
                Expanded(child: _buildHistoryList()),
              ],
            ),
    );
  }

  Widget _buildStatistics() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Practices',
            style: TextStyle(color: Colors.white70, fontSize: 14.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            '${_statistics['totalPractices'] ?? 0}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSkillStat(
                'Reading',
                _statistics['readingCount'] ?? 0,
                _statistics['avgReadingBand'] ?? 0.0,
                Colors.blue,
              ),
              _buildSkillStat(
                'Listening',
                _statistics['listeningCount'] ?? 0,
                _statistics['avgListeningBand'] ?? 0.0,
                Colors.orange,
              ),
              _buildSkillStat(
                'Writing',
                _statistics['writingCount'] ?? 0,
                _statistics['avgWritingBand'] ?? 0.0,
                Colors.green,
              ),
              _buildSkillStat(
                'Speaking',
                _statistics['speakingCount'] ?? 0,
                _statistics['avgSpeakingBand'] ?? 0.0,
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillStat(String skill, int count, double avgBand, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            _getSkillIcon(skill.toLowerCase()),
            color: Colors.white,
            size: 24.w,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          skill,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '$count',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          avgBand > 0 ? 'Avg: ${avgBand.toStringAsFixed(1)}' : '-',
          style: TextStyle(color: Colors.white70, fontSize: 10.sp),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('All', null),
          SizedBox(width: 8.w),
          _buildFilterChip('Reading', 'reading'),
          SizedBox(width: 8.w),
          _buildFilterChip('Listening', 'listening'),
          SizedBox(width: 8.w),
          _buildFilterChip('Writing', 'writing'),
          SizedBox(width: 8.w),
          _buildFilterChip('Speaking', 'speaking'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? skill) {
    final isSelected = _filterSkill == skill;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _filterBySkill(skill),
      selectedColor: Color(0xFF667eea),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80.w, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              'No practice history yet',
              style: TextStyle(fontSize: 18.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 8.h),
            Text(
              'Start practicing to see your history here',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        return _buildHistoryItem(item);
      },
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final skillType = item['skillType'] ?? '';
    final testTitle = item['testTitle'] ?? 'Practice';
    final bandScore = item['bandScore'] ?? 0.0;
    final score = item['score'] ?? 0;
    final totalQuestions = item['totalQuestions'] ?? 0;
    final timeSpent = item['timeSpent'] ?? 0;
    final completedAt = item['completedAt'];

    String dateStr = '';
    if (completedAt != null) {
      final date = completedAt.toDate();
      dateStr = DateFormat('MMM dd, yyyy HH:mm').format(date);
    }

    final color = _getSkillColor(skillType);
    final icon = _getSkillIcon(skillType);

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.w),
        leading: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: color, size: 28.w),
        ),
        title: Text(
          testTitle,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.score, size: 16.w, color: Colors.grey),
                SizedBox(width: 4.w),
                Text('Band: ${bandScore.toStringAsFixed(1)}'),
                SizedBox(width: 16.w),
                if (totalQuestions > 0) ...[
                  Icon(Icons.question_answer, size: 16.w, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Text('$score/$totalQuestions'),
                ],
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.access_time, size: 16.w, color: Colors.grey),
                SizedBox(width: 4.w),
                Text(dateStr),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: _getBandColor(bandScore),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            bandScore.toStringAsFixed(1),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
        ),
      ),
    );
  }

  Color _getSkillColor(String skill) {
    switch (skill) {
      case 'reading':
        return Colors.blue;
      case 'listening':
        return Colors.orange;
      case 'writing':
        return Colors.green;
      case 'speaking':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getSkillIcon(String skill) {
    switch (skill) {
      case 'reading':
        return Icons.book_outlined;
      case 'listening':
        return Icons.headphones_outlined;
      case 'writing':
        return Icons.edit_outlined;
      case 'speaking':
        return Icons.mic_outlined;
      default:
        return Icons.quiz;
    }
  }

  Color _getBandColor(double band) {
    if (band >= 8.0) return Colors.green;
    if (band >= 7.0) return Colors.blue;
    if (band >= 6.0) return Colors.orange;
    if (band >= 5.0) return Colors.deepOrange;
    return Colors.red;
  }
}

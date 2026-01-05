import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../routes/route_manager.dart';
import '../../../features/authentication/presentation/blocs/auth/auth_bloc.dart';
import '../../../features/exam/domain/entities/exam_type.dart';
import '../../../features/exam/presentation/cubits/exam_cubit.dart';
import '../../../features/exam/presentation/cubits/exam_state.dart';

class ExamHomePage extends StatefulWidget {
  const ExamHomePage({Key? key}) : super(key: key);

  @override
  State<ExamHomePage> createState() => _ExamHomePageState();
}

class _ExamHomePageState extends State<ExamHomePage> {
  ExamType _selectedExam = ExamType.ielts;
  void _navigateTo(String route) {
    context.push(route, extra: {'examType': _selectedExam});
  }

  List<Widget> _buildSkillCards() {
    if (_selectedExam == ExamType.ielts) {
      // Trả về 4 kỹ năng cho IELTS
      return [
        _SkillCard(
          skill: SkillType.reading,
          examType: _selectedExam,
          onTap: () => _navigateTo(AppRoutes.readingPractice),
        ),
        _SkillCard(
          skill: SkillType.listening,
          examType: _selectedExam,
          onTap: () => _navigateTo(AppRoutes.listeningPractice),
        ),
        _SkillCard(
          skill: SkillType.writing,
          examType: _selectedExam,
          onTap: () => _navigateTo(AppRoutes.writingPractice),
        ),
        _SkillCard(
          skill: SkillType.speaking,
          examType: _selectedExam,
          onTap: () => _navigateTo(AppRoutes.speakingPractice),
        ),
      ];
    } else {
      // Trả về danh sách khác cho TOEIC (ví dụ chỉ có 2 kỹ năng)
      return [
        _SkillCard(
          skill: SkillType.reading,
          examType: _selectedExam,
          onTap: () => _navigateTo(AppRoutes.readingPractice),
        ),
        _SkillCard(
          skill: SkillType.listening,
          examType: _selectedExam,
          onTap: () => _navigateTo(AppRoutes.listeningPractice),
        ),
        // Bạn có thể thêm các thẻ đặc thù cho TOEIC ở đây
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  void _loadProgress() {
    final user = context.read<AuthBloc>().state.user;
    if (user != null) {
      context.read<ExamCubit>().loadAllSkillProgress(
        userId: user.uid,
        examType: _selectedExam,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IELTS/TOEIC Practice'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Exam Type Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: _ExamTypeCard(
                    examType: ExamType.ielts,
                    isSelected: _selectedExam == ExamType.ielts,
                    onTap: () {
                      setState(() {
                        _selectedExam = ExamType.ielts;
                      });
                      _loadProgress();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ExamTypeCard(
                    examType: ExamType.toeic,
                    isSelected: _selectedExam == ExamType.toeic,
                    onTap: () {
                      setState(() {
                        _selectedExam = ExamType.toeic;
                      });
                      _loadProgress();
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Skills Grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Practice by Skill',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: _buildSkillCards(),
                  ),
                  const SizedBox(height: 32),
                  // Mock Tests Section
                  const Text(
                    'Mock Tests',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _ActionCard(
                    icon: Icons.assignment,
                    title: 'Full Mock Test',
                    subtitle:
                        'Complete ${_selectedExam.displayName} exam simulation',
                    color: Colors.purple,
                    onTap: () {
                      context.push(
                        AppRoutes.mockTest,
                        extra: {'examType': _selectedExam},
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  // AI Features Section
                  const Text(
                    'AI-Powered Features',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _ActionCard(
                    icon: Icons.chat,
                    title: 'AI Tutor',
                    subtitle: 'Get personalized help and explanations',
                    color: Colors.teal,
                    onTap: () {
                      context.push(AppRoutes.aiTutor);
                    },
                  ),
                  const SizedBox(height: 16),
                  _ActionCard(
                    icon: Icons.analytics,
                    title: 'Progress & Analytics',
                    subtitle: 'View detailed stats and predictions',
                    color: Colors.indigo,
                    onTap: () {
                      context.push(
                        AppRoutes.examProgress,
                        extra: {'examType': _selectedExam},
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamTypeCard extends StatelessWidget {
  final ExamType examType;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExamTypeCard({
    Key? key,
    required this.examType,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              examType.code,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              examType.displayName,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white70 : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  final SkillType skill;
  final ExamType examType;
  final VoidCallback onTap;

  const _SkillCard({
    Key? key,
    required this.skill,
    required this.examType,
    required this.onTap,
  }) : super(key: key);

  Color _getSkillColor() {
    switch (skill) {
      case SkillType.listening:
        return Colors.orange;
      case SkillType.reading:
        return Colors.blue;
      case SkillType.writing:
        return Colors.green;
      case SkillType.speaking:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSkillColor();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    skill.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                skill.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              BlocBuilder<ExamCubit, ExamState>(
                builder: (context, state) {
                  if (state is SkillProgressLoadedState) {
                    final progress = state.progressList.firstWhere(
                      (p) => p.skill == skill,
                      orElse: () => state.progressList.first,
                    );
                    return Column(
                      children: [
                        Text(
                          'Band ${progress.currentBandScore.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${progress.overallAccuracy.toStringAsFixed(0)}% accuracy',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    );
                  }
                  return Text(
                    'Start practicing',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

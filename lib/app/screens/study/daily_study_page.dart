import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/authentication/presentation/blocs/auth/auth_bloc.dart';
import '../../../features/word/domain/entities/word_status.dart';
import '../../../features/word/presentation/cubits/word_progress/word_progress_cubit.dart';
import '../../../injection_container.dart';
import '../../routes/route_manager.dart';

class DailyStudyPage extends StatefulWidget {
  const DailyStudyPage({super.key});

  @override
  State<DailyStudyPage> createState() => _DailyStudyPageState();
}

class _DailyStudyPageState extends State<DailyStudyPage> {
  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  void _loadProgress() {
    final uid = context.read<AuthBloc>().state.user?.uid;
    if (uid != null) {
      context.read<WordProgressCubit>().initProgressStream(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Study'),
        elevation: 0,
      ),
      body: BlocBuilder<WordProgressCubit, WordProgressState>(
        builder: (context, state) {
          if (state.status == WordProgressStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == WordProgressStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'An error occurred',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProgress,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final dueWords = state.dueWords;
          final newWords = state.newWords;
          final difficultWords = state.difficultWords;
          final dailyGoal = state.dailyGoal;

          return RefreshIndicator(
            onRefresh: () async {
              _loadProgress();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Daily Goal Card
                  _buildDailyGoalCard(dailyGoal),
                  const SizedBox(height: 24),

                  // Study Sections
                  _buildStudySection(
                    title: 'Review Due Words',
                    subtitle: 'Words that need review today',
                    icon: Icons.schedule,
                    color: Colors.red,
                    count: dueWords.length,
                    onTap: dueWords.isNotEmpty
                        ? () => _startStudy(context, dueWords, 'Due Words')
                        : null,
                  ),
                  const SizedBox(height: 16),

                  _buildStudySection(
                    title: 'Learn New Words',
                    subtitle: 'Start learning fresh vocabulary',
                    icon: Icons.auto_stories,
                    color: Colors.blue,
                    count: newWords.length,
                    onTap: newWords.isNotEmpty
                        ? () => _startStudy(context, newWords, 'New Words')
                        : null,
                  ),
                  const SizedBox(height: 16),

                  _buildStudySection(
                    title: 'Practice Difficult Words',
                    subtitle: 'Words you find challenging',
                    icon: Icons.fitness_center,
                    color: Colors.orange,
                    count: difficultWords.length,
                    onTap: difficultWords.isNotEmpty
                        ? () => _startStudy(context, difficultWords, 'Difficult Words')
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // Statistics Card
                  _buildStatisticsCard(state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailyGoalCard(Map<String, int> dailyGoal) {
    final dueGoal = dailyGoal['due'] ?? 0;
    final newGoal = dailyGoal['new'] ?? 0;
    final totalGoal = dailyGoal['total'] ?? 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.purple.shade400, Colors.purple.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Text(
              '📚 Today\'s Goal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGoalItem('Due', dueGoal, Colors.red.shade300),
                _buildGoalItem('New', newGoal, Colors.blue.shade300),
                _buildGoalItem('Total', totalGoal, Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStudySection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int count,
    VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;

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
                padding: const EdgeInsets.all(12),
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isEnabled ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isEnabled ? Colors.black54 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: isEnabled ? Colors.grey : Colors.grey.shade300,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(WordProgressState state) {
    final wordsByStatus = state.wordsByStatus;
    final totalWords = state.totalWords;
    final accuracy = state.overallAccuracy;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Your Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('Total Words', '$totalWords', Colors.purple),
                _buildStatItem('Accuracy', '${accuracy.toStringAsFixed(1)}%', Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ...WordStatus.values.map((status) {
              final count = wordsByStatus[status] ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(
                      status.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        status.displayName,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _startStudy(BuildContext context, List words, String category) {
    // Navigate to study session page with proper learning flow
    Navigator.pushNamed(
      context,
      AppRoutes.studySession,
      arguments: {
        'words': words,
        'title': category,
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_logger.dart';
import '../../features/authentication/presentation/pages/authentication_page.dart';
import '../../features/authentication/presentation/pages/change_password_page.dart';
import '../../features/mini_game/domain/entities/quiz_entity.dart';
import '../../features/mini_game/domain/entities/quiz_type.dart';
import '../../features/mini_game/presentation/pages/quiz/game_quiz_page.dart';
import '../../features/mini_game/presentation/pages/quiz/game_quiz_summery_page.dart';
import '../../features/mini_game/presentation/pages/quiz/quiz_type_selection_page.dart';
import '../../features/mini_game/presentation/pages/sliding_puzzle/sliding_puzzle_page.dart';
import '../../features/user/user_profile/presentation/pages/favourite/favourite_page.dart';
import '../../features/user/user_profile/presentation/pages/known_word/known_word_page.dart';
import '../../features/word/domain/entities/word_entity.dart';
import '../../injection_container.dart';
import '../managers/navigation.dart';
import '../managers/shared_preferences.dart';
import '../screens/cart/cart_page.dart';
import '../screens/entry/entry_page.dart';
import '../screens/main/main_page.dart';
import '../screens/main/pages/activity/activity_flash_card_page.dart';
import '../screens/main/pages/activity/activity_page.dart';
import '../screens/main/pages/activity/activity_word_store_page.dart';
import '../screens/main/pages/home/home_page.dart';
import '../screens/main/pages/profile/profile_page.dart';
import '../screens/main/pages/search/search_page.dart';
import '../screens/on_board/pages/on_board_page.dart';
import '../screens/setting/setting_page.dart';
import '../screens/study/daily_study_page.dart';
import '../screens/study/study_session_page.dart';
import '../screens/exam/exam_home_page.dart';
import '../../features/exam/presentation/pages/reading_practice_page.dart';
import '../../features/exam/presentation/pages/listening_practice_page.dart';
import '../../features/exam/presentation/pages/writing_practice_page.dart';
import '../../features/exam/presentation/pages/speaking_practice_page.dart';
import '../../features/exam/presentation/pages/mock_test_page.dart';
import '../../features/exam/presentation/pages/mock_test_execution_page.dart';
import '../../features/exam/presentation/pages/mock_test_results_page.dart';
import '../../features/exam/presentation/pages/exam_progress_page.dart';
import '../../features/exam/presentation/pages/practice_history_page.dart';
import '../../features/ai_tutor/presentation/pages/ai_tutor_page.dart';
import '../../features/exam/domain/entities/exam_type.dart';
import '../../features/exam/domain/entities/test_entity.dart';

part 'routes.dart';

class AppRouter {
  GoRouter router = GoRouter(
    navigatorKey: Navigators().navigationKey,
    initialLocation: AppRoutes.init,
    routes: [
      //? Route: '/'
      GoRoute(
        path: AppRoutes.init,
        builder: (context, state) {
          if (!sl<SharedPrefManager>().isCheckedInOnboard) {
            return const OnBoardPage();
          }
          return const EntryPage();
        },
      ),
      //? Route: '/authentication'
      GoRoute(
        path: AppRoutes.authentication,
        builder: (context, state) {
          logger.f(state.fullPath);
          return const AuthenticationPage();
        },
        routes: const [],
      ),
      //? Route: '/setting'
      GoRoute(
        path: AppRoutes.setting,
        pageBuilder: (context, state) {
          logger.f(state.fullPath);

          return slideTransitionPage(
            context: context,
            state: state,
            child: const SettingPage(),
          );
        },
        routes: const [],
      ),
      //? Route: '/favourite'
      GoRoute(
        path: AppRoutes.favourite,
        pageBuilder: (context, state) {
          logger.f(state.fullPath);

          return slideTransitionPage(
            context: context,
            state: state,
            child: const FavouritePage(),
          );
        },
        routes: const [],
      ),
      //? Route: '/knownWord'
      GoRoute(
        path: AppRoutes.knownWord,
        pageBuilder: (context, state) {
          logger.f(state.fullPath);

          return slideTransitionPage(
            context: context,
            state: state,
            child: const KnownWordPage(),
          );
        },
        routes: const [],
      ),
      //? Route: '/changePassword'
      GoRoute(
        path: AppRoutes.changePassword,
        pageBuilder: (context, state) {
          logger.f(state.fullPath);

          return slideTransitionPage(
            context: context,
            state: state,
            child: const ChangePasswordPage(),
          );
        },
        routes: const [],
      ),
      //? Route: '/listWord'
      GoRoute(
        path: AppRoutes.listWord,
        pageBuilder: (context, state) {
          logger.f(state.fullPath);

          return slideTransitionPage(
            context: context,
            state: state,
            child: const ActivityWordStorePage(),
          );
        },
        routes: const [],
      ),
      //? Route: '/flashCard'
      GoRoute(
        path: AppRoutes.flashCard,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          logger.f("${state.fullPath}");

          return slideTransitionPage(
            context: context,
            state: state,
            child: FlashCardPage(
              title: args?['title'] ?? '',
              words: args?['words'] ?? [],
            ),
          );
        },
        routes: const [],
      ),
      //? Route: '/cart'
      GoRoute(
        path: AppRoutes.cart,
        pageBuilder: (context, state) {
          logger.f("${state.fullPath}");

          return slideTransitionPage(
            context: context,
            state: state,
            child: const CartPage(),
          );
        },
        routes: const [],
      ),
      //? Route: '/quizTypeSelection'
      GoRoute(
        path: AppRoutes.quizTypeSelection,
        pageBuilder: (context, state) {
          logger.f("${state.fullPath}");
          final args = state.extra as List<WordEntity>?;

          return slideTransitionPage(
            context: context,
            state: state,
            child: QuizTypeSelectionPage(words: args ?? []),
          );
        },
        routes: const [],
      ),
      //? Route: '/quiz'
      GoRoute(
        path: AppRoutes.quiz,
        pageBuilder: (context, state) {
          logger.f("${state.fullPath}");
          final extra = state.extra;
          
          List<WordEntity> words = [];
          QuizType quizType = QuizType.meaningToWord;
          
          if (extra is Map<String, dynamic>) {
            words = extra['words'] as List<WordEntity>? ?? [];
            quizType = extra['type'] as QuizType? ?? QuizType.meaningToWord;
          } else if (extra is List<WordEntity>) {
            words = extra;
          }

          return slideTransitionPage(
            context: context,
            state: state,
            child: GameQuizPage(words: words, quizType: quizType),
          );
        },
        routes: const [],
      ),
      //? Route: '/quizSummery'
      GoRoute(
        path: AppRoutes.quizSummery,
        pageBuilder: (context, state) {
          logger.f("${state.fullPath}");
          final args = state.extra as List<QuizEntity>?;

          return slideTransitionPage(
            context: context,
            state: state,
            child: GameQuizSummeryPage(quizs: args ?? []),
          );
        },
        routes: const [],
      ),
      //? Route: '/slidingPuzzle'
      GoRoute(
        path: AppRoutes.slidingPuzzle,
        pageBuilder: (context, state) {
          logger.f("${state.fullPath}");
          final args = state.extra as List<WordEntity>?;

          return slideTransitionPage(
            context: context,
            state: state,
            child: SlidingPuzzlePage(words: args ?? []),
          );
        },
        routes: const [],
      ),
      //? Route: '/dailyStudy'
      GoRoute(
        path: AppRoutes.dailyStudy,
        pageBuilder: (context, state) {
          logger.f("${state.fullPath}");

          return slideTransitionPage(
            context: context,
            state: state,
            child: const DailyStudyPage(),
          );
        },
        routes: const [],
      ),
      //? Route: '/studySession'
      GoRoute(
        path: AppRoutes.studySession,
        pageBuilder: (context, state) {
          logger.f("${state.fullPath}");
          final args = state.extra as Map<String, dynamic>?;

          return slideTransitionPage(
            context: context,
            state: state,
            child: StudySessionPage(
              words: args?['words'] ?? [],
              sessionTitle: args?['title'] ?? 'Study Session',
            ),
          );
        },
        routes: const [],
      ),

      //? Route: '/examHome'
      GoRoute(
        path: AppRoutes.examHome,
        pageBuilder: (context, state) {
          logger.f("${state.fullPath}");
          return slideTransitionPage(
            context: context,
            state: state,
            child: const ExamHomePage(),
          );
        },
        routes: const [],
      ),

      //? Route: '/readingPractice'
      GoRoute(
        path: AppRoutes.readingPractice,
        pageBuilder: (context, state) {
          logger.f("${state.fullPath}");
          final args = state.extra as Map<String, dynamic>?;
          final examType = args?['examType'] as ExamType? ?? ExamType.ielts;
          final passageId = args?['passageId'] as String?;
          final difficulty = args?['difficulty'] as DifficultyLevel?;

          return slideTransitionPage(
            context: context,
            state: state,
            child: ReadingPracticePage(
              examType: examType,
              passageId: passageId,
              difficulty: difficulty,
            ),
          );
        },
        routes: const [],
      ),

      //? Route: '/listeningPractice'
      GoRoute(
        path: AppRoutes.listeningPractice,
        pageBuilder: (context, state) {
          logger.f("${state.fullPath}");
          final args = state.extra as Map<String, dynamic>?;
          final examType = args?['examType'] as ExamType? ?? ExamType.ielts;
          final audioId = args?['audioId'] as String?;
          final difficulty = args?['difficulty'] as DifficultyLevel?;

          return slideTransitionPage(
            context: context,
            state: state,
            child: ListeningPracticePage(
              examType: examType,
              audioId: audioId,
              difficulty: difficulty,
            ),
          );
        },
        routes: const [],
      ),

      //? Route: '/writingPractice'
      GoRoute(
        path: AppRoutes.writingPractice,
        pageBuilder: (context, state) {
          logger.f("${state.fullPath}");
          final args = state.extra as Map<String, dynamic>?;
          final examType = args?['examType'] as ExamType? ?? ExamType.ielts;
          final taskId = args?['taskId'] as String?;
          final difficulty = args?['difficulty'] as DifficultyLevel?;

          return slideTransitionPage(
            context: context,
            state: state,
            child: WritingPracticePage(
              examType: examType,
              taskId: taskId,
              difficulty: difficulty,
            ),
          );
        },
        routes: const [],
      ),

      //? Route: '/speakingPractice'
      GoRoute(
        path: AppRoutes.speakingPractice,
        pageBuilder: (context, state) {
          logger.f("${state.fullPath}");
          final args = state.extra as Map<String, dynamic>?;
          final examType = args?['examType'] as ExamType? ?? ExamType.ielts;
          final questionId = args?['questionId'] as String?;
          final difficulty = args?['difficulty'] as DifficultyLevel?;

          return slideTransitionPage(
            context: context,
            state: state,
            child: SpeakingPracticePage(
              examType: examType,
              questionId: questionId,
              difficulty: difficulty,
            ),
          );
        },
        routes: const [],
      ),

      //? Route: '/mockTest'
      GoRoute(
        path: AppRoutes.mockTest,
        pageBuilder: (context, state) {
          logger.f("${state.fullPath}");
          final args = state.extra as Map<String, dynamic>?;
          final examType = args?['examType'] as ExamType? ?? ExamType.ielts;
          final testId = args?['testId'] as String?;

          return slideTransitionPage(
            context: context,
            state: state,
            child: MockTestPage(
              examType: examType,
              testId: testId,
            ),
          );
        },
        routes: const [],
      ),

      //? Route: '/examProgress'
      GoRoute(
        path: AppRoutes.examProgress,
        pageBuilder: (context, state) {
          logger.f("${state.fullPath}");
          final args = state.extra as Map<String, dynamic>?;
          final examType = args?['examType'] as ExamType? ?? ExamType.ielts;

          return slideTransitionPage(
            context: context,
            state: state,
            child: ExamProgressPage(
              examType: examType,
            ),
          );
        },
        routes: const [],
      ),

      //? Route: '/practiceHistory'
      GoRoute(
        path: AppRoutes.practiceHistory,
        pageBuilder: (context, state) {
          logger.f("${state.fullPath}");

          return slideTransitionPage(
            context: context,
            state: state,
            child: const PracticeHistoryPage(),
          );
        },
        routes: const [],
      ),

      //? Route: '/aiTutor'
      GoRoute(
        path: AppRoutes.aiTutor,
        pageBuilder: (context, state) {
          logger.f("${state.fullPath}");
          final args = state.extra as Map<String, dynamic>?;
          final examType = args?['examType'] as ExamType? ?? ExamType.ielts;

          return slideTransitionPage(
            context: context,
            state: state,
            child: AiTutorPage(
              examType: examType,
            ),
          );
        },
        routes: const [],
      ),

      //? Route: '/mockTestExecution'
      GoRoute(
        path: AppRoutes.mockTestExecution,
        pageBuilder: (context, state) {
          logger.f("${state.fullPath}");
          final args = state.extra as Map<String, dynamic>?;
          final examType = args?['examType'] as ExamType? ?? ExamType.ielts;
          final test = args?['test'] as TestEntity;

          return slideTransitionPage(
            context: context,
            state: state,
            child: MockTestExecutionPage(
              examType: examType,
              test: test,
            ),
          );
        },
        routes: const [],
      ),

      //? Route: '/mockTestResults'
      GoRoute(
        path: AppRoutes.mockTestResults,
        pageBuilder: (context, state) {
          logger.f("${state.fullPath}");
          final args = state.extra as Map<String, dynamic>?;
          final examType = args?['examType'] as ExamType? ?? ExamType.ielts;
          final test = args?['test'] as TestEntity;
          final attemptId = args?['attemptId'] as String? ?? '';
          final results = args?['results'] as Map<String, dynamic>? ?? {};

          return slideTransitionPage(
            context: context,
            state: state,
            child: MockTestResultsPage(
              examType: examType,
              test: test,
              attemptId: attemptId,
              results: results, // ✅ Pass results
            ),
          );
        },
        routes: const [],
      ),

      //? Route: '/main'
      GoRoute(
        path: AppRoutes.main,
        builder: (context, state) {
          return const MainPage();
        },
        routes: [
          //? Route: '/main/home'
          GoRoute(
            path: "home",
            builder: (context, state) {
              logger.f(state.fullPath);
              return const HomePage();
            },
            routes: const [],
          ),
          //? Route: '/main/search'
          GoRoute(
            path: "search",
            builder: (context, state) {
              logger.f(state.fullPath);
              return const SearchPage();
            },
            routes: const [],
          ),
          //? Route: '/main/activity'
          GoRoute(
            path: "activity",
            builder: (context, state) {
              logger.f(state.fullPath);
              return const ActivityPage();
            },
            routes: const [],
          ),
          //? Route: '/main/profile'
          GoRoute(
            path: "profile",
            builder: (context, state) {
              logger.f(state.fullPath);
              return const ProfilePage();
            },
            routes: const [],
          ),
        ],
      ),
    ],
  );
}

CustomTransitionPage slideTransitionPage<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, _, child) {
      return SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeIn)),
        ),
        child: child,
      );
    },
  );
}

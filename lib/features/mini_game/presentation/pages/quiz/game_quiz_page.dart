// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../../app/constants/app_const.dart';
import '../../../../../app/constants/gen/assets.gen.dart';
import '../../../../../app/managers/navigation.dart';
import '../../../../../app/routes/route_manager.dart';
import '../../../../../app/themes/app_color.dart';
import '../../../../../app/themes/app_text_theme.dart';
import '../../../../../app/translations/translations.dart';
import '../../../../../app/widgets/select_option_tile.dart';
import '../../../../../app/widgets/timer_count_down.dart';
import '../../../../../app/widgets/widgets.dart';
import '../../../../../core/extensions/build_context.dart';
import '../../../../../core/extensions/color.dart';
import '../../../../../injection_container.dart';
import '../../../../authentication/presentation/blocs/auth/auth_bloc.dart';
import '../../../../word/domain/entities/word_entity.dart';
import '../../../../word/presentation/cubits/word_progress/word_progress_cubit.dart';
import '../../../domain/entities/quiz_entity.dart';
import '../../../domain/entities/quiz_type.dart';
import '../../cubits/quiz/game_quiz_cubit.dart';

class GameQuizPage extends StatefulWidget {
  const GameQuizPage({
    super.key,
    required this.words,
    this.quizType = QuizType.meaningToWord,
  });

  final List<WordEntity> words;
  final QuizType quizType;

  @override
  State<GameQuizPage> createState() => _GameQuizPageState();
}

class _GameQuizPageState extends State<GameQuizPage> {
  final ValueNotifier<int> currentQuestion = ValueNotifier(0);
  final ValueNotifier<int> selectedIndex = ValueNotifier(-1);
  late List<QuizEntity> quizs;
  late int timeDuration;
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
    timeDuration = AppValueConst.timeForQuiz * widget.words.length;
    
    // Generate quizzes based on selected type
    quizs = QuizEntity.generateQuizzes(
      type: widget.quizType,
      words: widget.words,
    );
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  _onCompleteQuiz(BuildContext context) async {
    final correct =
        quizs.where((element) => element.selectedAnswer == element.word).length;
    final gold = correct ~/ AppValueConst.minWordInBagToPlay +
        (correct == quizs.length ? 2 : 0);

    final uid = context.read<AuthBloc>().state.user?.uid;
    if (uid != null) {
      // Update game points and gold
      await context.read<GameQuizCubit>().calculateResult(
            uid: uid,
            point: correct,
            gold: gold,
          );
      
      // Update word progress for SRS system
      final wordProgressCubit = context.read<WordProgressCubit>();
      for (var quiz in quizs) {
        final isCorrect = quiz.selectedAnswer == quiz.word;
        await wordProgressCubit.updateWordProgress(
          uid: uid,
          wordId: quiz.word,
          word: quiz.word,
          isCorrect: isCorrect,
        );
      }
    }
  }

  void _onNextQuiz(BuildContext context, int current) {
    if (current < quizs.length - 1) {
      if (quizs[current].selectedAnswer.isNotEmpty) {
        currentQuestion.value++;
        selectedIndex.value = -1;
      }
    } else {
      _onCompleteQuiz(context);
    }
  }

  _onBack() async {
    final res = await Navigators().showDialogWithButton(
      title: LocaleKeys.game_quit_message.tr(),
      acceptText: LocaleKeys.common_yes_ofc.tr(),
    );
    if (res != null && res) {
      Navigators().popDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) => _onBack(),
      child: BlocProvider(
        create: (_) => sl<GameQuizCubit>(),
        child: Builder(builder: (context) {
          return StatusBar(
            child: BlocBuilder<GameQuizCubit, GameQuizState>(
              builder: (context, state) {
                if (state.status == GameQuizStatus.loading) {
                  return Scaffold(
                    backgroundColor: context.colors.blue900.darken(.05),
                    body: const LoadingIndicatorPage(),
                  );
                }
                if (state.status == GameQuizStatus.error) {
                  return Scaffold(
                    backgroundColor: context.colors.blue900.darken(.05),
                    body: ErrorPage(text: state.message ?? ''),
                  );
                }
                if (state.status == GameQuizStatus.success) {
                  final correct =
                      quizs.where((e) => e.selectedAnswer == e.word).length;

                  return _buildSuccess(context, correct);
                }

                return Scaffold(
                  backgroundColor: context.colors.blue900.darken(.05),
                  appBar: _buildAppBar(context),
                  body: SingleChildScrollView(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20.w, vertical: 3.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ValueListenableBuilder(
                            valueListenable: currentQuestion,
                            builder: (context, value, _) {
                              return LinearProgressIndicator(
                                value: (value + 1) / quizs.length,
                                color: context.colors.green,
                                backgroundColor:
                                    context.colors.grey.withOpacity(.15),
                                borderRadius: BorderRadius.circular(8.r),
                                minHeight: 12.h,
                              );
                            },
                          ),
                          const Gap(height: 20),
                          _buildCardQuestionAnswer(context),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSuccess(BuildContext context, int correct) {
    final gold = correct ~/ AppValueConst.minWordInBagToPlay +
        (correct == quizs.length ? 2 : 0);
    return Scaffold(
      backgroundColor: context.colors.blue900.darken(.05),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LottieBuilder.asset(
                  Assets.jsons.trophy,
                  height: context.screenHeight / 4,
                ),
                TextCustom(
                  LocaleKeys.game_correct_answer.tr(
                    args: ["$correct/${quizs.length}"],
                  ),
                  style: context.textStyle.bodyL.white,
                ),
                const Gap(height: 15),
                TextCustom(
                  LocaleKeys.game_congrats_you_got_point.tr(),
                  style: context.textStyle.titleM.bold.white,
                  maxLines: 2,
                ),
                const Gap(height: 10),
                TextCustom(
                  LocaleKeys.user_data_point.plural(correct),
                  style: context.textStyle.headingS.bold.copyWith(
                    color: context.colors.green400,
                  ),
                ),
                if (correct ~/ AppValueConst.minWordInBagToPlay > 0) ...[
                  const Gap(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        Assets.icons.gold,
                        height: 30.h,
                        width: 30.w,
                      ),
                      const Gap(width: 5),
                      TextCustom(
                        "+$gold",
                        style: context.textStyle.bodyL.white.bold,
                      ),
                    ],
                  ),
                ],
                const Gap(height: 20),
                PushableButton(
                  onPressed: () => context.pushReplacement(
                    AppRoutes.quizSummery,
                    extra: quizs,
                  ),
                  text: LocaleKeys.game_view_result.tr(),
                ),
                const Gap(height: 20),
                PushableButton(
                  onPressed: () => context.pop(),
                  text: LocaleKeys.common_back.tr(),
                  type: PushableButtonType.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardQuestionAnswer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: context.theme.cardColor,
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: ValueListenableBuilder(
        valueListenable: currentQuestion,
        child: Row(
          children: [
            SvgPicture.asset(
              Assets.images.questionMark,
              height: 30.h,
              width: 30.w,
            ),
            const Gap(width: 8),
            Expanded(
              child: TextCustom(
                LocaleKeys.game_select_your_answer.tr(),
                style: context.textStyle.bodyS.grey,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: context.theme.primaryColor,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: TimeCountDownWidget(
                onFinish: () {
                  _onCompleteQuiz(context);
                },
                durationInSeconds: timeDuration,
                style: context.textStyle.caption.white,
              ),
            ),
          ],
        ),
        builder: (context, current, row) {
          final currentQuiz = quizs[current];
          final isListeningQuiz = currentQuiz.type == QuizType.listening;
          
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              row!,
              const Gap(height: 10),
              
              // Show listening button for listening quiz
              if (isListeningQuiz) ...[
                Center(
                  child: GestureDetector(
                    onTap: () => _speak(currentQuiz.word),
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colors.blue500,
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.blue500.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.volume_up,
                        size: 48.w,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const Gap(height: 10),
                Center(
                  child: TextCustom(
                    "Tap to listen",
                    style: context.textStyle.caption.grey,
                  ),
                ),
              ] else
                TextCustom(
                  "${currentQuiz.question}.",
                  textAlign: TextAlign.justify,
                  maxLines: 10,
                ),
              const Gap(height: 15),
              ValueListenableBuilder(
                valueListenable: selectedIndex,
                builder: (context, selected, _) {
                  return Column(
                    children: currentQuiz
                        .answers
                        .mapIndexed((index, e) => SelectOptionTileWidget(
                              onTap: () {
                                currentQuiz.selectedAnswer = e;
                                selectedIndex.value = index;
                              },
                              isSelected: currentQuiz.selectedAnswer == e ||
                                  selected == index,
                              style: context.textStyle.bodyS.bw.bold,
                              text: e.toLowerCase(),
                            ))
                        .toList(),
                  );
                },
              ),
              const Gap(height: 15),
              _buildButtons(context, current),
            ],
          );
        },
      ),
    );
  }

  Widget _buildButtons(BuildContext context, int current) {
    return SizedBox(
      width: context.screenWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20.w),
            child: current == 0
                ? const SizedBox()
                : TextButton(
                    onPressed: () {
                      currentQuestion.value--;
                      selectedIndex.value = -1;
                    },
                    child: TextCustom(
                      LocaleKeys.common_back.tr(),
                      style: context.textStyle.bodyM.bold.bw,
                    ),
                  ),
          ),
          ValueListenableBuilder(
            valueListenable: selectedIndex,
            builder: (context, selected, _) {
              return SizedBox(
                width: context.screenWidth / 3,
                child: PushableButton(
                  onPressed: () => _onNextQuiz(context, current),
                  width: context.screenWidth / 3,
                  type: quizs[current].selectedAnswer.isNotEmpty ||
                          current == quizs.length - 1
                      ? PushableButtonType.primary
                      : PushableButtonType.grey,
                  text: current == quizs.length - 1
                      ? LocaleKeys.common_done.tr()
                      : LocaleKeys.common_next.tr(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  AppBarCustom _buildAppBar(BuildContext context) {
    return AppBarCustom(
      transparent: true,
      // enablePadding: true,
      leading: BackButton(
        style: ButtonStyle(
          iconSize: WidgetStateProperty.all(24.w),
          iconColor: WidgetStateProperty.all(context.colors.white),
        ),
      ),
      title: ValueListenableBuilder(
        valueListenable: currentQuestion,
        builder: (context, value, _) {
          return TextCustom(
            LocaleKeys.game_question_th.tr(
              args: [(value + 1).toString(), quizs.length.toString()],
            ),
            style: context.textStyle.bodyM.bold.white,
            textAlign: TextAlign.center,
          );
        },
      ),
      action: Padding(
        padding: EdgeInsets.only(right: 5.w),
        child: ValueListenableBuilder(
          valueListenable: currentQuestion,
          builder: (context, value, _) {
            if (value >= quizs.length - 1) {
              return SizedBox(width: 60.w);
            }
            return TextButton(
              onPressed: () {
                currentQuestion.value++;
                selectedIndex.value = -1;
              },
              child: TextCustom(
                LocaleKeys.common_skip.tr(),
                style: context.textStyle.bodyS.white,
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ),
    );
  }
}

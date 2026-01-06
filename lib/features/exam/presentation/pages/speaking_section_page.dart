import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/services/firestore_exam_service.dart';
import '../../data/services/openai_service.dart';
import '../../utils/ielts_band_calculator.dart';

class SpeakingSectionPage extends StatefulWidget {
  final String testId;
  final Function(Map<String, dynamic>) onComplete;

  const SpeakingSectionPage({super.key, required this.testId, required this.onComplete});

  @override
  State<SpeakingSectionPage> createState() => _SpeakingSectionPageState();
}

class _SpeakingSectionPageState extends State<SpeakingSectionPage> {
  final FirestoreExamService _examService = FirestoreExamService();
  final OpenAIService _openAIService = OpenAIService();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  
  bool _isLoading = true;
  bool _isRecorderInit = false;
  bool _isSubmitting = false;
  bool _hasStartedSubmission = false; // ✅ Flag to prevent multiple submissions
  String _progressMessage = '';
  Map<String, dynamic>? _testData;
  List<Map<String, dynamic>> _parts = [];
  int _currentPartIndex = 0;
  int _currentQuestionIndex = 0;
  
  final Map<String, String> _recordings = {};
  bool _isRecording = false;
  String? _currentRecordingPath;
  
  int _preparationTime = 0;
  bool _isPreparing = false;
  bool _hasCompletedPreparation = false;

  @override
  void initState() {
    super.initState();
    _loadTest();
    _initRecorder(); // ✅ Always init recorder
  }

  Future<void> _initRecorder() async {
    try {
      final status = await Permission.microphone.request();
      if (status == PermissionStatus.granted) {
        await _recorder.openRecorder();
        setState(() => _isRecorderInit = true);
      } else {
        // Show dialog to user
        if (mounted) {
          Future.delayed(Duration(milliseconds: 500), () {
            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Microphone Permission'),
                  content: Text('Cần quyền microphone để ghi âm Speaking. Bạn có thể skip nếu không có mic.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
                  ],
                ),
              );
            }
          });
        }
      }
    } catch (e) {
      print('Mic init failed: $e');
    }
  }

  Future<void> _loadTest() async {
    try {
      final data = await _examService.getSpeakingTest(widget.testId);
      if (data != null && mounted) {
        // Parse parts and extract questions properly
        final rawParts = List<Map<String, dynamic>>.from(data['parts'] ?? []);
        final parsedParts = <Map<String, dynamic>>[];
        
        for (var part in rawParts) {
          final partNumber = part['partNumber'] ?? 0;
          final parsedPart = Map<String, dynamic>.from(part);
          
          if (partNumber == 1) {
            // Part 1: Extract questions from topics
            final topics = List<Map<String, dynamic>>.from(part['topics'] ?? []);
            final allQuestions = <String>[];
            for (var topic in topics) {
              final topicQuestions = List<String>.from(topic['questions'] ?? []);
              allQuestions.addAll(topicQuestions);
            }
            parsedPart['questions'] = allQuestions;
          } else if (partNumber == 2) {
            // Part 2: Use cueCard as single question
            final cueCard = part['cueCard'];
            parsedPart['questions'] = [cueCard];
          } else if (partNumber == 3) {
            // Part 3: Extract questions from discussionTopics
            final discussionTopics = List<Map<String, dynamic>>.from(part['discussionTopics'] ?? []);
            final allQuestions = <String>[];
            for (var topic in discussionTopics) {
              final topicQuestions = List<String>.from(topic['questions'] ?? []);
              allQuestions.addAll(topicQuestions);
            }
            parsedPart['questions'] = allQuestions;
          }
          
          parsedParts.add(parsedPart);
        }
        
        setState(() {
          _testData = data;
          _parts = parsedParts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(appBar: AppBar(title: Text('Speaking')), body: Center(child: CircularProgressIndicator()));
    if (_testData == null) return Scaffold(appBar: AppBar(title: Text('Speaking')), body: Center(child: Text('No data')));

    if (_parts.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Speaking'), backgroundColor: Colors.red[700]),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80.w, color: Colors.red[700]),
              SizedBox(height: 24.h),
              Text('No parts found in test data', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('Go Back')),
            ],
          ),
        ),
      );
    }

    // Check if we've completed all parts
    if (_currentPartIndex >= _parts.length) {
      // ✅ Only submit once using dedicated flag
      if (!_hasStartedSubmission) {
        _hasStartedSubmission = true; // Set BEFORE callback
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _submitAnswers();
          }
        });
      }
      return Scaffold(
        appBar: AppBar(title: Text('Speaking'), backgroundColor: Colors.red[700]),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              if (_progressMessage.isNotEmpty)
                Text(
                  _progressMessage,
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      );
    }

    final part = _parts[_currentPartIndex];
    final questions = List<dynamic>.from(part['questions'] ?? []);
    final isPart2 = part['partNumber'] == 2;

    // Debug log
    print('🔍 Speaking Debug: partIndex=$_currentPartIndex, questionIndex=$_currentQuestionIndex, questionsLength=${questions.length}, partNumber=${part['partNumber']}');

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Part ${part['partNumber']}')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80.w, color: Colors.red[700]),
              SizedBox(height: 24.h),
              Text('No questions in Part ${part['partNumber']}', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  if (_currentPartIndex < _parts.length - 1) {
                    setState(() {
                      _currentPartIndex++;
                      _currentQuestionIndex = 0;
                    });
                  } else {
                    _skipSpeakingSection();
                  }
                },
                child: Text(_currentPartIndex < _parts.length - 1 ? 'Skip to Next Part' : 'Skip Speaking'),
              ),
            ],
          ),
        ),
      );
    }

    if (isPart2 && questions.isNotEmpty) {
      final q = questions[0];
      return _buildPart2Screen(part, q);
    }

    if (_currentQuestionIndex >= questions.length) {
      // Auto-move to next part instead of showing complete screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _currentPartIndex++;
            _currentQuestionIndex = 0;
            _hasCompletedPreparation = false;
            if (_currentPartIndex >= _parts.length) {
              _submitAnswers();
            }
          });
        }
      });
      return Scaffold(
        appBar: AppBar(title: Text('Part ${part['partNumber']}')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[_currentQuestionIndex];
    return _buildQuestionScreen(part, question);
  }

  Widget _buildQuestionScreen(Map<String, dynamic> part, dynamic question) {
    final questionKey = 'part${part['partNumber']}_q${_currentQuestionIndex + 1}';
    final hasRecording = _recordings.containsKey(questionKey);

    return Scaffold(
      appBar: AppBar(
        title: Text('Part ${part['partNumber']} - Question ${_currentQuestionIndex + 1}'),
        backgroundColor: Colors.red[700],
        actions: [
          TextButton.icon(
            onPressed: _skipSpeakingSection,
            icon: Icon(Icons.skip_next, color: Colors.white),
            label: Text('Skip (No Mic)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.red[700]!, Colors.red[500]!]), borderRadius: BorderRadius.circular(16.r)),
                child: Column(children: [Icon(Icons.mic, size: 60.w, color: Colors.white), SizedBox(height: 16.h), Text(part['title'] ?? 'Part ${part['partNumber']}', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white)), SizedBox(height: 8.h), Text(part['instruction'] ?? '', style: TextStyle(fontSize: 14.sp, color: Colors.white70), textAlign: TextAlign.center)]),
              ),
              SizedBox(height: 32.h),
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.grey[300]!, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5))]),
                child: Column(children: [Icon(Icons.question_answer, size: 48.w, color: Colors.red[700]), SizedBox(height: 20.h), Text(question is String ? question : question['question'] ?? '', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, height: 1.6), textAlign: TextAlign.center)]),
              ),
              SizedBox(height: 32.h),
              _buildRecordingControls(questionKey, hasRecording),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(hasRecording),
    );
  }

  Widget _buildPart2Screen(Map<String, dynamic> part, dynamic cueCard) {
    final questionKey = 'part2_cuecard';
    final hasRecording = _recordings.containsKey(questionKey);

    return Scaffold(
      appBar: AppBar(title: Text('Part 2 - Cue Card'), backgroundColor: Colors.red[700]),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.amber[300]!, width: 2)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(Icons.note_alt, color: Colors.amber[900]), SizedBox(width: 12.w), Text('Cue Card', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.amber[900]))]), SizedBox(height: 16.h), Text(cueCard is String ? cueCard : cueCard['topic'] ?? '', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, height: 1.6)), if (cueCard is Map && cueCard['bulletPoints'] != null) ...[SizedBox(height: 16.h), ...List.from(cueCard['bulletPoints']).map((b) => Padding(padding: EdgeInsets.only(bottom: 8.h), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('• ', style: TextStyle(fontSize: 16.sp)), Expanded(child: Text(b, style: TextStyle(fontSize: 15.sp)))])))], SizedBox(height: 16.h), Container(padding: EdgeInsets.all(12.w), decoration: BoxDecoration(color: Colors.amber[100], borderRadius: BorderRadius.circular(8.r)), child: Text('You have 1 minute to prepare and make notes. Then speak for 1-2 minutes.', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.amber[900])))]),
              ),
              SizedBox(height: 32.h),
              if (!_hasCompletedPreparation && !hasRecording) 
                ElevatedButton.icon(
                  onPressed: _startPreparation, 
                  icon: Icon(Icons.timer), 
                  label: Text('Start Preparation (1 min)'), 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700], 
                    padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h), 
                    textStyle: TextStyle(fontSize: 16.sp)
                  )
                )
              else if (_isPreparing) 
                Container(
                  padding: EdgeInsets.all(32.w), 
                  decoration: BoxDecoration(
                    color: Colors.orange[50], 
                    borderRadius: BorderRadius.circular(16.r), 
                    border: Border.all(color: Colors.orange[300]!)
                  ), 
                  child: Column(
                    children: [
                      Text('Preparation Time', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.orange[900])), 
                      SizedBox(height: 16.h), 
                      Text('$_preparationTime', style: TextStyle(fontSize: 72.sp, fontWeight: FontWeight.bold, color: Colors.orange[700])), 
                      SizedBox(height: 8.h), 
                      Text('seconds remaining', style: TextStyle(fontSize: 14.sp, color: Colors.orange[700]))
                    ]
                  )
                )
              else 
                Column(
                  children: [
                    if (_hasCompletedPreparation && !hasRecording) ...[
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.green[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green[700]),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                '✅ Preparation xong! Giờ nói trong 1-2 phút',
                                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.green[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                    _buildRecordingControls(questionKey, hasRecording),
                  ],
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: hasRecording ? _buildBottomBar(hasRecording) : null,
    );
  }

  Widget _buildPartCompleteScreen() {
    return Scaffold(
      appBar: AppBar(title: Text('Part ${_parts[_currentPartIndex]['partNumber']} Complete')),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 100.w, color: Colors.green[700]),
              SizedBox(height: 24.h),
              Text('Part ${_parts[_currentPartIndex]['partNumber']} Complete!', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 48.h),
              ElevatedButton.icon(onPressed: () {setState(() {_currentPartIndex++; _currentQuestionIndex = 0; if (_currentPartIndex >= _parts.length) _submitAnswers();});}, icon: Icon(_currentPartIndex < _parts.length - 1 ? Icons.arrow_forward : Icons.check), label: Text(_currentPartIndex < _parts.length - 1 ? 'Next Part' : 'Submit All'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700], padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h), textStyle: TextStyle(fontSize: 16.sp))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingControls(String key, bool hasRecording) {
    if (!_isRecorderInit) {
      return Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.orange[200]!)),
        child: Column(
          children: [
            Icon(Icons.mic_off, size: 60.w, color: Colors.orange[700]),
            SizedBox(height: 16.h),
            Text('Microphone không khả dụng', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.orange[900])),
            SizedBox(height: 8.h),
            Text('Vui lòng cấp quyền microphone hoặc nhấn nút Skip', style: TextStyle(fontSize: 14.sp, color: Colors.orange[700]), textAlign: TextAlign.center),
          ],
        ),
      );
    }
    
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.red[200]!)),
      child: Column(
        children: [
          if (!_isRecording && !hasRecording) ...[
            Icon(Icons.mic_none, size: 80.w, color: Colors.red[700]),
            SizedBox(height: 16.h),
            Text('Bật mic để ghi âm câu trả lời', style: TextStyle(fontSize: 16.sp, color: Colors.red[900])),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => _startRecording(key),
              icon: Icon(Icons.fiber_manual_record, size: 24.w),
              label: Text('🎤 BẬT MIC & GHI ÂM', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
              ),
            ),
          ] else if (_isRecording) ...[
            Icon(Icons.mic, size: 80.w, color: Colors.red[700]),
            SizedBox(height: 16.h),
            Text('🔴 ĐANG GHI ÂM...', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.red[900])),
            SizedBox(height: 8.h),
            Text('Nói câu trả lời của bạn', style: TextStyle(fontSize: 14.sp, color: Colors.red[700])),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _stopRecording,
              icon: Icon(Icons.stop, size: 24.w),
              label: Text('⏹️ DỪNG GHI ÂM', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[900],
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
              ),
            ),
          ] else ...[
            Icon(Icons.check_circle, size: 80.w, color: Colors.green[700]),
            SizedBox(height: 16.h),
            Text('✅ ĐÃ LƯU GHI ÂM!', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.green[700])),
            SizedBox(height: 24.h),
            OutlinedButton.icon(
              onPressed: () => _startRecording(key),
              icon: Icon(Icons.refresh),
              label: Text('Ghi lại', style: TextStyle(fontSize: 16.sp)),
              style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool hasRecording) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, -5))]),
      child: ElevatedButton.icon(
        onPressed: hasRecording ? () {
          setState(() {
            final isPart2 = _parts[_currentPartIndex]['partNumber'] == 2;
            final questions = List<dynamic>.from(_parts[_currentPartIndex]['questions'] ?? []);
            
            if (isPart2) {
              // Part 2 only has 1 question (cue card), go directly to next part
              _currentPartIndex++;
              _currentQuestionIndex = 0;
              _hasCompletedPreparation = false;
              if (_currentPartIndex >= _parts.length) {
                _submitAnswers();
              }
            } else {
              // For Part 1 and 3, check if there are more questions
              if (_currentQuestionIndex + 1 < questions.length) {
                // Go to next question in same part
                _currentQuestionIndex++;
                _hasCompletedPreparation = false;
              } else {
                // No more questions, go to next part
                _currentPartIndex++;
                _currentQuestionIndex = 0;
                _hasCompletedPreparation = false;
                if (_currentPartIndex >= _parts.length) {
                  _submitAnswers();
                }
              }
            }
          });
        } : null, 
        icon: Icon(Icons.arrow_forward), 
        label: Text('Next Question'), 
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700], padding: EdgeInsets.symmetric(vertical: 12.h))
      ),
    );
  }

  void _startPreparation() {
    setState(() {
      _isPreparing = true; 
      _preparationTime = 60;
      _hasCompletedPreparation = false;
    });
    Future.delayed(Duration(seconds: 1), _countDown);
  }

  void _countDown() {
    if (_preparationTime > 0 && mounted) {
      setState(() => _preparationTime--);
      Future.delayed(Duration(seconds: 1), _countDown);
    } else if (mounted) {
      setState(() {
        _isPreparing = false;
        _hasCompletedPreparation = true; // ✅ Mark as completed
      });
    }
  }

  Future<void> _startRecording(String key) async {
    if (!_isRecorderInit) return;
    final dir = await getTemporaryDirectory();
    _currentRecordingPath = '${dir.path}/$key.wav';
    
    // Use lower sample rate (16kHz) to reduce file size
    // OpenAI Whisper works well with 16kHz audio
    await _recorder.startRecorder(
      toFile: _currentRecordingPath, 
      codec: Codec.pcm16WAV,
      sampleRate: 16000, // 16kHz instead of default 44.1kHz
      numChannels: 1,     // Mono instead of stereo
    );
    
    setState(() => _isRecording = true);
    print('🎤 Recording started: $key (16kHz, mono)');
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    if (_currentRecordingPath != null) {
      final key = _currentRecordingPath!.split('/').last.replaceAll('.wav', '');
      _recordings[key] = _currentRecordingPath!;
      
      // Log file size
      final file = File(_currentRecordingPath!);
      if (await file.exists()) {
        final size = await file.length();
        print('🎙️ Recording saved: $key (${(size / 1024).toStringAsFixed(2)} KB)');
      }
    }
    setState(() {_isRecording = false; _currentRecordingPath = null;});
  }

  Future<void> _submitAnswers() async {
    if (!mounted) return;
    setState(() => _isSubmitting = true);
    
    try {
      // Transcribe all recordings with progress tracking
      final transcripts = <String, String>{};
      final totalRecordings = _recordings.length;
      var currentRecording = 0;
      
      for (var entry in _recordings.entries) {
        if (!mounted) return;
        
        currentRecording++;
        if (mounted) {
          setState(() => _progressMessage = 'Đang phiên âm ${currentRecording}/$totalRecordings...');
        }
        
        try {
          final transcript = await _openAIService.transcribeAudio(entry.value);
          transcripts[entry.key] = transcript;
          
          // Delay to avoid rate limiting
          await Future.delayed(Duration(milliseconds: 500));
        } catch (e) {
          print('⚠️ Transcription error for ${entry.key}: $e');
          transcripts[entry.key] = ''; // Continue with empty transcript
        }
      }
      
      // Build question-answer pairs for detailed feedback
      final Map<String, Map<String, dynamic>> detailedFeedback = {};
      var gradedCount = 0;
      final totalQuestions = transcripts.length;
      
      // Part 1 - Individual questions
      if (_parts.isNotEmpty) {
        final part1Questions = _parts[0]['questions'] as List;
        for (var i = 0; i < part1Questions.length; i++) {
          if (!mounted) return;
          
          final questionKey = 'part1_q${i + 1}';
          final question = part1Questions[i];
          final transcript = transcripts[questionKey] ?? '';
          
          if (transcript.isNotEmpty) {
            gradedCount++;
            if (mounted) {
              setState(() => _progressMessage = 'Đang chấm câu $gradedCount/$totalQuestions...');
            }
            
            try {
              final feedback = await _openAIService.gradeSpeaking(
                transcription: transcript,
                taskPrompt: question.toString(),
                partNumber: 1,
              );
              detailedFeedback[questionKey] = {
                'question': question,
                'transcript': transcript,
                'score': IELTSBandCalculator.convertAIScoreToBand(feedback['overall_score'] ?? 5.0),
                'feedback': feedback['feedback'] ?? '',
                'strengths': feedback['strengths'] ?? [],
                'improvements': feedback['improvements'] ?? [],
              };
              
              // Delay to avoid rate limiting
              await Future.delayed(Duration(seconds: 2));
            } catch (e) {
              print('⚠️ Grading error for $questionKey: $e');
              // Continue with default score if grading fails
              detailedFeedback[questionKey] = {
                'question': question,
                'transcript': transcript,
                'score': 5.0,
                'feedback': 'Không thể chấm điểm do lỗi API',
                'strengths': [],
                'improvements': [],
              };
            }
          }
        }
      }
      
      // Part 2 - Cue card
      if (_parts.length > 1) {
        if (!mounted) return;
        
        final part2Transcript = transcripts['part2_cuecard'] ?? '';
        if (part2Transcript.isNotEmpty) {
          gradedCount++;
          if (mounted) {
            setState(() => _progressMessage = 'Đang chấm câu $gradedCount/$totalQuestions...');
          }
          
          try {
            final feedback = await _openAIService.gradeSpeaking(
              transcription: part2Transcript,
              taskPrompt: _parts[1]['questions'][0].toString(),
              partNumber: 2,
            );
            detailedFeedback['part2_cuecard'] = {
              'question': _parts[1]['questions'][0],
              'transcript': part2Transcript,
              'score': IELTSBandCalculator.convertAIScoreToBand(feedback['overall_score'] ?? 5.0),
              'feedback': feedback['feedback'] ?? '',
              'strengths': feedback['strengths'] ?? [],
              'improvements': feedback['improvements'] ?? [],
            };
            
            // Delay to avoid rate limiting
            await Future.delayed(Duration(seconds: 2));
          } catch (e) {
            print('⚠️ Grading error for part2_cuecard: $e');
            detailedFeedback['part2_cuecard'] = {
              'question': _parts[1]['questions'][0],
              'transcript': part2Transcript,
              'score': 5.0,
              'feedback': 'Không thể chấm điểm do lỗi API',
              'strengths': [],
              'improvements': [],
            };
          }
        }
      }
      
      // Part 3 - Discussion questions
      if (_parts.length > 2) {
        final part3Questions = _parts[2]['questions'] as List;
        for (var i = 0; i < part3Questions.length; i++) {
          if (!mounted) return;
          
          final questionKey = 'part3_q${i + 1}';
          final question = part3Questions[i];
          final transcript = transcripts[questionKey] ?? '';
          
          if (transcript.isNotEmpty) {
            gradedCount++;
            if (mounted) {
              setState(() => _progressMessage = 'Đang chấm câu $gradedCount/$totalQuestions...');
            }
            
            try {
              final feedback = await _openAIService.gradeSpeaking(
                transcription: transcript,
                taskPrompt: question.toString(),
                partNumber: 3,
              );
              detailedFeedback[questionKey] = {
                'question': question,
                'transcript': transcript,
                'score': IELTSBandCalculator.convertAIScoreToBand(feedback['overall_score'] ?? 5.0),
                'feedback': feedback['feedback'] ?? '',
                'strengths': feedback['strengths'] ?? [],
                'improvements': feedback['improvements'] ?? [],
              };
              
              // Delay to avoid rate limiting
              await Future.delayed(Duration(seconds: 2));
            } catch (e) {
              print('⚠️ Grading error for $questionKey: $e');
              detailedFeedback[questionKey] = {
                'question': question,
                'transcript': transcript,
                'score': 5.0,
                'feedback': 'Không thể chấm điểm do lỗi API',
                'strengths': [],
                'improvements': [],
              };
            }
          }
        }
      }
      
      // Calculate overall scores
      final part1Scores = detailedFeedback.entries.where((e) => e.key.startsWith('part1')).map((e) => e.value['score'] as double);
      final part1Score = part1Scores.isEmpty ? 5.0 : part1Scores.reduce((a, b) => a + b) / part1Scores.length;
      
      final part2Score = detailedFeedback['part2_cuecard']?['score'] ?? 5.0;
      
      final part3Scores = detailedFeedback.entries.where((e) => e.key.startsWith('part3')).map((e) => e.value['score'] as double);
      final part3Score = part3Scores.isEmpty ? 5.0 : part3Scores.reduce((a, b) => a + b) / part3Scores.length;
      
      final overallBand = IELTSBandCalculator.roundToHalfBand((part1Score + part2Score + part3Score) / 3);
      
      widget.onComplete({
        'speakingBand': overallBand,
        'speakingPart1Score': part1Score,
        'speakingPart2Score': part2Score,
        'speakingPart3Score': part3Score,
        'speakingRecordings': _recordings,
        'speakingTranscripts': transcripts,
        'speakingDetailedFeedback': detailedFeedback, // ✅ Detailed feedback per question
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi chấm điểm: $e'))
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _skipSpeakingSection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Skip Speaking Section?'),
        content: Text('Bạn sẽ nhận 5.0 band cho Speaking section. Bạn có chắc không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Return default score 5.0 for all parts
              widget.onComplete({
                'speakingBand': 5.0,
                'speakingPart1Score': 5.0,
                'speakingPart2Score': 5.0,
                'speakingPart3Score': 5.0,
                'speakingRecordings': {},
                'speakingTranscripts': {},
                'speakingFeedback': {'part1': {}, 'part2': {}, 'part3': {}},
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Skip'),
          ),
        ],
      ),
    );
  }
}

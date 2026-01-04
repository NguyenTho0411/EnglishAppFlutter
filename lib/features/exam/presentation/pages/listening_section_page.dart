import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../data/services/firestore_exam_service.dart';
import '../../utils/ielts_band_calculator.dart';

class ListeningSectionPage extends StatefulWidget {
  final String testId;
  final Function(Map<String, dynamic>) onComplete;

  const ListeningSectionPage({super.key, required this.testId, required this.onComplete});

  @override
  State<ListeningSectionPage> createState() => _ListeningSectionPageState();
}

class _ListeningSectionPageState extends State<ListeningSectionPage> {
  final FirestoreExamService _examService = FirestoreExamService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isLoading = true;
  Map<String, dynamic>? _testData;
  List<Map<String, dynamic>> _sections = [];
  int _currentSectionIndex = 0;
  final Map<String, String> _userAnswers = {};
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadTest();
    _audioPlayer.onDurationChanged.listen((d) => setState(() => _duration = d));
    _audioPlayer.onPositionChanged.listen((p) => setState(() => _position = p));
    _audioPlayer.onPlayerStateChanged.listen((s) => setState(() => _isPlaying = s == PlayerState.playing));
  }

  Future<void> _loadTest() async {
    try {
      final data = await _examService.getListeningTest(widget.testId);
      if (data != null && mounted) {
        setState(() {
          _testData = data;
          _sections = List<Map<String, dynamic>>.from(data['sections'] ?? []);
          _isLoading = false;
        });
        if (_sections.isNotEmpty && _sections[0]['audioUrl'] != null) {
          await _audioPlayer.setSourceUrl(_sections[0]['audioUrl']);
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(appBar: AppBar(title: Text('Listening')), body: Center(child: CircularProgressIndicator()));
    if (_testData == null) return Scaffold(appBar: AppBar(title: Text('Listening')), body: Center(child: Text('No data')));

    final section = _sections[_currentSectionIndex];
    final questions = List<Map<String, dynamic>>.from(section['questions'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text('Listening Section'),
        actions: [Padding(padding: EdgeInsets.only(right: 16.w), child: Center(child: Text('Section ${_currentSectionIndex + 1}/${_sections.length}')))],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAudioPlayer(section),
            Divider(height: 1, thickness: 2),
            Container(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.amber[200]!)),
                    child: Row(children: [Icon(Icons.warning_amber, color: Colors.amber[900]), SizedBox(width: 12.w), Expanded(child: Text(section['instruction'] ?? 'Listen and answer', style: TextStyle(color: Colors.amber[900], fontWeight: FontWeight.w500)))]),
                  ),
                  SizedBox(height: 24.h),
                  Text(section['title'] ?? 'Section ${section['sectionNumber']}', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20.h),
                  ...questions.map((q) => _buildQuestion(q)).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAudioPlayer(Map<String, dynamic> section) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.purple[700]!, Colors.purple[500]!])),
      child: Column(
        children: [
          Icon(Icons.headphones, size: 48.w, color: Colors.white),
          SizedBox(height: 16.h),
          Text(section['title'] ?? 'Audio', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 24.h),
          Slider(
            value: _position.inSeconds.toDouble(),
            max: _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1,
            onChanged: (v) => _audioPlayer.seek(Duration(seconds: v.toInt())),
            activeColor: Colors.white,
            inactiveColor: Colors.white38,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_formatTime(_position), style: TextStyle(color: Colors.white)), Text(_formatTime(_duration), style: TextStyle(color: Colors.white))]),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: () => _audioPlayer.seek(_position - Duration(seconds: 10)), icon: Icon(Icons.replay_10, color: Colors.white), iconSize: 32.w),
              SizedBox(width: 24.w),
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: IconButton(onPressed: () => _isPlaying ? _audioPlayer.pause() : _audioPlayer.resume(), icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.purple[700]), iconSize: 36.w),
              ),
              SizedBox(width: 24.w),
              IconButton(onPressed: () => _audioPlayer.seek(_position + Duration(seconds: 10)), icon: Icon(Icons.forward_10, color: Colors.white), iconSize: 32.w),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(Duration d) => '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  Widget _buildQuestion(Map<String, dynamic> q) {
    final id = q['id'] ?? q['questionNumber']?.toString() ?? '';
    final type = q['type'] ?? 'multipleChoice';
    final answer = _userAnswers[id];
    
    if (type.contains('Completion') || type.contains('form')) {
      final controller = TextEditingController(text: answer);
      return Container(
        margin: EdgeInsets.only(bottom: 20.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12.r)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(width: 28.w, height: 28.w, decoration: BoxDecoration(color: Colors.purple[700], shape: BoxShape.circle), child: Center(child: Text('${q['questionNumber']}', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)))),
              SizedBox(width: 12.w),
              Expanded(child: Text(q['question'] ?? '', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600))),
            ]),
            SizedBox(height: 12.h),
            TextField(controller: controller, decoration: InputDecoration(hintText: 'Your answer...', border: OutlineInputBorder()), onChanged: (v) => _userAnswers[id] = v.trim()),
          ],
        ),
      );
    }
    
    final options = List<dynamic>.from(q['options'] ?? ['A', 'B', 'C']);
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12.r), color: answer != null ? Colors.purple[50] : Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 28.w, height: 28.w, decoration: BoxDecoration(color: Colors.purple[700], shape: BoxShape.circle), child: Center(child: Text('${q['questionNumber']}', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)))),
            SizedBox(width: 12.w),
            Expanded(child: Text(q['question'] ?? '', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600))),
          ]),
          SizedBox(height: 12.h),
          ...options.asMap().entries.map((e) {
            final letter = String.fromCharCode(65 + e.key);
            final selected = answer == letter;
            return GestureDetector(
              onTap: () => setState(() => _userAnswers[id] = letter),
              child: Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(color: selected ? Colors.purple[700] : Colors.white, border: Border.all(color: selected ? Colors.purple[700]! : Colors.grey[300]!, width: 2), borderRadius: BorderRadius.circular(8.r)),
                child: Row(children: [
                  Container(width: 24.w, height: 24.w, decoration: BoxDecoration(color: selected ? Colors.white : Colors.grey[100], shape: BoxShape.circle), child: Center(child: Text(letter, style: TextStyle(color: selected ? Colors.purple[700] : Colors.black, fontSize: 12.sp, fontWeight: FontWeight.bold)))),
                  SizedBox(width: 12.w),
                  Expanded(child: Text(e.value.toString(), style: TextStyle(fontSize: 14.sp, color: selected ? Colors.white : Colors.black87))),
                ]),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final total = _sections.fold<int>(0, (s, sec) => s + (sec['questions'] as List).length);
    final answered = _userAnswers.length;
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, -5))]),
      child: Row(
        children: [
          Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Progress: $answered/$total', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)), SizedBox(height: 8.h), LinearProgressIndicator(value: answered / total, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation(Colors.purple[700]!), minHeight: 8.h)])),
          SizedBox(width: 16.w),
          if (_currentSectionIndex > 0) ...[OutlinedButton(onPressed: () async {setState(() => _currentSectionIndex--); if (_sections[_currentSectionIndex]['audioUrl'] != null) await _audioPlayer.setSourceUrl(_sections[_currentSectionIndex]['audioUrl']);}, child: Text('Previous')), SizedBox(width: 12.w)],
          ElevatedButton.icon(
            onPressed: () async {
              if (_currentSectionIndex < _sections.length - 1) {
                setState(() => _currentSectionIndex++);
                if (_sections[_currentSectionIndex]['audioUrl'] != null) await _audioPlayer.setSourceUrl(_sections[_currentSectionIndex]['audioUrl']);
              } else _submitAnswers();
            },
            icon: Icon(_currentSectionIndex < _sections.length - 1 ? Icons.arrow_forward : Icons.check),
            label: Text(_currentSectionIndex < _sections.length - 1 ? 'Next' : 'Submit'),
            style: ElevatedButton.styleFrom(backgroundColor: _currentSectionIndex < _sections.length - 1 ? Colors.purple[700] : Colors.green[700]),
          ),
        ],
      ),
    );
  }

  void _submitAnswers() {
    int correct = 0, total = 0;
    final Map<String, String> correctAnswers = {};
    final Map<String, String> questionTexts = {};
    
    for (var sec in _sections) {
      final qs = List<Map<String, dynamic>>.from(sec['questions'] ?? []);
      total += qs.length;
      for (var q in qs) {
        final id = q['id'] ?? q['questionNumber']?.toString() ?? '';
        final correctAnswer = q['correctAnswer']?.toString().toUpperCase() ?? '';
        
        // Store correct answer and question text
        correctAnswers[id] = correctAnswer;
        questionTexts[id] = q['question']?.toString() ?? '';
        
        if (_userAnswers[id]?.toUpperCase() == correctAnswer) correct++;
      }
    }
    
    widget.onComplete({
      'listeningBand': IELTSBandCalculator.calculateBandScore(correct, total),
      'listeningCorrect': correct,
      'listeningTotal': total,
      'listeningAnswers': _userAnswers,
      'listeningCorrectAnswers': correctAnswers, // ✅ Add correct answers
      'listeningQuestions': questionTexts, // ✅ Add question texts
    });
  }
}

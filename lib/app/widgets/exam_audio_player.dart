import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class ExamAudioPlayer extends StatefulWidget {
  final String audioUrl;
  final bool autoPlay;

  const ExamAudioPlayer({
    super.key,
    required this.audioUrl,
    this.autoPlay = false,
  });

  @override
  State<ExamAudioPlayer> createState() => _ExamAudioPlayerState();
}

class _ExamAudioPlayerState extends State<ExamAudioPlayer> {
  late AudioPlayer _player;
  PlayerState _playerState = PlayerState.stopped;
  
  // Thời lượng
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Trạng thái kéo thanh trượt (để tránh xung đột khi audio đang chạy)
  bool _isDragging = false; 
  double _dragValue = 0.0;
  
  // Trạng thái loading
  bool _isLoading = true;

  // Stream subscriptions để hủy khi thoát
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _player = AudioPlayer();

    // 1. Lắng nghe trạng thái (Playing/Paused/Stopped)
    _playerStateChangeSubscription = _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playerState = state);
    });

    // 2. Lắng nghe tổng thời lượng (Khi file load xong metadata)
    _durationSubscription = _player.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
          _isLoading = false; // Có duration nghĩa là đã load xong cơ bản
        });
      }
    });

    // 3. Lắng nghe vị trí hiện tại (Cập nhật liên tục khi chạy)
    _positionSubscription = _player.onPositionChanged.listen((newPosition) {
      // Chỉ cập nhật UI nếu người dùng KHÔNG đang kéo thanh trượt
      if (!_isDragging && mounted) {
        setState(() => _position = newPosition);
      }
    });

    // 4. Xử lý khi chạy hết bài -> Reset về 0
    _playerCompleteSubscription = _player.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _playerState = PlayerState.stopped;
          _position = Duration.zero;
        });
      }
    });

    // 5. Load Source
    try {
      await _player.setSource(UrlSource(widget.audioUrl));
      if (widget.autoPlay) {
        await _player.resume();
      }
    } catch (e) {
      print("Error loading audio: $e");
      if (mounted) setState(() => _isLoading = false); // Tắt loading dù lỗi
    }
  }

  @override
  void dispose() {
    // Hủy các luồng lắng nghe và player để tránh rò rỉ bộ nhớ
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  // Hàm format thời gian: 125s -> 02:05
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _playerState == PlayerState.playing;
    
    // Giá trị slider: Nếu đang kéo thì lấy giá trị kéo, không thì lấy vị trí thực
    final sliderValue = _isDragging 
        ? _dragValue 
        : _position.inSeconds.toDouble().clamp(0.0, _duration.inSeconds.toDouble());
    
    final maxSliderValue = _duration.inSeconds.toDouble();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Nút Play/Pause
              _isLoading
                  ? const SizedBox(
                      width: 48,
                      height: 48,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        color: Theme.of(context).primaryColor,
                      ),
                      iconSize: 48,
                      onPressed: () async {
                        if (isPlaying) {
                          await _player.pause();
                        } else {
                          await _player.resume();
                        }
                      },
                    ),
              
              const SizedBox(width: 8),

              // Phần Seeker (Thanh trượt + Thời gian)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thanh Slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4.0,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
                        activeTrackColor: Theme.of(context).primaryColor,
                        inactiveTrackColor: Colors.grey.shade300,
                        thumbColor: Theme.of(context).primaryColor,
                      ),
                      child: Slider(
                        min: 0.0,
                        max: maxSliderValue > 0 ? maxSliderValue : 1.0, // Tránh lỗi chia cho 0
                        value: sliderValue,
                        onChanged: (value) {
                          // Khi người dùng bắt đầu kéo:
                          // 1. Đánh dấu đang kéo để chặn stream cập nhật UI
                          // 2. Cập nhật UI theo ngón tay người dùng ngay lập tức
                          setState(() {
                            _isDragging = true;
                            _dragValue = value;
                          });
                        },
                        onChangeEnd: (value) async {
                          // Khi người dùng thả tay ra:
                          // 1. Tua đến vị trí mới
                          await _player.seek(Duration(seconds: value.toInt()));
                          // 2. Cho phép stream cập nhật lại bình thường
                          setState(() {
                            _isDragging = false;
                          });
                          // 3. Nếu đang pause thì tự play (tùy chọn UX)
                          if (!_isLoading && !isPlaying) {
                             await _player.resume();
                          }
                        },
                      ),
                    ),
                    
                    // Thời gian: 00:15 / 02:30
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_isDragging ? Duration(seconds: _dragValue.toInt()) : _position),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
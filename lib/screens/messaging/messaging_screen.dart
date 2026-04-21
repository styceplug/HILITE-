import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/routes/routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../controllers/chat_controller.dart';
import '../../models/message_model.dart';
import 'package:file_picker/file_picker.dart';

import '../../utils/app_constants.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key, required this.myId, required this.chat});

  final String myId;
  final Chat chat;

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen>
    with WidgetsBindingObserver {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _picker = ImagePicker();

  late final ChatController ctrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ctrl = Get.find<ChatController>();
    ctrl.initChat(chat: widget.chat, myId: widget.myId);
    _scrollCtrl.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ctrl.closeChat();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    unawaited(_AudioMessagePlaybackCoordinator.stopActive());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      unawaited(_AudioMessagePlaybackCoordinator.stopActive());
    }
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels <= 60 &&
        ctrl.hasMore &&
        !ctrl.isLoading.value) {
      ctrl.loadMessages(loadMore: true);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage() async {
    final xfile = await _picker.pickImage(source: ImageSource.gallery);
    if (xfile == null) return;

    await ctrl.sendImage(File(xfile.path));
    _scrollToBottom();
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'ogg', 'webm', 'm4a'],
    );

    if (result == null || result.files.single.path == null) return;

    await ctrl.sendAudio(File(result.files.single.path!));
    _scrollToBottom();
  }

  Future<void> _sendText() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    _textCtrl.clear();
    await ctrl.sendText(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final peer = ctrl.chat.peer(widget.myId);
    final presence = peer != null ? ctrl.presenceMap[peer.id] : null;

    return Scaffold(
      // FIX 1: White background so SafeAreas match the header and input bar seamlessly
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _ChatHeader(peer: peer, myId: widget.myId, presence: presence),
            Expanded(
              // The grey background is now strictly applied to the chat list area
              child: Container(
                color: const Color(0xFFF0F2F5),
                child: _MessageList(
                  ctrl: ctrl,
                  myId: widget.myId,
                  scrollCtrl: _scrollCtrl,
                ),
              ),
            ),
            _InputBar(
              textCtrl: _textCtrl,
              ctrl: ctrl,
              onSend: _sendText,
              onPickImage: _pickImage,
              onPickAudio: _pickAudio,
              onTyping: ctrl.notifyTyping,
              onAudioRecorded: (path) async {
                await ctrl.sendAudio(File(path));
                _scrollToBottom();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.peer,
    required this.myId,
    required this.presence,
  });

  final ChatParticipant? peer;
  final String myId;
  final UserPresence? presence;

  @override
  Widget build(BuildContext context) {
    final rawName = peer?.displayName?.trim() ?? '';
    final displayName = rawName.isNotEmpty ? rawName : 'User';
    final avatarLetter =
    rawName.isNotEmpty ? rawName.characters.first.toUpperCase() : '?';

    final hasImage = (peer?.profilePicture?.trim().isNotEmpty ?? false);
    final isOnline = presence?.isOnline ?? false;
    final lastSeen = presence?.lastSeen ?? peer?.lastSeen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Get.back(),
            splashRadius: 24,
          ),
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage:
                hasImage ? NetworkImage(peer!.profilePicture!) : null,
                backgroundColor: const Color(0xFFE5E7EB),
                child: !hasImage
                    ? Text(
                  avatarLetter,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B5563),
                  ),
                )
                    : null,
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () {
                unawaited(_AudioMessagePlaybackCoordinator.stopActive());
                Get.toNamed(
                  AppRoutes.othersProfileScreen,
                  arguments: {'targetId': peer?.id},
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isOnline ? 'Online' : _formatLastSeen(lastSeen),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isOnline ? const Color(0xFF22C55E) : const Color(0xFF6B7280),
                      fontWeight: isOnline ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastSeen(DateTime? dt) {
    if (dt == null) return 'Offline';

    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Last seen just now';
    if (diff.inMinutes < 60) return 'Last seen ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Last seen ${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Last seen yesterday';

    return 'Last seen ${DateFormat('MMM d, HH:mm').format(dt)}';
  }
}

// ─── Message list ─────────────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.ctrl,
    required this.myId,
    required this.scrollCtrl,
  });

  final ChatController ctrl;
  final String myId;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final msgs = ctrl.messages;
      final groups = _groupByDate(msgs);

      return ListView.builder(
        controller: scrollCtrl,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount:
        groups.length +
            (ctrl.peerIsTyping.value ? 1 : 0) +
            (ctrl.isLoading.value ? 1 : 0),
        itemBuilder: (_, i) {
          if (ctrl.isLoading.value && i == 0) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final adjustedI = ctrl.isLoading.value ? i - 1 : i;

          if (ctrl.peerIsTyping.value && adjustedI == groups.length) {
            return const Align(
              alignment: Alignment.centerLeft,
              child: _TypingBubble(),
            );
          }

          if (adjustedI < 0 || adjustedI >= groups.length) {
            return const SizedBox();
          }

          final group = groups[adjustedI];
          return Column(
            children: [
              _DateLabel(label: group.label),
              ...group.messages.map((msg) {
                final mine = msg.sender.id == myId;
                final allRead = mine && msg.readBy.any((id) => id != myId);

                return _MessageBubble(
                  msg: msg,
                  mine: mine,
                  allRead: allRead,
                  onLongPress: () => _showDeleteSheet(context, msg.id),
                );
              }),
            ],
          );
        },
      );
    });
  }

  void _showDeleteSheet(BuildContext context, String msgId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.red),
                ),
                title: const Text(
                  'Delete message',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ctrl.deleteMessage(msgId);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<({String label, List<ChatMessage> messages})> _groupByDate(
      List<ChatMessage> msgs,
      ) {
    final map = <String, List<ChatMessage>>{};

    for (final m in msgs) {
      final now = DateTime.now();
      final d = m.createdAt;

      final String label;
      if (_isSameDay(d, now)) {
        label = 'Today';
      } else if (_isSameDay(d, now.subtract(const Duration(days: 1)))) {
        label = 'Yesterday';
      } else {
        label = DateFormat('MMM d, yyyy').format(d);
      }

      map.putIfAbsent(label, () => []).add(m);
    }

    return map.entries.map((e) => (label: e.key, messages: e.value)).toList();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DateLabel extends StatelessWidget {
  const _DateLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.msg,
    required this.mine,
    required this.allRead,
    required this.onLongPress,
  });

  final ChatMessage msg;
  final bool mine;
  final bool allRead;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final isAudio = msg.type == 'audio';

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * (isAudio ? 0.80 : 0.75),
          ),
          decoration: BoxDecoration(
            color: mine ? const Color(0xFF007AFF) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: mine ? const Radius.circular(20) : const Radius.circular(4),
              bottomRight: mine ? const Radius.circular(4) : const Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(isAudio ? 4 : 12),
            child: Column(
              crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildContent(context),
                if (!isAudio) const SizedBox(height: 4),
                if (!isAudio)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(msg.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: mine ? Colors.white.withOpacity(0.8) : const Color(0xFF9CA3AF),
                        ),
                      ),
                      if (mine) ...[
                        const SizedBox(width: 4),
                        Icon(
                          allRead ? Icons.done_all_rounded : Icons.check_rounded,
                          size: 16,
                          color: allRead ? Colors.white : Colors.white.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final imageUrl = MediaUrlHelper.resolve(msg.image?.url);
    final audioUrl = MediaUrlHelper.resolve(msg.audio?.url);

    switch (msg.type) {
      case 'image':
        if (imageUrl == null) {
          return const SizedBox(
            width: 200, height: 120,
            child: Center(child: Icon(Icons.broken_image)),
          );
        }
        return GestureDetector(
          onTap: () {
            unawaited(_AudioMessagePlaybackCoordinator.stopActive());
            Get.to(() => _FullScreenImageViewer(imageUrl: imageUrl));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(
                width: 200, height: 120,
                child: Center(child: Icon(Icons.broken_image)),
              ),
            ),
          ),
        );

      case 'audio':
        if (audioUrl == null) {
          return Text('Audio unavailable', style: TextStyle(color: mine ? Colors.white : Colors.black));
        }
        return _AudioMessagePlayer(
          url: audioUrl,
          mine: mine,
          timestamp: msg.createdAt,
          isRead: allRead,
        );

      default:
        return Text(
          msg.text ?? '',
          style: TextStyle(
            fontSize: 15,
            color: mine ? Colors.white : const Color(0xFF1F2937),
            height: 1.3,
          ),
        );
    }
  }
}

// ─── Interactive Input Bar ───────────────────────────────────────────────────

class _InputBar extends StatefulWidget {
  const _InputBar({
    required this.textCtrl,
    required this.ctrl,
    required this.onSend,
    required this.onPickImage,
    required this.onPickAudio,
    required this.onTyping,
    required this.onAudioRecorded,
  });

  final TextEditingController textCtrl;
  final ChatController ctrl;
  final VoidCallback onSend;
  final VoidCallback onPickImage;
  final VoidCallback onPickAudio;
  final VoidCallback onTyping;
  final Function(String) onAudioRecorded;

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> with SingleTickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  int _recordDuration = 0;
  Timer? _timer;

  bool get _isTyping => widget.textCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    widget.textCtrl.addListener(() {
      setState(() {}); // Trigger rebuild to toggle Send/Mic icon
    });
  }

  void _startTimer() {
    _recordDuration = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100),
          path: path,
        );
        setState(() => _isRecording = true);
        _startTimer();
      } else {
        Get.snackbar('Permission denied', 'Microphone permission is required');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to start recording');
    }
  }

  Future<void> _stopRecording(bool send) async {
    _timer?.cancel();
    try {
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);
      if (send && path != null && _recordDuration > 0) {
        widget.onAudioRecorded(path);
      }
    } catch (e) {
      setState(() => _isRecording = false);
    }
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!_isRecording) ...[
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF6B7280), size: 28),
              splashRadius: 24,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _AttachmentMenu(
                    onPickImage: widget.onPickImage,
                    onPickAudio: widget.onPickAudio,
                  ),
                );
              },
            ),
            Expanded(
              child: TextField(
                controller: widget.textCtrl,
                onChanged: (_) => widget.onTyping(),
                maxLines: 5,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ] else ...[
            // Recording Active State UI
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const _BlinkingDot(),
                    const SizedBox(width: 8),
                    Text(
                      _formatDuration(_recordDuration),
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Spacer(),
                    const Text('Slide to cancel', style: TextStyle(color: Colors.grey)),
                    const Icon(Icons.chevron_left_rounded, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(width: 8),

          // Send / Record Button
          GestureDetector(
            onLongPress: _isTyping ? null : _startRecording,
            onLongPressEnd: _isTyping ? null : (details) {
              // Basic slide to cancel logic
              if (details.localPosition.dx < -50) {
                _stopRecording(false); // Cancel
              } else {
                _stopRecording(true); // Send
              }
            },
            onTap: _isTyping ? widget.onSend : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isRecording ? Colors.red : const Color(0xFF007AFF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording ? Colors.red : const Color(0xFF007AFF)).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Obx(() => widget.ctrl.isSending.value
                  ? const Padding(
                padding: EdgeInsets.all(14),
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : Icon(
                _isTyping ? Icons.send_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 24,
              )),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlinkingDot extends StatefulWidget {
  const _BlinkingDot();
  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}
class _BlinkingDotState extends State<_BlinkingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
    );
  }
}

// ─── Pro Audio Player ─────────────────────────────────────────────────────────

class _AudioMessagePlayer extends StatefulWidget {
  const _AudioMessagePlayer({required this.url, required this.mine, required this.timestamp, required this.isRead});

  final String url;
  final bool mine;
  final DateTime timestamp;
  final bool isRead;

  @override
  State<_AudioMessagePlayer> createState() => _AudioMessagePlayerState();
}

class _AudioMessagePlayerState extends State<_AudioMessagePlayer> {
  late final AudioPlayer _player;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.setUrl(widget.url).catchError((_) {});

    // Listen for completion to automatically reset the player
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _handlePlaybackCompleted();
      }
    });
  }

  Future<void> _handlePlaybackCompleted() async {
    try {
      await _player.pause();
      await _player.seek(Duration.zero);
      await _AudioMessagePlaybackCoordinator.release(_player);
    } catch (_) {}
    if (mounted) setState(() {});
  }

  String _formatDuration(Duration? d) {
    if (d == null) return "0:00";
    final min = d.inMinutes.remainder(60);
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$min:$sec";
  }

  Future<void> _togglePlay() async {
    if (_loading) return;
    try {
      // FIX 2: Better logic check to see if we should pause or play
      if (_player.playing && _player.processingState != ProcessingState.completed) {
        await _player.pause();
      } else {
        if (_player.processingState == ProcessingState.completed) {
          await _player.seek(Duration.zero);
        }
        await _AudioMessagePlaybackCoordinator.activate(_player);
        await _player.play();
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not play audio message');
    }
  }

  @override
  void dispose() {
    unawaited(_AudioMessagePlaybackCoordinator.release(_player));
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.mine ? Colors.white : const Color(0xFF007AFF);

    return Container(
      width: 250,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          StreamBuilder<PlayerState>(
            stream: _player.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing ?? false;

              // Only consider it "active playing" if it hasn't hit the end
              final isPlayingActive = playing && processingState != ProcessingState.completed;

              if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  width: 32.0, height: 32.0,
                  child: CircularProgressIndicator(color: color, strokeWidth: 3),
                );
              }
              return IconButton(
                icon: Icon(isPlayingActive ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded),
                iconSize: 44,
                color: color,
                onPressed: _togglePlay,
                padding: EdgeInsets.zero,
              );
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder<Duration>(
                  stream: _player.positionStream,
                  builder: (context, posSnap) {
                    final position = posSnap.data ?? Duration.zero;
                    return StreamBuilder<Duration?>(
                      stream: _player.durationStream,
                      builder: (context, durSnap) {
                        final duration = durSnap.data ?? Duration.zero;
                        return SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3.0,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
                            activeTrackColor: color,
                            inactiveTrackColor: color.withOpacity(0.3),
                            thumbColor: color,
                          ),
                          child: Slider(
                            min: 0.0,
                            max: duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1.0,
                            value: position.inMilliseconds.toDouble().clamp(0.0, duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1.0),
                            onChanged: (value) {
                              _player.seek(Duration(milliseconds: value.round()));
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StreamBuilder<Duration>(
                        stream: _player.positionStream,
                        builder: (_, snap) => Text(
                          _formatDuration(snap.data),
                          style: TextStyle(fontSize: 11, color: color.withOpacity(0.8)),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            DateFormat('HH:mm').format(widget.timestamp),
                            style: TextStyle(fontSize: 11, color: color.withOpacity(0.8)),
                          ),
                          if (widget.mine) ...[
                            const SizedBox(width: 4),
                            Icon(
                              widget.isRead ? Icons.done_all_rounded : Icons.check_rounded,
                              size: 14,
                              color: widget.isRead ? (color == Colors.white ? Colors.white : const Color(0xFF34B7F1)) : color.withOpacity(0.6),
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
        ],
      ),
    );
  }
}

// ─── Attachments Bottom Sheet ─────────────────────────────────────────────────

class _AttachmentMenu extends StatelessWidget {
  final VoidCallback onPickImage;
  final VoidCallback onPickAudio;

  const _AttachmentMenu({required this.onPickImage, required this.onPickAudio});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AttachmentIcon(
                icon: Icons.image_rounded,
                color: Colors.purple,
                label: 'Gallery',
                onTap: () { Navigator.pop(context); onPickImage(); },
              ),
              _AttachmentIcon(
                icon: Icons.audio_file_rounded,
                color: Colors.orange,
                label: 'Audio',
                onTap: () { Navigator.pop(context); onPickAudio(); },
              ),
              _AttachmentIcon(
                icon: Icons.description_rounded,
                color: Colors.blue,
                label: 'Document',
                onTap: () { Navigator.pop(context); /* Implement if needed */ },
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _AttachmentIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _AttachmentIcon({required this.icon, required this.color, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF4B5563))),
        ],
      ),
    );
  }
}

// Keep existing helpers (_TypingBubble, _Dot, MediaUrlHelper, _FullScreenImageViewer, _AudioMessagePlaybackCoordinator)
class _TypingBubble extends StatelessWidget {
  const _TypingBubble();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(4),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Dot(delay: 0), SizedBox(width: 4), _Dot(delay: 200), SizedBox(width: 4), _Dot(delay: 400),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  const _Dot({required this.delay});
  final int delay;
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0, end: -5).animate(CurvedAnimation(parent: _ac, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () { if (mounted) _ac.forward(); });
  }
  @override
  void dispose() { _ac.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF9CA3AF), shape: BoxShape.circle)),
      ),
    );
  }
}

class MediaUrlHelper {
  static String? resolve(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) return trimmed;
    return '${AppConstants.SOCKET_BASE_URL}$trimmed';
  }
}

class _FullScreenImageViewer extends StatelessWidget {
  const _FullScreenImageViewer({required this.imageUrl});
  final String imageUrl;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(child: InteractiveViewer(child: Image.network(imageUrl, fit: BoxFit.contain))),
    );
  }
}

class _AudioMessagePlaybackCoordinator {
  static AudioPlayer? _activePlayer;
  static Future<void> _resetPlayer(AudioPlayer player) async {
    try { if (player.playing) await player.pause(); } catch (_) {}
    try { await player.seek(Duration.zero); } catch (_) {}
  }
  static Future<void> activate(AudioPlayer player) async {
    if (identical(_activePlayer, player)) return;
    final previousPlayer = _activePlayer;
    _activePlayer = player;
    if (previousPlayer != null) await _resetPlayer(previousPlayer);
  }
  static Future<void> release(AudioPlayer player) async {
    if (!identical(_activePlayer, player)) return;
    _activePlayer = null;
    await _resetPlayer(player);
  }
  static Future<void> stopActive() async {
    final player = _activePlayer;
    _activePlayer = null;
    if (player == null) return;
    await _resetPlayer(player);
  }
}
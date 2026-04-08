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
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;

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
    unawaited(_audioRecorder.stop());
    unawaited(_audioRecorder.dispose());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      unawaited(_AudioMessagePlaybackCoordinator.stopActive());
      if (_isRecording) {
        unawaited(_audioRecorder.stop());
        if (mounted) {
          setState(() {
            _isRecording = false;
          });
        }
      }
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

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path =
            '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );

        setState(() {
          _isRecording = true;
        });
      } else {
        Get.snackbar('Permission denied', 'Microphone permission is required');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
      });

      if (path != null) {
        await ctrl.sendAudio(File(path));
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
      Get.snackbar('Error', 'Failed to send voice note: $e');
    }
  }

  Future<void> _sendText() async {
    final text = _textCtrl.text;
    _textCtrl.clear();
    await ctrl.sendText(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final peer = ctrl.chat.peer(widget.myId);
    final presence = peer != null ? ctrl.presenceMap[peer.id] : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _ChatHeader(peer: peer, myId: widget.myId, presence: presence),
            Expanded(
              child: _MessageList(
                ctrl: ctrl,
                myId: widget.myId,
                scrollCtrl: _scrollCtrl,
              ),
            ),
            _InputBar(
              textCtrl: _textCtrl,
              ctrl: ctrl,
              onSend: _sendText,
              onPickImage: _pickImage,
              onPickAudio: _pickAudio,
              onTyping: ctrl.notifyTyping,
              onStartRecording: _startRecording,
              onStopRecording: _stopRecording,
              isRecording: _isRecording,
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
    final rawName = peer?.name?.trim() ?? '';
    final displayName = rawName.isNotEmpty ? rawName : 'User';

    final avatarLetter =
        rawName.isNotEmpty ? rawName.characters.first.toUpperCase() : '?';

    final hasImage = (peer?.profilePicture?.trim().isNotEmpty ?? false);
    final isOnline = presence?.isOnline ?? false;
    final lastSeen = presence?.lastSeen ?? peer?.lastSeen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Get.back(),
          ),
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage:
                    hasImage ? NetworkImage(peer!.profilePicture!) : null,
                child:
                    !hasImage
                        ? Text(
                          avatarLetter,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        )
                        : null,
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: (){
                unawaited(_AudioMessagePlaybackCoordinator.stopActive());
                Get.toNamed(AppRoutes.othersProfileScreen,arguments: {
                  'targetId': peer?.id,
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isOnline ? 'Online' : _formatLastSeen(lastSeen),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      builder:
          (_) => SafeArea(
            child: ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Delete for me',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                ctrl.deleteMessage(msgId);
              },
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
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
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: mine ? const Color(0xFF2563EB) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft:
              mine ? const Radius.circular(16) : const Radius.circular(4),
              bottomRight:
              mine ? const Radius.circular(4) : const Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildContent(context),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('HH:mm').format(msg.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: mine ? Colors.white70 : const Color(0xFF9CA3AF),
                    ),
                  ),
                  if (mine) ...[
                    const SizedBox(width: 3),
                    Icon(
                      allRead ? Icons.done_all : Icons.done,
                      size: 14,
                      color: allRead ? Colors.white : Colors.white70,
                    ),
                  ],
                ],
              ),
            ],
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
            width: 200,
            height: 120,
            child: Center(child: Icon(Icons.broken_image)),
          );
        }

        return GestureDetector(
          onTap: () {
            unawaited(_AudioMessagePlaybackCoordinator.stopActive());
            Get.to(() => _FullScreenImageViewer(imageUrl: imageUrl));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              width: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(
                width: 200,
                height: 120,
                child: Center(child: Icon(Icons.broken_image)),
              ),
            ),
          ),
        );

      case 'audio':
        if (audioUrl == null) {
          return Text(
            'Audio unavailable',
            style: TextStyle(
              color: mine ? Colors.white : const Color(0xFF0F0F0F),
              fontSize: 14,
            ),
          );
        }

        return _AudioMessagePlayer(
          url: audioUrl,
          mine: mine,
        );

      default:
        return Text(
          msg.text ?? '',
          style: TextStyle(
            fontSize: 14,
            color: mine ? Colors.white : const Color(0xFF0F0F0F),
            height: 1.5,
          ),
        );
    }
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Dot(delay: 0),
          SizedBox(width: 4),
          _Dot(delay: 200),
          SizedBox(width: 4),
          _Dot(delay: 400),
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

    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _anim = Tween<double>(
      begin: 0,
      end: -5,
    ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeInOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ac.forward();
    });
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder:
          (_, __) => Transform.translate(
            offset: Offset(0, _anim.value),
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFF9CA3AF),
                shape: BoxShape.circle,
              ),
            ),
          ),
    );
  }
}

// ─── Input bar ────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.textCtrl,
    required this.ctrl,
    required this.onSend,
    required this.onPickImage,
    required this.onPickAudio,
    required this.onTyping,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.isRecording,
  });

  final TextEditingController textCtrl;
  final ChatController ctrl;
  final VoidCallback onSend;
  final VoidCallback onPickImage;
  final VoidCallback onPickAudio;
  final VoidCallback onTyping;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final bool isRecording;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(
              Icons.attach_file_rounded,
              color: Color(0xFF6B7280),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder:
                    (_) => SafeArea(
                      child: Wrap(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.image_outlined),
                            title: const Text('Send image'),
                            onTap: () {
                              Navigator.pop(context);
                              onPickImage();
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.mic_outlined),
                            title: const Text('Send audio'),
                            onTap: () {
                              Navigator.pop(context);
                              onPickAudio();
                            },
                          ),
                        ],
                      ),
                    ),
              );
            },
          ),
          Expanded(
            child: TextField(
              controller: textCtrl,
              onChanged: (_) => onTyping(),
              maxLines: 5,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Message…',
                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFF2563EB)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),

          GestureDetector(
            onLongPressStart: (_) => onStartRecording(),
            onLongPressEnd: (_) => onStopRecording(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isRecording ? Colors.red : const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mic,
                color: isRecording ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Obx(
            () => AnimatedOpacity(
              opacity: ctrl.isSending.value ? 0.5 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: GestureDetector(
                onTap: ctrl.isSending.value ? null : onSend,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                  child:
                      ctrl.isSending.value
                          ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MediaUrlHelper {
  static String? resolve(String? url) {
    if (url == null || url.trim().isEmpty) return null;

    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

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
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image, color: Colors.white, size: 40),
          ),
        ),
      ),
    );
  }
}

class _AudioMessagePlaybackCoordinator {
  static AudioPlayer? _activePlayer;

  static Future<void> activate(AudioPlayer player) async {
    if (identical(_activePlayer, player)) return;

    final previousPlayer = _activePlayer;
    _activePlayer = player;

    if (previousPlayer != null) {
      try {
        await previousPlayer.stop();
      } catch (_) {}
    }
  }

  static Future<void> release(AudioPlayer player) async {
    if (!identical(_activePlayer, player)) return;
    _activePlayer = null;

    try {
      await player.stop();
    } catch (_) {}
  }

  static Future<void> stopActive() async {
    final player = _activePlayer;
    _activePlayer = null;

    if (player == null) return;

    try {
      await player.stop();
    } catch (_) {}
  }
}

class _AudioMessagePlayer extends StatefulWidget {
  const _AudioMessagePlayer({
    required this.url,
    required this.mine,
  });

  final String url;
  final bool mine;

  @override
  State<_AudioMessagePlayer> createState() => _AudioMessagePlayerState();
}

class _AudioMessagePlayerState extends State<_AudioMessagePlayer> {
  late final AudioPlayer _player;
  StreamSubscription<PlayerState>? _playerStateSub;
  bool _loading = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    _playerStateSub = _player.playerStateStream.listen((state) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _togglePlay() async {
    if (_loading) return;

    try {
      if (_player.playing) {
        await _player.pause();
        return;
      }

      if (!_ready) {
        setState(() => _loading = true);
        await _player.setUrl(widget.url);
        _ready = true;
        setState(() => _loading = false);
      }

      await _AudioMessagePlaybackCoordinator.activate(_player);
      await _player.play();
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
      Get.snackbar('Error', 'Could not play audio message');
    }
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    unawaited(_AudioMessagePlaybackCoordinator.release(_player));
    unawaited(_player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.mine ? Colors.white : const Color(0xFF2563EB);
    final textColor = widget.mine ? Colors.white : const Color(0xFF0F0F0F);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _togglePlay,
          child: _loading
              ? SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: iconColor,
            ),
          )
              : Icon(
            _player.playing
                ? Icons.pause_circle_filled
                : Icons.play_circle_fill,
            color: iconColor,
            size: 32,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          _player.playing ? 'Playing...' : 'Voice message',
          style: TextStyle(
            color: textColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

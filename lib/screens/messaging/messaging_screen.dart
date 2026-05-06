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

enum _VoiceComposerMode { idle, recording, preview }

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key, required this.myId, required this.chat});

  final String myId;
  final Chat chat;

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen>
    with WidgetsBindingObserver {
  static const Duration _minimumVoiceNoteDuration = Duration(milliseconds: 700);

  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _picker = ImagePicker();

  late final ChatController ctrl;
  final AudioRecorder _audioRecorder = AudioRecorder();
  late final AudioPlayer _draftPlayer;
  StreamSubscription<PlayerState>? _draftPlayerStateSub;
  StreamSubscription<Duration>? _draftPositionSub;
  StreamSubscription<Duration?>? _draftDurationSub;
  Timer? _recordingTimer;

  _VoiceComposerMode _voiceMode = _VoiceComposerMode.idle;
  String? _draftRecordingPath;
  Duration _recordingDuration = Duration.zero;
  Duration _draftPosition = Duration.zero;
  Duration _draftDuration = Duration.zero;
  bool _draftLoading = false;
  bool _isHandlingDraftCompletion = false;
  final Set<String> _retainedVoiceDraftPaths = <String>{};

  bool get _isRecording => _voiceMode == _VoiceComposerMode.recording;

  bool get _hasVoiceDraft =>
      _voiceMode == _VoiceComposerMode.preview &&
      _draftRecordingPath != null &&
      _draftRecordingPath!.trim().isNotEmpty;

  bool get _isDraftPlaying =>
      _draftPlayer.playing &&
      _draftPlayer.playerState.processingState != ProcessingState.completed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ctrl = Get.find<ChatController>();
    ctrl.initChat(chat: widget.chat, myId: widget.myId);
    _scrollCtrl.addListener(_onScroll);
    _draftPlayer = AudioPlayer();
    _draftPlayerStateSub = _draftPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        unawaited(_handleDraftPlaybackCompleted());
      }
      if (mounted) {
        setState(() {});
      }
    });
    _draftPositionSub = _draftPlayer.positionStream.listen((position) {
      if (!mounted || !_hasVoiceDraft) return;
      setState(() => _draftPosition = position);
    });
    _draftDurationSub = _draftPlayer.durationStream.listen((duration) {
      if (!mounted || duration == null || !_hasVoiceDraft) return;
      setState(() => _draftDuration = duration);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ctrl.closeChat();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _recordingTimer?.cancel();
    unawaited(_AudioMessagePlaybackCoordinator.stopActive());
    _draftPlayerStateSub?.cancel();
    _draftPositionSub?.cancel();
    _draftDurationSub?.cancel();
    final draftPath = _draftRecordingPath;
    unawaited(_draftPlayer.dispose());
    unawaited(_audioRecorder.stop());
    unawaited(_audioRecorder.dispose());
    if (draftPath != null) {
      unawaited(_deleteVoiceFile(draftPath));
    }
    for (final path in _retainedVoiceDraftPaths) {
      unawaited(_deleteVoiceFile(path));
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      unawaited(_AudioMessagePlaybackCoordinator.stopActive());
      if (_isRecording) {
        unawaited(_finalizeRecording(openPreview: true, showErrors: false));
      } else if (_isDraftPlaying) {
        unawaited(_draftPlayer.pause());
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

    final sent = await ctrl.sendAudio(File(result.files.single.path!));
    if (sent) {
      _scrollToBottom();
    }
  }

  Future<void> _startRecording() async {
    if (_isRecording || _hasVoiceDraft || ctrl.isSending.value) return;

    try {
      if (!await _audioRecorder.hasPermission()) {
        Get.snackbar('Permission denied', 'Microphone permission is required');
        return;
      }

      await _AudioMessagePlaybackCoordinator.stopActive();

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

      _recordingTimer?.cancel();
      if (mounted) {
        setState(() {
          _voiceMode = _VoiceComposerMode.recording;
          _recordingDuration = Duration.zero;
        });
      }
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || !_isRecording) return;
        setState(() {
          _recordingDuration += const Duration(seconds: 1);
        });
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    await _finalizeRecording(openPreview: true);
  }

  Future<void> _cancelRecording() async {
    await _finalizeRecording(openPreview: false);
  }

  Future<void> _sendText() async {
    final text = _textCtrl.text;
    if (text.trim().isEmpty) return; // Prevent empty messages
    _textCtrl.clear();
    await ctrl.sendText(text);
    _scrollToBottom();
  }

  Future<void> _finalizeRecording({
    required bool openPreview,
    bool showErrors = true,
  }) async {
    if (!_isRecording) return;

    final recordedDuration = _recordingDuration;
    _recordingTimer?.cancel();

    try {
      final path = await _audioRecorder.stop();
      if (mounted) {
        setState(() {
          _voiceMode = _VoiceComposerMode.idle;
          _recordingDuration = Duration.zero;
        });
      }

      if (path == null || path.trim().isEmpty) {
        return;
      }

      final recordedFile = File(path);
      if (!await recordedFile.exists() || await recordedFile.length() == 0) {
        await _deleteVoiceFile(path);
        if (showErrors) {
          Get.snackbar('Error', 'The recorded voice note was empty.');
        }
        return;
      }

      if (recordedDuration < _minimumVoiceNoteDuration) {
        await _deleteVoiceFile(path);
        if (showErrors) {
          Get.snackbar('Too short', 'Record a slightly longer voice note.');
        }
        return;
      }

      if (!openPreview) {
        await _deleteVoiceFile(path);
        return;
      }

      await _prepareVoiceDraft(path);
    } catch (e) {
      if (mounted) {
        setState(() {
          _voiceMode = _VoiceComposerMode.idle;
          _recordingDuration = Duration.zero;
        });
      }
      if (showErrors) {
        Get.snackbar('Error', 'Failed to stop recording: $e');
      }
    }
  }

  Future<void> _prepareVoiceDraft(String path) async {
    await _resetDraftPlayer();

    final previousDraft = _draftRecordingPath;
    if (mounted) {
      setState(() {
        _voiceMode = _VoiceComposerMode.preview;
        _draftRecordingPath = path;
        _draftPosition = Duration.zero;
        _draftDuration = Duration.zero;
        _draftLoading = true;
      });
    }

    if (previousDraft != null && previousDraft != path) {
      await _deleteVoiceFile(previousDraft);
    }

    try {
      final duration = await _draftPlayer.setFilePath(path);
      if (!mounted) return;

      setState(() {
        _draftDuration = duration ?? Duration.zero;
        _draftPosition = Duration.zero;
        _draftLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _voiceMode = _VoiceComposerMode.idle;
          _draftRecordingPath = null;
          _draftPosition = Duration.zero;
          _draftDuration = Duration.zero;
          _draftLoading = false;
        });
      }
      await _deleteVoiceFile(path);
      Get.snackbar('Error', 'Could not load the recorded voice note');
    }
  }

  Future<void> _toggleDraftPlayback() async {
    if (!_hasVoiceDraft || _draftLoading) return;

    try {
      if (_draftPlayer.playing) {
        await _draftPlayer.pause();
        if (mounted) setState(() {});
        return;
      }

      final draftPath = _draftRecordingPath;
      final processingState = _draftPlayer.playerState.processingState;
      if ((processingState == ProcessingState.idle ||
              processingState == ProcessingState.completed) &&
          draftPath != null) {
        if (processingState == ProcessingState.idle) {
          if (mounted) {
            setState(() => _draftLoading = true);
          }
          final duration = await _draftPlayer.setFilePath(draftPath);
          if (mounted) {
            setState(() {
              _draftDuration = duration ?? _draftDuration;
              _draftLoading = false;
            });
          }
        } else {
          await _draftPlayer.seek(Duration.zero);
        }
      }

      await _AudioMessagePlaybackCoordinator.activate(_draftPlayer);
      await _draftPlayer.play();
    } catch (e) {
      if (mounted) {
        setState(() => _draftLoading = false);
      }
      Get.snackbar('Error', 'Could not play the recorded voice note');
    }
  }

  Future<void> _handleDraftPlaybackCompleted() async {
    if (_isHandlingDraftCompletion) return;
    _isHandlingDraftCompletion = true;

    try {
      await _draftPlayer.pause();
      await _draftPlayer.seek(Duration.zero);
      await _AudioMessagePlaybackCoordinator.release(_draftPlayer);
    } catch (_) {
    } finally {
      _isHandlingDraftCompletion = false;
      if (mounted) {
        setState(() => _draftPosition = Duration.zero);
      }
    }
  }

  Future<void> _discardVoiceDraft() async {
    if (_isRecording) {
      await _cancelRecording();
      return;
    }

    final draftPath = _draftRecordingPath;
    await _resetDraftPlayer();

    if (mounted) {
      setState(() {
        _voiceMode = _VoiceComposerMode.idle;
        _draftRecordingPath = null;
        _draftPosition = Duration.zero;
        _draftDuration = Duration.zero;
        _draftLoading = false;
      });
    }

    if (draftPath != null) {
      await _deleteVoiceFile(draftPath);
    }
  }

  Future<void> _sendVoiceDraft() async {
    final draftPath = _draftRecordingPath;
    if (draftPath == null || ctrl.isSending.value || _draftLoading) return;

    final sent = await ctrl.sendAudio(File(draftPath));
    if (!sent) return;

    _retainedVoiceDraftPaths.add(draftPath);
    await _resetDraftPlayer();
    if (mounted) {
      setState(() {
        _voiceMode = _VoiceComposerMode.idle;
        _draftRecordingPath = null;
        _draftPosition = Duration.zero;
        _draftDuration = Duration.zero;
        _draftLoading = false;
      });
    }
    await _deleteVoiceFile(draftPath);
    _scrollToBottom();
  }

  Future<void> _resetDraftPlayer() async {
    try {
      if (_draftPlayer.playing) {
        await _draftPlayer.pause();
      }
    } catch (_) {}

    try {
      await _draftPlayer.seek(Duration.zero);
    } catch (_) {}
  }

  Future<void> _deleteVoiceFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    _retainedVoiceDraftPaths.remove(path);
  }

  @override
  Widget build(BuildContext context) {
    final peer = ctrl.chat.peer(widget.myId);
    final presence = peer != null ? ctrl.presenceMap[peer.id] : null;

    return Scaffold(
      backgroundColor: const Color(0xFF030A1B), // Dark Theme Background
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
              onCancelRecording: _cancelRecording,
              onPlayVoiceDraft: _toggleDraftPlayback,
              onDiscardVoiceDraft: _discardVoiceDraft,
              onSendVoiceDraft: _sendVoiceDraft,
              voiceMode: _voiceMode,
              recordingDuration: _recordingDuration,
              draftPosition: _draftPosition,
              draftDuration: _draftDuration,
              isDraftPlaying: _isDraftPlaying,
              isDraftLoading: _draftLoading,
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
    final rawName = peer?.displayName.trim() ?? '';
    final displayName = rawName.isNotEmpty ? rawName : 'User';
    final avatarLetter =
        rawName.isNotEmpty ? rawName.characters.first.toUpperCase() : '?';

    final hasImage = (peer?.profilePicture.trim().isNotEmpty ?? false);
    final isOnline = presence?.isOnline ?? false;
    final lastSeen = presence?.lastSeen ?? peer?.lastSeen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF030A1B),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Colors.white,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withOpacity(0.1),
                backgroundImage:
                    hasImage ? NetworkImage(peer!.profilePicture) : null,
                child:
                    !hasImage
                        ? Text(
                          avatarLetter,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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
                      border: Border.all(
                        color: const Color(0xFF030A1B),
                        width: 2,
                      ),
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
                  AppRoutes.othersProfileScreen, // Or your specific route
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
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isOnline ? 'Online' : _formatLastSeen(lastSeen),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isOnline
                              ? const Color(0xFF22C55E)
                              : Colors.white.withOpacity(0.5),
                      fontWeight:
                          isOnline ? FontWeight.w500 : FontWeight.normal,
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
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
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
      backgroundColor: const Color(0xFF1F2937),
      builder:
          (_) => SafeArea(
            child: ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
              title: const Text(
                'Delete for me',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
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
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
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
    // Determine colors based on sender
    // Note: Use your primary AppColor for `mine`, e.g., AppColors.buttonColor
    final Color bubbleColor =
        mine ? const Color(0xFF2563EB) : Colors.white.withOpacity(0.1);
    final Color textColor = Colors.white;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft:
                  mine ? const Radius.circular(18) : const Radius.circular(4),
              bottomRight:
                  mine ? const Radius.circular(4) : const Radius.circular(18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildContent(context, textColor),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('HH:mm').format(msg.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
                  if (mine) ...[
                    const SizedBox(width: 4),
                    Icon(
                      allRead ? Icons.done_all : Icons.done,
                      size: 14,
                      color:
                          allRead
                              ? const Color(0xFF34B7F1)
                              : textColor.withOpacity(0.6),
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

  Widget _buildContent(BuildContext context, Color textColor) {
    final imageUrl = MediaUrlHelper.resolve(msg.image?.url);
    final audioUrl = MediaUrlHelper.resolve(msg.audio?.url);

    switch (msg.type) {
      case 'image':
        if (imageUrl == null) {
          return const SizedBox(
            width: 200,
            height: 120,
            child: Center(
              child: Icon(Icons.broken_image, color: Colors.white54),
            ),
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
              width: 240,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => const SizedBox(
                    width: 200,
                    height: 120,
                    child: Center(
                      child: Icon(Icons.broken_image, color: Colors.white54),
                    ),
                  ),
            ),
          ),
        );

      case 'audio':
        final localAudioPath = msg.localAudioPath;
        if (audioUrl == null && localAudioPath == null) {
          return Text(
            'Audio unavailable',
            style: TextStyle(color: textColor, fontSize: 14),
          );
        }

        return _AudioMessagePlayer(
          url: audioUrl,
          localFilePath: localAudioPath,
          durationHint: msg.audio?.length,
          mine: mine,
        );

      default:
        return Text(
          msg.text ?? '',
          style: TextStyle(fontSize: 15, color: textColor, height: 1.4),
        );
    }
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomRight: Radius.circular(18),
          bottomLeft: Radius.circular(4),
        ),
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
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
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
    required this.onCancelRecording,
    required this.onPlayVoiceDraft,
    required this.onDiscardVoiceDraft,
    required this.onSendVoiceDraft,
    required this.voiceMode,
    required this.recordingDuration,
    required this.draftPosition,
    required this.draftDuration,
    required this.isDraftPlaying,
    required this.isDraftLoading,
  });

  final TextEditingController textCtrl;
  final ChatController ctrl;
  final VoidCallback onSend;
  final VoidCallback onPickImage;
  final VoidCallback onPickAudio;
  final VoidCallback onTyping;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onCancelRecording;
  final VoidCallback onPlayVoiceDraft;
  final VoidCallback onDiscardVoiceDraft;
  final VoidCallback onSendVoiceDraft;
  final _VoiceComposerMode voiceMode;
  final Duration recordingDuration;
  final Duration draftPosition;
  final Duration draftDuration;
  final bool isDraftPlaying;
  final bool isDraftLoading;

  @override
  Widget build(BuildContext context) {
    if (voiceMode == _VoiceComposerMode.recording) {
      return _buildRecordingComposer();
    }

    if (voiceMode == _VoiceComposerMode.preview) {
      return _buildPreviewComposer();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF030A1B),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.white.withOpacity(0.5),
              size: 28,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF1F2937),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder:
                    (_) => SafeArea(
                      child: Wrap(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.image_outlined,
                              color: Colors.white,
                            ),
                            title: const Text(
                              'Send image',
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              onPickImage();
                            },
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.mic_outlined,
                              color: Colors.white,
                            ),
                            title: const Text(
                              'Send audio',
                              style: TextStyle(color: Colors.white),
                            ),
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
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type a message…',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 15,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          GestureDetector(
            onTap: onStartRecording,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mic_rounded, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Obx(
            () => AnimatedOpacity(
              opacity: ctrl.isSending.value ? 0.5 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: GestureDetector(
                onTap: ctrl.isSending.value ? null : onSend,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB), // Primary button color
                    shape: BoxShape.circle,
                  ),
                  child:
                      ctrl.isSending.value
                          ? const Padding(
                            padding: EdgeInsets.all(12),
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

  Widget _buildRecordingComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF030A1B),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          _buildCircleButton(
            icon: Icons.delete_outline_rounded,
            backgroundColor: Colors.white.withOpacity(0.1),
            iconColor: Colors.white54,
            onTap: onCancelRecording,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const _BlinkingDot(),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Recording...',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text(
                    _formatDuration(recordingDuration),
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildCircleButton(
            icon: Icons.stop_rounded,
            backgroundColor: Colors.redAccent,
            iconColor: Colors.white,
            onTap: onStopRecording,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewComposer() {
    final total = draftDuration > Duration.zero ? draftDuration : draftPosition;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF030A1B),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          _buildCircleButton(
            icon: Icons.delete_outline_rounded,
            backgroundColor: Colors.white.withOpacity(0.1),
            iconColor: Colors.white54,
            onTap: onDiscardVoiceDraft,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onPlayVoiceDraft,
                    child:
                        isDraftLoading
                            ? const SizedBox(
                              width: 36,
                              height: 36,
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            )
                            : Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2563EB),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isDraftPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                              ),
                            ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Voice note',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_formatDuration(draftPosition)} / ${_formatDuration(total)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Obx(
            () => _buildCircleButton(
              icon: Icons.send_rounded,
              backgroundColor: const Color(0xFF2563EB),
              iconColor: Colors.white,
              onTap: ctrl.isSending.value ? null : onSendVoiceDraft,
              child:
                  ctrl.isSending.value
                      ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback? onTap,
    Widget? child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: child ?? Icon(icon, color: iconColor),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

// Reusable Blinking Dot for Recording UI
class _BlinkingDot extends StatefulWidget {
  const _BlinkingDot();

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
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
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: Colors.redAccent,
          shape: BoxShape.circle,
        ),
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
            errorBuilder:
                (_, __, ___) => const Icon(
                  Icons.broken_image,
                  color: Colors.white,
                  size: 40,
                ),
          ),
        ),
      ),
    );
  }
}

class _AudioMessagePlaybackCoordinator {
  static AudioPlayer? _activePlayer;

  static Future<void> _resetPlayer(AudioPlayer player) async {
    try {
      if (player.playing) {
        await player.pause();
      }
    } catch (_) {}

    try {
      await player.seek(Duration.zero);
    } catch (_) {}
  }

  static Future<void> activate(AudioPlayer player) async {
    if (identical(_activePlayer, player)) return;

    final previousPlayer = _activePlayer;
    _activePlayer = player;

    if (previousPlayer != null) {
      await _resetPlayer(previousPlayer);
    }
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

class _AudioMessagePlayer extends StatefulWidget {
  const _AudioMessagePlayer({
    required this.url,
    required this.mine,
    this.localFilePath,
    this.durationHint,
  });

  final String? url;
  final String? localFilePath;
  final int? durationHint;
  final bool mine;

  @override
  State<_AudioMessagePlayer> createState() => _AudioMessagePlayerState();
}

class _AudioMessagePlayerState extends State<_AudioMessagePlayer> {
  late final AudioPlayer _player;
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  bool _loading = false;
  bool _ready = false;
  bool _isCompletingPlayback = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    _playerStateSub = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        unawaited(_handlePlaybackCompleted());
      }
      if (mounted) setState(() {});
    });
    _positionSub = _player.positionStream.listen((position) {
      if (!mounted) return;
      setState(() => _position = position);
    });
    _durationSub = _player.durationStream.listen((duration) {
      if (!mounted || duration == null) return;
      setState(() => _duration = duration);
    });
  }

  Future<void> _togglePlay() async {
    if (_loading) return;

    try {
      if (_player.playing) {
        await _player.pause();
        return;
      }

      final processingState = _player.playerState.processingState;

      if (!_ready || processingState == ProcessingState.idle) {
        setState(() => _loading = true);
        await _loadAudioSource();
        if (mounted) {
          setState(() => _loading = false);
        }
      } else if (processingState == ProcessingState.completed) {
        await _player.seek(Duration.zero);
      }

      await _AudioMessagePlaybackCoordinator.activate(_player);
      await _player.play();
    } catch (e) {
      debugPrint(
        'Audio message playback error '
        '(remote: ${widget.url}, local: ${widget.localFilePath}): $e',
      );
      _ready = false;
      if (mounted) {
        setState(() => _loading = false);
      }
      Get.snackbar('Error', 'Could not play audio message');
    }
  }

  Future<void> _handlePlaybackCompleted() async {
    if (_isCompletingPlayback) return;
    _isCompletingPlayback = true;

    try {
      await _player.pause();
      await _player.seek(Duration.zero);
      await _AudioMessagePlaybackCoordinator.release(_player);
    } catch (_) {
    } finally {
      _isCompletingPlayback = false;
      if (mounted) {
        setState(() => _position = Duration.zero);
      }
    }
  }

  Future<void> _loadAudioSource() async {
    final localFilePath = widget.localFilePath;
    if (localFilePath != null && localFilePath.trim().isNotEmpty) {
      final localFile = File(localFilePath);
      if (await localFile.exists()) {
        try {
          final duration = await _player.setFilePath(localFile.path);
          _duration = duration ?? _duration;
          _ready = true;
          return;
        } catch (e) {
          debugPrint('Local audio fallback failed ($localFilePath): $e');
        }
      }
    }

    final remoteUrl = widget.url;
    if (remoteUrl == null || remoteUrl.trim().isEmpty) {
      throw Exception('No audio source available');
    }

    final duration = await _player.setUrl(remoteUrl);
    _duration = duration ?? _duration;
    _ready = true;
  }

  Duration get _displayDuration {
    if (_duration > Duration.zero) {
      return _duration;
    }

    final hint = widget.durationHint;
    if (hint == null || hint <= 0) {
      return Duration.zero;
    }

    if (hint > 3600) {
      return Duration(milliseconds: hint);
    }

    return Duration(seconds: hint);
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    unawaited(_AudioMessagePlaybackCoordinator.release(_player));
    unawaited(_player.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.mine ? Colors.white : Colors.white;
    final textColor = widget.mine ? Colors.white : Colors.white;
    final isPlayingActive =
        _player.playing &&
        _player.playerState.processingState != ProcessingState.completed;
    final secondaryTextColor = Colors.white.withOpacity(0.6);
    final displayDuration = _displayDuration;
    final displayPosition =
        _position > displayDuration && displayDuration > Duration.zero
            ? displayDuration
            : _position;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _togglePlay,
          child:
              _loading
                  ? SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: iconColor,
                    ),
                  )
                  : Icon(
                    isPlayingActive
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    color: iconColor,
                    size: 36,
                  ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // PRO SLIDER INTEGRATION
            SizedBox(
              width: 140,
              height: 20,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3.0,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6.0,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14.0,
                  ),
                  activeTrackColor: iconColor,
                  inactiveTrackColor: iconColor.withOpacity(0.3),
                  thumbColor: iconColor,
                ),
                child: Slider(
                  min: 0.0,
                  max:
                      displayDuration.inMilliseconds > 0
                          ? displayDuration.inMilliseconds.toDouble()
                          : 1.0,
                  value: displayPosition.inMilliseconds.toDouble().clamp(
                    0.0,
                    displayDuration.inMilliseconds > 0
                        ? displayDuration.inMilliseconds.toDouble()
                        : 1.0,
                  ),
                  onChanged: (value) {
                    if (_ready) {
                      _player.seek(Duration(milliseconds: value.round()));
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '${_formatDuration(displayPosition)} / ${_formatDuration(displayDuration)}',
                style: TextStyle(color: secondaryTextColor, fontSize: 11),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

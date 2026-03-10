import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../controllers/chat_controller.dart';
import '../../models/message_model.dart';


class MessagingScreen extends StatefulWidget {
  const MessagingScreen({
    super.key,
    required this.myId,
    required this.chat,
  });

  final String myId;
  final Chat chat;

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _picker = ImagePicker();

  late final ChatController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<ChatController>();
    ctrl.initChat(chat: widget.chat, myId: widget.myId);

    _scrollCtrl.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    ctrl.closeChat();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels <= 60 &&
        ctrl.hasMore &&
        !ctrl.isLoading.value) {
      ctrl.loadMessages(loadMore: true);
    }
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickImage() async {
    final xfile = await _picker.pickImage(source: ImageSource.gallery);
    if (xfile == null) return;
    await ctrl.sendImage(File(xfile.path));
    _scrollToBottom();
  }

  Future<void> _sendText() async {
    final text = _textCtrl.text;
    _textCtrl.clear();
    await ctrl.sendText(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final peer = widget.chat.peer(widget.myId);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _ChatHeader(peer: peer, myId: widget.myId),
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
              onTyping: ctrl.notifyTyping,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.peer, required this.myId});

  final ChatParticipant? peer;
  final String myId;

  @override
  Widget build(BuildContext context) {
    final hasImage = (peer?.profilePicture?.isNotEmpty ?? false);
    final hasName = (peer?.name.isNotEmpty ?? false);

    final displayName = hasName ? peer!.name : 'User';
    final avatarLetter = hasName
        ? peer!.name.trim().substring(0, 1).toUpperCase()
        : '?';

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
          CircleAvatar(
            radius: 20,
            backgroundImage: hasImage ? NetworkImage(peer!.profilePicture!) : null,
            child: !hasImage
                ? Text(
              avatarLetter,
              style: const TextStyle(fontWeight: FontWeight.w600),
            )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Message list ─────────────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  const _MessageList({required this.ctrl, required this.myId, required this.scrollCtrl});
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
        itemCount: groups.length + (ctrl.peerIsTyping.value ? 1 : 0) + (ctrl.isLoading.value ? 1 : 0),
        itemBuilder: (_, i) {
          // Loading spinner at top
          if (ctrl.isLoading.value && i == 0) {
            return const Center(child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(strokeWidth: 2),
            ));
          }

          final adjustedI = ctrl.isLoading.value ? i - 1 : i;

          // Typing indicator at end
          if (ctrl.peerIsTyping.value && adjustedI == groups.length) {
            return const Align(
              alignment: Alignment.centerLeft,
              child: _TypingBubble(),
            );
          }

          if (adjustedI < 0 || adjustedI >= groups.length) return const SizedBox();

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
      builder: (_) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.delete_outline, color: Colors.red),
          title: const Text('Delete for me', style: TextStyle(color: Colors.red)),
          onTap: () {
            Navigator.pop(context);
            ctrl.deleteMessage(msgId);
          },
        ),
      ),
    );
  }

  List<({String label, List<ChatMessage> messages})> _groupByDate(List<ChatMessage> msgs) {
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
          child: Text(label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500)),
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
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: mine ? const Color(0xFF2563EB) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: mine ? const Radius.circular(16) : const Radius.circular(4),
              bottomRight: mine ? const Radius.circular(4) : const Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildContent(),
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

  Widget _buildContent() {
    return switch (msg.type) {
      'image' => ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(msg.image?.url ?? '', width: 200, fit: BoxFit.cover),
      ),
      'audio' => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_circle_fill, color: mine ? Colors.white : const Color(0xFF2563EB), size: 32),
          const SizedBox(width: 6),
          Text('Voice message',
              style: TextStyle(color: mine ? Colors.white : const Color(0xFF0F0F0F), fontSize: 14)),
        ],
      ),
      _ => Text(
        msg.text ?? '',
        style: TextStyle(
          fontSize: 14,
          color: mine ? Colors.white : const Color(0xFF0F0F0F),
          height: 1.5,
        ),
      ),
    };
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
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0, end: -5).animate(
      CurvedAnimation(parent: _ac, curve: Curves.easeInOut),
    );
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
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(color: Color(0xFF9CA3AF), shape: BoxShape.circle),
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
    required this.onTyping,
  });

  final TextEditingController textCtrl;
  final ChatController ctrl;
  final VoidCallback onSend;
  final VoidCallback onPickImage;
  final VoidCallback onTyping;

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
            icon: const Icon(Icons.attach_file_rounded, color: Color(0xFF6B7280)),
            onPressed: onPickImage,
          ),
          Expanded(
            child: TextField(
              controller: textCtrl,
              onChanged: (_) => onTyping(),
              maxLines: 5,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Message…',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          Obx(() => AnimatedOpacity(
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
                child: ctrl.isSending.value
                    ? const Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
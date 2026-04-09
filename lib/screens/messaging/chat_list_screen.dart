import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:intl/intl.dart';

import '../../controllers/chat_controller.dart';
import '../../models/message_model.dart';
import '../../routes/routes.dart';

class ChatListScreen extends StatelessWidget {
  UserController userController = Get.find<UserController>();
  final void Function(Chat chat)? onChatTap;
  final String? myId ;


  ChatListScreen({
    super.key,
    this.myId ,
    this.onChatTap,
  });




  @override
  Widget build(BuildContext context) {
    final String effectiveId = myId ?? userController.user.value?.id ?? '';
    final ctrl = Get.find<ChatListController>();
    ctrl.currentUserId = effectiveId;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(ctrl: ctrl),
            _SearchBar(ctrl: ctrl),
            Expanded(
              child: _ChatList(
                ctrl: ctrl,
                myId: effectiveId,
                onTap: onChatTap ?? (chat) {
                  Get.toNamed(
                    AppRoutes.messagingScreen,
                    arguments: {
                      'chat': chat,
                    },
                  );
                },

              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.ctrl});

  final ChatListController ctrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          const Text(
            'Messages',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5),
          ),
          const SizedBox(width: 10),
          Obx(() =>
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${ctrl.chats.length}',
                  style: const TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280)),
                ),
              )),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.ctrl});

  final ChatListController ctrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        onChanged: ctrl.updateSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search conversations…',
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF9CA3AF),
            size: 20,
          ),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2563EB)),
          ),
        ),
      ),
    );
  }
}

class _ChatList extends StatelessWidget {
  const _ChatList({
    required this.ctrl,
    required this.myId,
    required this.onTap,
  });

  final ChatListController ctrl;
  final String myId;
  final void Function(Chat) onTap;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoading.value && ctrl.chats.isEmpty) {
        return ListView.builder(
          itemCount: 6,
          itemBuilder: (_, __) => const _SkeletonTile(),
        );
      }

      final filteredChats = ctrl.filteredChats;

      if (filteredChats.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💬', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(
                ctrl.searchQuery.value.trim().isEmpty
                    ? 'No conversations yet'
                    : 'No matching conversations',
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: ctrl.loadChats,
        child: ListView.separated(
          itemCount: filteredChats.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 80),
          itemBuilder: (_, i) {
            final chat = filteredChats[i];
            final peer = chat.peer(myId);
            final presence = peer != null ? ctrl.presenceMap[peer.id] : null;
            final isOnline = presence?.isOnline ?? false;
            final unread = chat.unreadCount;
            final isMine = chat.lastMessage?.sender.id == myId;

            return _ChatTile(
              chat: chat,
              peer: peer,
              isOnline: isOnline,
              unread: unread,
              isMine: isMine,
              onTap: () => onTap(chat),
            );
          },
        ),
      );
    });
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({
    required this.chat,
    required this.peer,
    required this.isOnline,
    required this.unread,
    required this.isMine,
    required this.onTap,
  });

  final Chat chat;
  final ChatParticipant? peer;
  final bool isOnline;
  final int unread;
  final bool isMine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final msg = chat.lastMessage;
    final preview = _preview(msg, isMine);
    final timeStr = msg != null ? _formatTime(msg.createdAt) : '';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: peer?.profilePicture != null
                      ? NetworkImage(peer!.profilePicture!)
                      : null,
                  child: peer?.profilePicture == null
                      ? Text(peer?.name.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600))
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    right: 1,
                    bottom: 1,
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
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        peer?.displayName ?? '',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: unread > 0 ? FontWeight.w700 : FontWeight
                              .w500,
                        ),
                      ),
                      Text(timeStr,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: unread > 0
                                ? const Color(0xFF0F0F0F)
                                : const Color(0xFF6B7280),
                            fontWeight: unread > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (unread > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: const TextStyle(fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
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
    );
  }

  String _preview(ChatMessage? msg, bool mine) {
    if (msg == null) return 'No messages yet';
    final prefix = mine ? 'You: ' : '';
    return switch (msg.type) {
      'audio' => '${prefix}🎵 Voice message',
      'image' => '${prefix}📷 Photo',
      _ => '$prefix${msg.text ?? ''}',
    };
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return DateFormat('HH:mm').format(dt);
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return DateFormat('EEE').format(dt);
    return DateFormat('d MMM').format(dt);
  }
}

class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: const BoxDecoration(
                color: Color(0xFFE5E7EB), shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14,
                    width: 120,
                    decoration: BoxDecoration(color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(6))),
                const SizedBox(height: 8),
                Container(height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/utils/colors.dart';
import 'package:intl/intl.dart';

import '../../controllers/chat_controller.dart';
import '../../models/message_model.dart';
import '../../routes/routes.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../utils/dimensions.dart';
import '../../widgets/custom_appbar.dart';
// Ensure your imports for AppRoutes, AppColors, Dimensions, Controllers, Models, etc. are here

class ChatListScreen extends StatelessWidget {
  UserController userController = Get.find<UserController>();
  final void Function(Chat chat)? onChatTap;
  final String? myId;

  ChatListScreen({
    super.key,
    this.myId,
    this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    final String effectiveId = myId ?? userController.user.value?.id ?? '';
    final ctrl = Get.find<ChatListController>();
    ctrl.currentUserId = effectiveId;

    return Scaffold(
      backgroundColor: const Color(0xFF030A1B),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(ctrl: ctrl),
            _SearchBar(ctrl: ctrl),
            SizedBox(height: Dimensions.height10),
            Expanded(
              child: _ChatList(
                ctrl: ctrl,
                myId: effectiveId,
                onTap: onChatTap ??
                        (chat) {
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
      padding: EdgeInsets.fromLTRB(
          Dimensions.width20,
          Dimensions.height10,
          Dimensions.width20,
          Dimensions.height20
      ),
      child: Row(
        children: [
          Text(
            'Messages',
            style: TextStyle(
              fontSize: Dimensions.font25,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.buttonColor.withOpacity(0.15), // Soft accent background
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${ctrl.chats.length}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.buttonColor, // Accent color text
              ),
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
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      child: TextField(
        onChanged: ctrl.updateSearchQuery,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search conversations…',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            CupertinoIcons.search,
            color: Colors.white.withOpacity(0.4),
            size: 20,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05), // Sleek translucent fill
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none, // Borderless looks cleaner in dark mode
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.buttonColor, width: 1.5),
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
        // --- NEW: SKELETONIZER LOADING STATE ---
        return Skeletonizer(
          enabled: true,
          child: ListView.builder(
            itemCount: 6,
            itemBuilder: (_, __) => const _SkeletonTile(),
          ),
        );
      }

      final filteredChats = ctrl.filteredChats;

      if (filteredChats.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.chat_bubble_2,
                size: 60,
                color: Colors.white.withOpacity(0.1),
              ),
              const SizedBox(height: 16),
              Text(
                ctrl.searchQuery.value.trim().isEmpty
                    ? 'No conversations yet'
                    : 'No matching conversations',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: AppColors.buttonColor,
        backgroundColor: const Color(0xFF030A1B),
        onRefresh: ctrl.loadChats,
        child: ListView.builder( // Removed the divider for a cleaner, modern look
          itemCount: filteredChats.length,
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
      highlightColor: Colors.white.withOpacity(0.05),
      splashColor: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  backgroundImage: peer?.profilePicture != null
                      ? NetworkImage(peer!.profilePicture!)
                      : null,
                  child: peer?.profilePicture == null
                      ? Text(
                    peer?.name.substring(0, 1).toUpperCase() ?? '?',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  )
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF030A1B), width: 2.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
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
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: unread > 0 ? AppColors.buttonColor : Colors.white.withOpacity(0.5),
                          fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: unread > 0
                                ? Colors.white.withOpacity(0.9)
                                : Colors.white.withOpacity(0.5),
                            fontWeight: unread > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (unread > 0) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.buttonColor, // e.g. Color(0xFF007AFF)
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4),
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
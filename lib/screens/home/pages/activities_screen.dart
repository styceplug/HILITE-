import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/routes/routes.dart';
import 'package:hilite/utils/app_constants.dart';
import 'package:hilite/utils/colors.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:hilite/widgets/custom_appbar.dart';
import 'package:hilite/widgets/empty_state_widget.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../controllers/chat_controller.dart';
import '../../../controllers/notification_controller.dart';
import '../../../models/message_model.dart';
import '../../../models/notification_model.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen>
    with AutomaticKeepAliveClientMixin<ActivitiesScreen> {
  @override
  bool get wantKeepAlive => true;
  UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: CustomAppbar(
        title: 'Activities',
      ),
      body: GetBuilder<NotificationController>(
        init: NotificationController(notificationRepo: Get.find()),
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Container(
            height: Dimensions.screenHeight,
            width: Dimensions.screenWidth,
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
            child: Column(
              children: [

                Container(
                  height: Dimensions.height150,
                  decoration: BoxDecoration(
                    color: AppColors.grey3,
                    borderRadius: BorderRadius.circular(
                      Dimensions.radius15,
                    ),
                  ),
                  child: Center(child: Text('Ads Placement')),
                ),
                SizedBox(height: Dimensions.height10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: Dimensions.height10,
                      width: Dimensions.width10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.grey4,
                      ),
                    ),
                    SizedBox(width: Dimensions.width10),
                    Container(
                      height: Dimensions.height10,
                      width: Dimensions.width10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.grey4,
                      ),
                    ),
                    SizedBox(width: Dimensions.width10),
                    Container(
                      height: Dimensions.height10,
                      width: Dimensions.width10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.grey4,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height20),

                ItemCard(
                    icon: Icons.sports_soccer,
                    title: 'Trials',
                    subtitle: 'Check open trials here',
                    color: AppColors.warning,
                    onTap: () {
                      Get.toNamed(AppRoutes.trialListScreen);
                    }
                ),
                ItemCard(
                    icon: Icons.table_rows,
                    title: 'Competitions',
                    subtitle: 'Check open competitions here',
                    color: AppColors.success,
                    onTap: () {
                      Get.toNamed(AppRoutes.competitionsScreen);
                    }
                ),
                ItemCard(
                    icon: Icons.message,
                    title: 'Messages',
                    subtitle: 'Messaging is the fun of it all',
                    color: AppColors.error,
                    onTap: () {
                      Get.toNamed(AppRoutes.chatListScreen);
                    }
                ),

              ],
            ),
          );
        },
      ),
    );
  }

  Widget ItemCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
        child: Row(
          children: [
            // Icon Circle
            Container(
              height: Dimensions.height10 * 6,
              width: Dimensions.width10 * 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.8),
              ),
              child: Icon(
                icon,
                color: AppColors.white,
                size: Dimensions.iconSize30,
              ),
            ),
            SizedBox(width: Dimensions.width10),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: Dimensions.font18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: Dimensions.font14,
                      color: AppColors.grey4,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ChatListScreen extends StatelessWidget {
  const ChatListScreen(
      {super.key, required this.myId, required this.onChatTap});

  final String myId;
  final void Function(Chat chat) onChatTap;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ChatListController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(ctrl: ctrl),
            _SearchBar(ctrl: ctrl),
            Expanded(
                child: _ChatList(ctrl: ctrl, myId: myId, onTap: onChatTap)),
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

class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.ctrl});

  final ChatListController ctrl;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _query = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        onChanged: (v) => _query.value = v,
        decoration: InputDecoration(
          hintText: 'Search conversations…',
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          prefixIcon: const Icon(
              Icons.search, color: Color(0xFF9CA3AF), size: 20),
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
  const _ChatList(
      {required this.ctrl, required this.myId, required this.onTap});

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
      if (ctrl.chats.isEmpty) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('💬', style: TextStyle(fontSize: 40)),
              SizedBox(height: 12),
              Text('No conversations yet',
                  style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15)),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: ctrl.loadChats,
        child: ListView.separated(
          itemCount: ctrl.chats.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 80),
          itemBuilder: (_, i) {
            final chat = ctrl.chats[i];
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
                        peer?.name ?? 'Unknown',
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
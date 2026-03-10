import 'dart:async';
import 'package:get/get.dart';
import 'dart:io';
import '../data/repo/chat_repo.dart';
import '../helpers/socket_helper.dart';
import '../models/message_model.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/message_model.dart';


class ChatListController extends GetxController {
  ChatListController({
    required this.chatRepo,
    required this.socketHelper,
  });

  final ChatRepo chatRepo;
  final SocketHelper socketHelper;

  String? myId;

  final chats = <Chat>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final presenceMap = <String, UserPresence>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadChats();
    _subscribeSocket();
  }

  Future<void> loadChats() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await chatRepo.getChats();

      if (response.statusCode == 200 && response.body['code'] == '00') {
        final List list = response.body['data']?['data'] ?? [];
        chats.assignAll(list.map((e) => Chat.fromJson(e)).toList());
      } else {
        errorMessage.value = response.body?['message'] ?? 'Failed to load chats';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void markOpened(String chatId) {
    final idx = chats.indexWhere((c) => c.id == chatId);
    if (idx == -1) return;
    chats[idx] = chats[idx].copyWith(unreadCount: 0);
  }

  void _subscribeSocket() {
    socketHelper.onNewMessage((data) {
      final chatId = data['chatId']?.toString();
      final msgJson = data['message'];

      if (chatId == null || msgJson == null) return;

      final msg = ChatMessage.fromJson(msgJson as Map<String, dynamic>);

      final idx = chats.indexWhere((c) => c.id == chatId);
      if (idx == -1) {
        loadChats();
        return;
      }

      final updated = chats[idx].copyWith(
        lastMessage: msg,
        unreadCount: chats[idx].unreadCount + 1,
      );

      chats.removeAt(idx);
      chats.insert(0, updated);
    });

    socketHelper.onUserStatus((data) {
      final presence = UserPresence.fromJson(data as Map<String, dynamic>);
      presenceMap[presence.userId] = presence;
    });
  }
}



class ChatController extends GetxController {
  final ChatRepo chatRepo;
  final SocketHelper socketHelper;

  ChatController({
    required this.chatRepo,
    required this.socketHelper,
  });

  final TextEditingController messageController = TextEditingController();

  RxList<ChatMessage> messages = <ChatMessage>[].obs;
  RxBool isLoading = false.obs;
  RxBool isSending = false.obs;
  RxBool peerIsTyping = false.obs;

  Chat? selectedChat;
  String? currentChatId;
  String? currentUserId;

  int _page = 1;
  int _totalPages = 1;
  Timer? _typingTimer;
  bool _isTyping = false;

  bool get hasMore => _page < _totalPages;

  Future<void> initChat({
    required Chat chat,
    required String myId,
  }) async {
    selectedChat = chat;
    currentChatId = chat.id;
    currentUserId = myId;

    socketHelper.leaveChat(chat.id);
    socketHelper.joinChat(chat.id);

    await loadMessages(reload: true);
    await markChatAsRead();
    _bindSocketEvents();
  }

  Future<void> loadMessages({bool loadMore = false, bool reload = false}) async {
    if (currentChatId == null) return;

    if (reload) {
      _page = 1;
      messages.clear();
    }

    final nextPage = loadMore ? _page + 1 : _page;
    if (loadMore && nextPage > _totalPages) return;

    isLoading.value = true;

    final response = await chatRepo.getMessages(
      chatId: currentChatId!,
      page: nextPage,
      limit: 30,
    );

    if (response.statusCode == 200 && response.body['code'] == '00') {
      final data = response.body['data'];
      final List list = data['data'] ?? [];

      final fetched = list.map((e) => ChatMessage.fromJson(e)).toList();

      _page = nextPage;
      _totalPages = data['totalPages'] ?? 1;

      if (loadMore) {
        messages.insertAll(0, fetched);
      } else {
        messages.assignAll(fetched);
      }
    } else {
      Get.snackbar(
        'Error',
        response.body?['message'] ?? 'Failed to fetch messages',
      );
    }

    isLoading.value = false;
  }

  Future<void> sendText(String text) async {
    if (currentChatId == null) return;

    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    isSending.value = true;

    final response = await chatRepo.sendTextMessage(
      chatId: currentChatId!,
      text: trimmed,
    );

    if (response.statusCode == 201 && response.body['code'] == '00') {
      final message = ChatMessage.fromJson(response.body['data']);
      messages.add(message);
      messageController.clear();
      stopTyping();
    } else {
      Get.snackbar(
        'Error',
        response.body?['message'] ?? 'Failed to send message',
      );
    }

    isSending.value = false;
  }

  Future<void> sendImage(File file) async {
    if (currentChatId == null) return;

    isSending.value = true;

    final response = await chatRepo.sendImageMessage(
      chatId: currentChatId!,
      imageFile: file,
    );

    if (response.statusCode == 201 && response.body['code'] == '00') {
      messages.add(ChatMessage.fromJson(response.body['data']));
    } else {
      Get.snackbar(
        'Error',
        response.body?['message'] ?? 'Failed to send image',
      );
    }

    isSending.value = false;
  }

  Future<void> sendAudio(File file) async {
    if (currentChatId == null) return;

    isSending.value = true;

    final response = await chatRepo.sendAudioMessage(
      chatId: currentChatId!,
      audioFile: file,
    );

    if (response.statusCode == 201 && response.body['code'] == '00') {
      messages.add(ChatMessage.fromJson(response.body['data']));
    } else {
      Get.snackbar(
        'Error',
        response.body?['message'] ?? 'Failed to send audio',
      );
    }

    isSending.value = false;
  }

  Future<void> markChatAsRead() async {
    if (currentChatId == null) return;
    await chatRepo.markChatAsRead(currentChatId!);
  }

  Future<void> deleteMessage(String messageId) async {
    final response = await chatRepo.deleteMessage(messageId);

    if (response.statusCode == 200 && response.body['code'] == '00') {
      messages.removeWhere((e) => e.id == messageId);
    }
  }

  String? get peerId {
    if (selectedChat == null || currentUserId == null) return null;
    return selectedChat!.peer(currentUserId!)?.id;
  }

  void notifyTyping() {
    if (currentChatId == null || peerId == null) return;

    if (!_isTyping) {
      _isTyping = true;
      socketHelper.sendTyping(
        chatId: currentChatId!,
        recipientId: peerId!,
        isTyping: true,
      );
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 1500), stopTyping);
  }

  void stopTyping() {
    if (!_isTyping || currentChatId == null || peerId == null) return;

    _isTyping = false;
    socketHelper.sendTyping(
      chatId: currentChatId!,
      recipientId: peerId!,
      isTyping: false,
    );
  }

  void _bindSocketEvents() {
    socketHelper.onNewMessage((data) {
      if (data['chatId'] != currentChatId) return;
      final msg = ChatMessage.fromJson(data['message']);
      final exists = messages.any((e) => e.id == msg.id);
      if (!exists) {
        messages.add(msg);
      }
      markChatAsRead();
    });

    socketHelper.onMessagesRead((data) {
      if (data['chatId'] != currentChatId) return;
      final readByUserId = data['readByUserId']?.toString();
      if (readByUserId == null) return;

      for (int i = 0; i < messages.length; i++) {
        final msg = messages[i];
        if (!msg.readBy.contains(readByUserId)) {
          messages[i] = msg.copyWith(
            readBy: [...msg.readBy, readByUserId],
          );
        }
      }
      messages.refresh();
    });

    socketHelper.onTyping((data) {
      if (data['chatId'] != currentChatId) return;
      if (data['userId'] == currentUserId) return;
      peerIsTyping.value = data['isTyping'] == true;
    });
  }

  void closeChat() {
    _typingTimer?.cancel();
    if (currentChatId != null) {
      socketHelper.leaveChat(currentChatId!);
    }
    peerIsTyping.value = false;
  }

  @override
  void onClose() {
    closeChat();
    messageController.dispose();
    super.onClose();
  }
}
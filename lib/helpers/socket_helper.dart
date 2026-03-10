import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;


class SocketHelper extends GetxService {
  io.Socket? _socket;
  io.Socket? get socket => _socket;

  final RxBool isConnected = false.obs;

  Future<void> connect({
    required String baseUrl,
    required String token,
  }) async {
    disconnect();

    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setAuth({'token': token})
          .build(),
    );

    _socket?.onConnect((_) {
      isConnected.value = true;
      print('✅ Socket connected: ${_socket?.id}');
    });

    _socket?.onDisconnect((_) {
      isConnected.value = false;
      print('❌ Socket disconnected');
    });

    _socket?.onConnectError((data) {
      isConnected.value = false;
      print('⚠️ Socket connect error: $data');
    });

    _socket?.onError((data) {
      print('⚠️ Socket error: $data');
    });

    _socket?.connect();
  }

  void disconnect() {
    _socket?.off('new_message');
    _socket?.off('messages_read');
    _socket?.off('typing');
    _socket?.off('user_status');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    isConnected.value = false;
  }

  void joinChat(String chatId) {
    _socket?.emit('join_chat', {'chatId': chatId});
  }

  void leaveChat(String chatId) {
    _socket?.emit('leave_chat', {'chatId': chatId});
  }

  void sendTyping({
    required String chatId,
    required String recipientId,
    required bool isTyping,
  }) {
    _socket?.emit('typing', {
      'chatId': chatId,
      'recipientId': recipientId,
      'isTyping': isTyping,
    });
  }

  void onNewMessage(Function(dynamic data) callback) {
    _socket?.off('new_message');
    _socket?.on('new_message', callback);
  }

  void onMessagesRead(Function(dynamic data) callback) {
    _socket?.off('messages_read');
    _socket?.on('messages_read', callback);
  }

  void onTyping(Function(dynamic data) callback) {
    _socket?.off('typing');
    _socket?.on('typing', callback);
  }

  void onUserStatus(Function(dynamic data) callback) {
    _socket?.off('user_status');
    _socket?.on('user_status', callback);
  }
}
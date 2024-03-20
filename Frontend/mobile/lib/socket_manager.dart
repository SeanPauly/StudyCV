// ignore_for_file: library_prefixes

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketManager with ChangeNotifier {
  late IO.Socket _socket;
  BuildContext context; // Pass the context to SocketManager if needed

  SocketManager(this.context) {
    createSocketConnection();
  }

  void createSocketConnection() {
    String socketURL = _determineSocketURL();
    _socket = IO.io(socketURL, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.onConnect((_) {
      debugPrint('Socket Connected');
      notifyListeners();
    });

    _socket.onDisconnect((_) {
      debugPrint('Socket Disconnected');
      notifyListeners();
    });

    _socket.onConnectError((data) {
      debugPrint('Connection Error: $data');
      notifyListeners();
      // Consider implementing retry logic here
    });

    _socket.onError((data) {
      debugPrint('Error: $data');
      // Handle specific error events here
    });

    // Implement a retry mechanism or a manual trigger for reconnection
    connect();
  }

  void connect() async {
    try {
      _socket.connect();
      // Optionally, set a connection timeout
    } catch (e) {
      debugPrint('Socket connection failed: $e');
      // Handle connection failure (e.g., retry connection)
    }
  }

  void disconnect() {
    if (_socket.connected) {
      _socket.disconnect();
    }
  }

  void emit(String event, [dynamic data]) {
    if (_socket.connected) {
      _socket.emit(event, data);
    } else {
      debugPrint('Socket is not connected. Cannot emit event $event');
      // Optionally, queue the event for later or try to reconnect
    }
  }

  void on(String event, Function(dynamic) callback) {
    _socket.on(event, callback);
  }

  void logout() {
    emit('logout', {'reason': 'User logged out'});
    disconnect();
    // Optionally, clear any client-side user data or session info here
  }

  @override
  void dispose() {
    _socket.dispose();
    super.dispose();
  }

  String _determineSocketURL() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    } else if (Platform.isIOS) {
      return 'http://localhost:3000';
    } else {
      return 'http://your_production_url:3000';
    }
  }
  
  void ensureConnected() {
    if (!_socket.connected) {
      _socket.connect();
      // Bind listeners again if needed
      _socket.onConnect((_) => notifyListeners());
      _socket.onDisconnect((_) => notifyListeners());
    }
  }
}  
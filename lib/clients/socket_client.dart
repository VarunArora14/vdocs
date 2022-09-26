import 'package:socket_io_client/socket_io_client.dart' as io;

import '../constants/constants.dart';

class SocketClient {
  io.Socket? socket; // can be null at start
  static SocketClient? _instance;

// private constructor for socket client
  SocketClient._internal() {
    // uri is our IP address. Here we configure the socket and below we connect it
    socket = io.io(host, <String, dynamic>{
      'transports': ['websocket'], // transportation is through web sockets
      'autoConnect': false, // we don't want to connect it right away
    });
    socket!.connect();
  }
// static so that we work on single instance all along
  static SocketClient get instance {
    _instance ??= SocketClient._internal(); // if instance if null, call the private constructor, otherwise
    return _instance!;
  }
}

// we want this class to be a singleton design pattern as single instance remains throughout the class
import 'package:socket_io_client/socket_io_client.dart';
import 'package:vdocs/clients/socket_client.dart';

class SocketRepo {
  // it is null check, if it is null then we call the private constructor
  final _socketClient = SocketClient.instance.socket!; // instance from getter of SocketClient
  Socket get socketClient => _socketClient; // getter for socketClient to be used at other places

  // we want sockets to join a room so socket can send data to that room
  void joinRoom(String roomId) {
    _socketClient.emit('join', roomId); // keep roomId same as documentId
    // calls the io.on() method in index.js
  }
}

import 'package:flutter_quill/flutter_quill.dart';
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

  void typing(Map<String, dynamic> data) {
    _socketClient.emit('typing', data); // pass data to 'typing' event
  }

  void changeListener(Function(Map<String, dynamic>) func) {
    // here we have to take changed data and pass it to quill controller which we can't access here
    // we call the parameter func to report the changes to the document
    _socketClient.on('changes', (data) => func(data));
  }

  void autoSave(Map<String, dynamic> data) {
    _socketClient.emit('save', data); // handle this emit in index.js file
  }
}

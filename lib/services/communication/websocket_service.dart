import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:rxdart/rxdart.dart';

class WebSocketService {
  late final WebSocketChannel _channel;

  final BehaviorSubject<String> _messageStreamController =
      BehaviorSubject<String>();

  Stream<String> get messages => _messageStreamController.stream;

  void connect() {
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://communication-api.os-develop.site/ws'),
    );

    _channel.stream.listen((message) {
      _messageStreamController.add(message);
    }, onError: (error) {
      print('WebSocket Error: $error');
    }, onDone: () {
      print('WebSocket closed');
      _messageStreamController.close();
    });
  }

  // Send a message over the WebSocket
  void sendMessage(String message) {
    _channel.sink.add(message);
  }

  // Close the WebSocket connection
  void disconnect() {
    _channel.sink.close();
  }
}

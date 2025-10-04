
import 'package:flutter/material.dart';
import 'package:family_message/widgets/message_bubble.dart';
import 'package:family_message/widgets/message_composer.dart';

class ChatScreen extends StatefulWidget {
  final String conversationName;

  const ChatScreen({Key? key, required this.conversationName}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'sender': 'Dad', 'message': 'See you tomorrow!'},
    {'sender': 'You', 'message': 'Okay, sounds good.'},
  ]; // Sample messages

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({'sender': 'You', 'message': _controller.text});
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversationName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final bool isMe = message['sender'] == 'You';
                return MessageBubble(
                  sender: message['sender']!,
                  text: message['message']!,
                  isMe: isMe,
                );
              },
            ),
          ),
          MessageComposer(
            controller: _controller,
            onSendPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

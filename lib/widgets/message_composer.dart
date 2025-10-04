
import 'package:flutter/material.dart';

class MessageComposer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendPressed;

  const MessageComposer({Key? key, required this.controller, required this.onSendPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: onSendPressed,
          ),
        ],
      ),
    );
  }
}

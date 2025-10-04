import 'package:flutter/material.dart';
import 'package:family_message/screens/chat_screen.dart';
import 'package:family_message/widgets/conversation_list_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
      ),
      body: ListView(
        children: [
          ConversationListItem(
            avatarText: 'FG',
            name: 'Family Group',
            lastMessage: 'Dad: See you tomorrow!',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ChatScreen(conversationName: 'Family Group'),
                ),
              );
            },
          ),
          ConversationListItem(
            avatarText: 'M',
            name: 'Mom',
            lastMessage: 'You: Okay, sounds good.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ChatScreen(conversationName: 'Mom'),
                ),
              );
            },
          ),
          ConversationListItem(
            avatarText: 'D',
            name: 'Dad',
            lastMessage: 'See you tomorrow!',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ChatScreen(conversationName: 'Dad'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
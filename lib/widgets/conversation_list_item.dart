
import 'package:flutter/material.dart';

class ConversationListItem extends StatelessWidget {
  final String avatarText;
  final String name;
  final String lastMessage;
  final VoidCallback onTap;

  const ConversationListItem({
    Key? key,
    required this.avatarText,
    required this.name,
    required this.lastMessage,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(avatarText)),
      title: Text(name),
      subtitle: Text(lastMessage),
      onTap: onTap,
    );
  }
}

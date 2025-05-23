import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:mobile_app/screens/user_screens/profile/base_profile_screen.dart';
import 'package:mobile_app/style/colors.dart';
import 'package:mobile_app/types/controllers/main_user_controller.dart';
import 'package:mobile_app/types/events/comments.dart';
import 'package:mobile_app/types/user/user.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

Map<String, types.User> chatUserFromPure(List<PureUser> users) {
  Map<String, types.User> chatUsers = {};

  for (var user in users) {
    chatUsers[user.id] = types.User(
      id: user.id.toString(),
      firstName: user.firstName,
      lastName: user.lastName,
      imageUrl: user.pictureUrl,
    );
  }
  return chatUsers;
}

List<types.Message> messagesFromComments(List<PureComment> comments, List<PureUser> users) {
  final chatUsers = chatUserFromPure(users);
  List<types.Message> messages = [];

  for (var comment in comments) {
    if (!chatUsers.containsKey(comment.authorId)) {
      log("comment id ${comment.id} from user ${comment.authorId} not found");
      continue;
    }

    messages.add(
      types.TextMessage(author: chatUsers[comment.authorId]!, id: comment.id.toString(), text: comment.text),
    );
  }
  return messages;
}

class ChatScreen extends StatefulWidget {
  static const String routeName = "/chat";

  static Route getChatRoute(RouteSettings settings) {
    Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;

    List<types.Message>? messages = args["messages"] as List<types.Message>?;
    if (messages == null) {
      throw Exception("Messages object is required in args");
    }

    return CupertinoPageRoute(builder: (context) => ChatScreen(messages: messages));
  }

  final List<types.Message> messages;

  const ChatScreen({super.key, required this.messages});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  get messages => widget.messages;

  @override
  void initState() {
    super.initState();
  }

  void _addMessage(types.Message message) {
    setState(() {
      messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message, types.User author) {
    final textMessage = types.TextMessage(
      author: author,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);
  }

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<MainUserController>(context, listen: false).user;

    if (user == null) {
      log("user is null, but in chat screen");
      throw Exception("critical error user is null");
    }

    final chatUser = chatUserFromPure([user])[user.id]!;

    return Scaffold(
      backgroundColor: lightGrayWithPurple,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Chat(
        messages: messages,
        onSendPressed: (message) {
          _handleSendPressed(message, chatUser);
        },
        onAvatarTap: (types.User user) {
          Navigator.pushNamed(context, ProfileScreen.routeName, arguments: int.parse(user.id));
        },
        showUserAvatars: true,
        showUserNames: true,
        user: chatUser,
        theme: DefaultChatTheme(
          backgroundColor: lightGrayWithPurple,
          inputBackgroundColor: Colors.white,
          inputTextColor: Colors.black,
        ),
      ),
    );
  }
}

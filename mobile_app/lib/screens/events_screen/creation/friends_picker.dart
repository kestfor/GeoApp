import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/types/user/user.dart';

class FriendsSelectionScreen extends StatefulWidget {
  final List<PureUser> friends;
  final List<int>? selectedFriendIds;

  const FriendsSelectionScreen({super.key, required this.friends, this.selectedFriendIds});

  @override
  _FriendsSelectionScreenState createState() => _FriendsSelectionScreenState();
}

class _FriendsSelectionScreenState extends State<FriendsSelectionScreen> {
  late final List<PureUser> _friends = widget.friends;

  late final Set<int> _selectedFriendIds = Set.of(widget.selectedFriendIds ?? []);

  @override
  Widget build(BuildContext context) {
    final avatarSize = MediaQuery.of(context).size.width * 0.1;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Choose friends'),
        actions: [
          // Кнопка для обработки выбранных друзей
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              final List<PureUser> selectedFriends =
                  _friends.where((friend) => _selectedFriendIds.contains(friend.id)).toList();

              Navigator.pop(context, selectedFriends);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friend = _friends[index];
          final isSelected = _selectedFriendIds.contains(friend.id);
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(avatarSize / 2),
              child: CachedNetworkImage(
                imageUrl: friend.pictureUrl,
                width: avatarSize,
                height: avatarSize,
                fit: BoxFit.cover,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            title: Text("${friend.firstName} ${friend.lastName}"),
            subtitle: Text("@${friend.username}"),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (bool? selected) {
                setState(() {
                  if (selected == true) {
                    _selectedFriendIds.add(friend.id);
                  } else {
                    _selectedFriendIds.remove(friend.id);
                  }
                });
              },
            ),
          );
        },
      ),
    );
  }
}

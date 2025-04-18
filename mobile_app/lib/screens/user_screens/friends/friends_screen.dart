import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/style/colors.dart';

import '../../../types/user/user.dart';
import '../profile/user_screen.dart';
import 'friend_button.dart';
import 'friend_list.dart';

class FriendsScreen extends StatefulWidget {
  final LazyDataProvider<PureUser> dataProvider;
  final User user;

  static const String routeName = "/friends";

  static Route getFriendsRoute(RouteSettings settings) {
    Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;

    LazyDataProvider<PureUser>? dataProvider = args["dataProvider"];
    User? user = args["user"];

    if (dataProvider == null) {
      throw Exception("DataProvider is required in args");
    }

    if (user == null) {
      throw Exception("User object is required in args");
    }

    return CupertinoPageRoute(builder: (context) => FriendsScreen(dataProvider: dataProvider, user: user));
  }

  const FriendsScreen({super.key, required this.dataProvider, required this.user});

  @override
  State createState() => FriendsScreenState();
}

class FriendsScreenState extends State<FriendsScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<PureUser> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;
  String _query = '';
  Timer? _debounce;

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        _searchFocusNode.requestFocus();
      } else {
        _searchController.clear();
        _query = '';
        _fetchData(reset: true);
        _searchFocusNode.unfocus();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchData();
      }
    });
  }

  Future<void> _fetchData({bool reset = false}) async {
    if (reset) {
      _offset = 0;
      _hasMore = true;
      _items.clear();
    }
    setState(() {
      _isLoading = true;
    });
    List<PureUser> newItems = await widget.dataProvider.fetchItems(
      userId: widget.user.id,
      offset: _offset,
      limit: _limit,
      query: _query,
    );
    setState(() {
      _offset += newItems.length;
      _isLoading = false;
      if (newItems.length < _limit) {
        _hasMore = false;
      }
      _items.addAll(newItems);
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _query = query;
      });
      _fetchData(reset: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Widget buildLazyList() {
    final size = MediaQuery.of(context).size;
    final avatarSize = (size.width / 8).ceilToDouble();
    final paddingSize = avatarSize;
    return CupertinoScrollbar(
      controller: _scrollController,
      child: ListView.separated(
        controller: _scrollController,
        itemCount: _items.length + (_hasMore ? 1 : 0),
        separatorBuilder:
            (context, index) => Padding(
              padding: EdgeInsets.only(left: paddingSize * 2 + avatarSize * 2 / 3),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 4)),
                  ],
                ),
                child: Divider(color: gray.withOpacity(0.2), height: 1),
              ),
            ),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Center(
              child: Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator())),
            );
          }

          final user = _items[index];
          return ListTile(
            tileColor: lightGrayWithPurple,
            //subtitle: Padding(padding: EdgeInsets.only(left: paddingSize), child: Text("@${user.username}", style: TextStyle(fontSize: 12, color: Colors.grey))),
            contentPadding: EdgeInsets.only(left: paddingSize / 2, right: paddingSize / 2, top: 4, bottom: 4),
            leading: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 7))],
              ),
              child: CachedNetworkImage(
                imageUrl: _items[index].pictureUrl,
                errorWidget: (context, url, error) => CircleAvatar(child: Icon(Icons.error)),
                placeholder: (context, url) => CircularProgressIndicator(color: purpleGradient[1]),
                fit: BoxFit.cover,
                imageBuilder: (context, imageProvider) => CircleAvatar(backgroundImage: imageProvider),
              ),
            ),
            title: Padding(padding: EdgeInsets.only(left: paddingSize), child: Text(user.firstName)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Random random = Random();
              Navigator.pushNamed(
                context,
                UserScreen.routeName,
                arguments: {"user": user.id, "status": FriendStatus.values[random.nextInt(FriendStatus.values.length)]},
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(color: _isSearching ? Colors.grey : lightGrayWithPurple),
      child: _isSearching ? _buildSearchBar() : _buildNormalAppBar(),
    );
  }

  AppBar _buildNormalAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Friends', style: TextStyle(color: Colors.black)),
      centerTitle: false,
      actions: [IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: _toggleSearch)],
    );
  }

  AppBar _buildSearchBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: _toggleSearch),
      title: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        autofocus: true,
        decoration: InputDecoration(
          hintStyle: const TextStyle(color: Colors.black, fontSize: 24),
          hintText: 'Search users...',
          border: InputBorder.none,
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrayWithPurple,
      appBar: PreferredSize(preferredSize: Size.fromHeight(kToolbarHeight), child: _buildAppBar()),
      body: buildLazyList(),
    );
  }
}

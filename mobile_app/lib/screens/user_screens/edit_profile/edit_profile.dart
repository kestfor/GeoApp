import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/geo_api/services/users_service.dart';
import 'package:mobile_app/style/colors.dart';
import 'package:mobile_app/toast_notifications/notifications.dart';
import 'package:mobile_app/utils/date_picker/date_picker.dart';

import '../../../types/user/user.dart';

class ProfileEditScreen extends StatefulWidget {
  final User user;

  static const String routeName = "/edit_profile";

  static Route getProfileEditRoute(RouteSettings settings) {
    User? user = settings.arguments as User?;
    if (user == null) {
      throw Exception("User object is required in args");
    }
    return CupertinoPageRoute(builder: (context) => ProfileEditScreen(user: user));
  }

  const ProfileEditScreen({super.key, required this.user});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final UsersService _usersService = UsersService();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _usernameController = TextEditingController(text: widget.user.username);
    _bioController = TextEditingController(text: widget.user.bio);
    _birthDate = widget.user.birthDate;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() async {

    final json = widget.user.toJson();
    User modified = User.fromJson(json);
    modified.firstName = _firstNameController.text;
    modified.lastName = _lastNameController.text;
    modified.username = _usernameController.text;
    modified.bio = _bioController.text;
    modified.birthDate = _birthDate;

    try {
      await _usersService.modifyUser(modified);
    } on Exception catch (error) {
      print("$error");
      showError(context, error.toString());
      return;
    }

    setState(() {
      widget.user.firstName = _firstNameController.text;
      widget.user.lastName = _lastNameController.text;
      widget.user.username = _usernameController.text;
      widget.user.bio = _bioController.text;
      widget.user.birthDate = _birthDate;
    });

    Navigator.pop(context, widget.user);
  }

  void _removeDate() {
    setState(() {
      _birthDate = null;
    });
  }

  Widget _buildInputBlock({required String label, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 5.0, bottom: 5.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(label, style: const TextStyle(fontSize: 16, color: Colors.purple)), child],
      ),
    );
  }

  Widget _defaultTextField(controller, hintText, {maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: 1,
      decoration: InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintText: hintText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Profile Info'),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _saveProfile)],
      ),
      backgroundColor: lightGrayWithPurple,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: SafeArea(
      
          child: Column(
      
            children: [
              _buildInputBlock(
                label: 'Your name',
                child: SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _defaultTextField(_firstNameController, "First Name"),
                      Divider(thickness: 0.1),
                      _defaultTextField(_lastNameController, "Last Name"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
      
              _buildInputBlock(label: 'Your username', child: _defaultTextField(_usernameController, "@username")),
              const SizedBox(height: 10),
      
              _buildInputBlock(
                label: 'Your bio',
                child: _defaultTextField(_bioController, "Write about yourself...", maxLines: 3),
              ),
              const SizedBox(height: 10),
      
              _buildInputBlock(
                label: 'Your birthday',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 40,
                      child: BottomDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        onPicked: (DateTime date) {
                          setState(() {
                            _birthDate = date;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Date of Birth'),
                            Text(
                              _birthDate != null
                                  ? '${_birthDate!.day.toString().padLeft(2, '0')}.'
                                      '${_birthDate!.month.toString().padLeft(2, '0')}.'
                                      '${_birthDate!.year}'
                                  : 'Not set',
                              style: TextStyle(color: _birthDate != null ? purple : Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
      
                    Divider(thickness: 0.1),
                    GestureDetector(
                      onTap: _removeDate,
                      child: const Text('Remove Date of Birth', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 300)
            ],
          ),
        ),
      ),
    );
  }
}

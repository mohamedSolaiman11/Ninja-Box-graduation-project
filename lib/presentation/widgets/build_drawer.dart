import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:graduation_project2024/presentation/view/admin.dart';
import 'package:graduation_project2024/presentation/view/pictures_from_camera.dart';
import 'package:graduation_project2024/utils/app_color.dart';
import 'package:image_picker/image_picker.dart';
import '../view/permission_page.dart';
import '../view/rules_page.dart';
import '../view/settings.dart';
import '../view/verificationCode.dart';
import '../widgets/build_drawer_items.dart';
import '../widgets/go_to_page_only.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BulidDrawer extends StatefulWidget {
  BulidDrawer({
    super.key,
    required this.closeMyDrawer,
  });
  final VoidCallback? closeMyDrawer;

  @override
  State<BulidDrawer> createState() => _BulidDrawerState();
}

class _BulidDrawerState extends State<BulidDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String? _profileImageUrl;
  bool _isLoading = false;
  final FocusNode focusNode= FocusNode();
  String? _username;
  bool _isEditingUsername = false;
  final TextEditingController _usernameController = TextEditingController();



  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImageUrl =
          prefs.getString('profileImageUrl') ?? _auth.currentUser?.photoURL;
    });
  }

  Future<void> _saveProfileImageUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImageUrl', url);
    setState(() {
      _profileImageUrl = url;
    });
  }

  Future<void> _updateProfileImage(File image) async {
    try {
      setState(() {
        _isLoading = true; // Start loading
      });

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${_auth.currentUser!.uid}.jpg');
      await storageRef.putFile(image);
      final downloadUrl = await storageRef.getDownloadURL();

      await _auth.currentUser!.updatePhotoURL(downloadUrl);
      await _saveProfileImageUrl(downloadUrl);

      // Cache the downloaded image
      final file = await DefaultCacheManager().getSingleFile(downloadUrl);

      setState(() {
        _profileImageUrl = downloadUrl;
        _isLoading = false; // Stop loading
      });
    } catch (e) {
      setState(() {
        _isLoading = false; // Stop loading in case of error
      });
      print('Error uploading profile image: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        _image = file;
      });
      await _updateProfileImage(file);
    }
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'User Name';
      _usernameController.text = _username!;
    });
  }

  Future<void> _saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    setState(() {
      _username = username;
      _isEditingUsername = false;
    });
  }
  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadUsername();
    focusNode.addListener(() {
      if (!focusNode.hasFocus && _usernameController.text.isNotEmpty) {
        _saveUsername(_usernameController.text);
      }
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    _usernameController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Drawer(
        elevation: 0,
        width: size.width * .85,
        backgroundColor: AppColor.light_yellow,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Container(
            width: size.width,
            height: size.height,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: widget.closeMyDrawer,
                        icon: const Icon(
                          Icons.close_outlined,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 12,
                  child: DrawerHeader(
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      children: [
                        Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: size.width * .5,
                                  height: size.height * .22,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(250)),
                                  ),
                                  child: _profileImageUrl != null
                                      ? FittedBox(
                                          child: CircleAvatar(
                                            radius: 80,
                                            backgroundImage:
                                                NetworkImage(_profileImageUrl!),
                                          ),
                                        )
                                      : FittedBox(
                                    fit: BoxFit.cover,
                                        child: CircleAvatar(
                                          radius: 80,
                                          backgroundColor: Colors.grey,
                                          child: _image != null
                                              ? Image.file(
                                                  _image!,
                                                )
                                              : const Icon(Icons.person,
                                                  size: 80,
                                                  color: Colors.white),
                                        ),
                                      ),
                                ),
                                _isLoading
                                    ? Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(80))),
                                          // Semi-transparent background
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                                color: Colors.white),
                                          ),
                                        ),
                                      )
                                    : Positioned(
                                        bottom: 10,
                                        right: 20,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(7),
                                          ),
                                          width: 30,
                                          height: 30,
                                          child: GestureDetector(
                                            onTap: _pickImage,
                                            child: const Icon(
                                              Icons.edit,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),

                            _isEditingUsername
                                ? TextField(
                                    textAlign: TextAlign.center,
                                    controller: _usernameController,
                                    focusNode: focusNode,
                                    style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Enter your name',
                                      hintStyle:
                                          TextStyle(color: Colors.white54),
                                    ),
                                    onSubmitted: (newName) {
                                      _saveUsername(newName);

                                    },
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _username ?? 'User Name',
                                        style: const TextStyle(
                                            fontSize: 24,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.white),
                                        onPressed: () {
                                          setState(() {
                                            _isEditingUsername = true;
                                          });
                                        },
                                      )
                                    ],
                                  ),
                            const SizedBox(height: 20),
                            BuildDrawerRowItems(
                              text: 'Verification Code',
                              icon: Icons.numbers,
                              onTap: () {
                                goToPageOnly(context, Verification());
                              },
                            ),
                            BuildDrawerRowItems(
                              text: 'Settings',
                              icon: Icons.settings,
                              onTap: () {
                                goToPageOnly(context, Settings());
                              },
                            ),
                            BuildDrawerRowItems(
                              text: 'Permission',
                              icon: Icons.add_chart_rounded,
                              onTap: () {
                                goToPageOnly(context, const PermissionPage());
                              },
                            ),
                            BuildDrawerRowItems(
                              text: 'Rules',
                              icon: Icons.rule,
                              onTap: () {
                                goToPageOnly(context, const RulesPage());
                              },
                            ),
                            BuildDrawerRowItems(
                              text: 'Camera Pictures',
                              icon: Icons.camera_alt,
                              onTap: () {
                                goToPageOnly(
                                    context, const PicturesFromCamera());
                              },
                            ),
                            // BuildDrawerRowItems(
                            //   text: 'Pick ',
                            //   icon: Icons.video_camera_front_outlined,
                            //   onTap: () {
                            //     goToPageOnly(context, const CameraStreamPage());
                            //   },
                            // ),
                            BuildDrawerRowItems(
                              text: 'Log Out',
                              icon: Icons.logout,
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        const Admin(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

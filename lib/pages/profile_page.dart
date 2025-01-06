import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:image_picker/image_picker.dart';
import 'package:schedule_app/main.dart';
import 'package:schedule_app/pages/signup_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _userId = supabase.auth.currentUser?.id;

  Map<String, dynamic>? userMetadata;
  @override
  void initState() {
    super.initState();
    fetchUserMetadata();
  }

  void fetchUserMetadata() {
    final user = supabase.auth.currentUser;

    if (user != null) {
      setState(() {
        userMetadata = user.userMetadata;
      });
    }
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const SignupPage(),
      ),
      ModalRoute.withName('/'),
    );
  }

  Future<void> _deleteAllSchedule() async {
    await supabase.from('schedules').delete().eq('id', userMetadata!['id']);
  }

  Future<void> _deleteAccount() async {
    _deleteAllSchedule();
    _signOut();
    await supabase.from('profiles').delete().eq('id', userMetadata!['id']);
  }

  Future<void> _getImageFromGalery() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final File originalFile = File(image.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: Theme.of(context).appBarTheme.titleTextStyle ??
              const TextStyle(color: Colors.white),
        ),
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ?? Colors.blue,
        actions: [
          IconButton(
            onPressed: () {
              _signOut();
            },
            icon: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    ProfilePicture(
                      name: userMetadata?['full_name'] ?? 'User',
                      radius: 50,
                      fontsize: 20,
                      random: true,
                    ),
                    GestureDetector(
                      child: const Text('Edit Profile picture'),
                      onTap: () {},
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        userMetadata?['username']?.toString() ?? 'Username',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(top: 50.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Full Name: ${userMetadata!['full_name']}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 20,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 10.0)),
                      Text(
                        'Email: ${userMetadata!['email']}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 20,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 200),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: const Text(
                                      'This feature is still in development'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Ok'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text('Edit Account'),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: const Text(
                                      'Are you sure you want to delete your account?'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              content: const Text(
                                                  'This feature is still in development'),
                                              actions: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Ok'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: const Text('Yes'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('No'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            'Delete account',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

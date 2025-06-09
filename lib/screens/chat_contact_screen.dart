import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatContactsScreen extends StatelessWidget {
  const ChatContactsScreen({super.key});

  void _onMenuOptionSelected(String choice, BuildContext context) {
    if (choice == 'Logout') {
      FirebaseAuth.instance.signOut();
    } else if (choice == 'Settings') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Settings clicked")));
    } else if (choice == 'About') {
      showAboutDialog(
        context: context,
        applicationName: "ChitChat",
        applicationVersion: "1.0.0",
        applicationLegalese: "© 2025 ChitChat Inc.",
      );
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'a while ago';
    final dt = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hr ago';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  String _getChatId(String uid1, String uid2) {
    return uid1.compareTo(uid2) < 0 ? '$uid1\_$uid2' : '$uid2\_$uid1';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'ChitChat',
          style: TextStyle(
            color: Color.fromRGBO(108, 99, 255, 1),
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            menuPadding: EdgeInsets.all(20),
            iconSize: 30,
            color: Colors.white,
            icon: Icon(Icons.menu, color: Color.fromRGBO(108, 99, 255, 1)),
            onSelected: (choice) => _onMenuOptionSelected(choice, context),
            itemBuilder:
                (BuildContext context) => [
                  PopupMenuItem(
                    value: 'Settings',
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        color: Color.fromRGBO(108, 99, 255, 1),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'About',
                    child: Text(
                      'About',
                      style: TextStyle(
                        color: Color.fromRGBO(108, 99, 255, 1),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'Logout',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginScreen()),
                      );
                    },
                    child: Text(
                      'Logout',
                      style: TextStyle(
                        color: Color.fromRGBO(108, 99, 255, 1),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              cursorColor: Color.fromRGBO(108, 99, 255, 1),
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                prefixIcon: const Icon(Icons.search),
                prefixIconColor: Color.fromRGBO(108, 99, 255, 1),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Contacts list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                final users =
                    docs
                        .map(
                          (doc) => UserModel.fromMap(
                            doc.data() as Map<String, dynamic>,
                          ),
                        )
                        .where((user) => user.uid != currentUser!.uid)
                        .toList();

                if (users.isEmpty) {
                  return const Center(child: Text("No other users found."));
                }

                return ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  itemBuilder: (context, index) {
                    final user = users[index];

                    final displayName =
                        (user.name != null && user.name!.isNotEmpty)
                            ? user.name!
                            : user.email ?? 'Unknown';

                    return FutureBuilder<QuerySnapshot>(
                      future:
                          FirebaseFirestore.instance
                              .collection('chats')
                              .doc(_getChatId(currentUser!.uid, user.uid))
                              .collection('messages')
                              .orderBy('timestamp', descending: true)
                              .limit(1)
                              .get(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text("Something went wrong"),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data == null) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final docs = snapshot.data!.docs;

                        if (docs.isEmpty) {
                          return const Center(child: Text("No messages yet"));
                        }
                        String preview = '';
                        if (docs.isNotEmpty) {
                          final msg = docs.first.data() as Map<String, dynamic>;

                          final type =
                              msg.containsKey('type') ? msg['type'] : 'text';

                          if (type == 'image') {
                            preview = '📷 Photo';
                          } else if (type == 'file') {
                            preview = '📎 File';
                          } else {
                            preview = msg['text'] ?? '';
                          }
                        }

                        return Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          elevation: 1,
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            leading: CircleAvatar(
                              radius: 26,
                              backgroundColor: const Color.fromRGBO(
                                108,
                                99,
                                255,
                                0.1,
                              ),
                              child: Text(
                                displayName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Color.fromRGBO(108, 99, 255, 1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Text(
                                  '9:30 PM', // You can replace this with last msg time from snapshot
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              preview.isNotEmpty
                                  ? preview
                                  : (user.isOnline
                                      ? 'Online'
                                      : 'Last seen ${_formatTimestamp(user.lastSeen)}'),
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    preview.isNotEmpty
                                        ? Colors.black87
                                        : (user.isOnline
                                            ? Colors.green
                                            : Colors.grey),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(peerUser: user),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

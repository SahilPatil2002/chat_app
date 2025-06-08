import 'package:chat_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatContactsScreen extends StatelessWidget {
  const ChatContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Contact'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          final users = docs
              .map(
                (doc) =>
                    UserModel.fromMap(doc.data() as Map<String, dynamic>),
              )
              .where((user) => user.uid != currentUser!.uid)
              .toList();

          if (users.isEmpty) {
            return const Center(child: Text("No other users found."));
          }

          return ListView.separated(
  itemCount: users.length,
  separatorBuilder: (_, __) => const SizedBox(height: 12),
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  itemBuilder: (context, index) {
    final user = users[index];

    final displayName = (user.name != null && user.name!.isNotEmpty)
        ? user.name!
        : user.email ?? 'Unknown';

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color.fromRGBO(108, 99, 255, 0.1),
          child: Text(
            displayName[0].toUpperCase(),
            style: const TextStyle(
              color: Color.fromRGBO(108, 99, 255, 1),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          displayName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          user.email ?? '',
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // Navigator.pushNamed(context, '/chat', arguments: user);
        },
      ),
    );
  },
);
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';

class FriendsListScreen extends StatelessWidget {
  const FriendsListScreen({super.key});

  static String get routeName => 'FriendsListScreen';

  @override
  Widget build(BuildContext context) {
    final List<UserEntity> dummyFriends = [
      UserEntity(
        id: '1',
        userName: 'ali_reza',
        email: 'ali@test.com',
        name: 'علی رضا',
        friends: [],
      ),UserEntity(
        id: '1',
        userName: 'sina',
        email: 'ali@test.com',
        name: 'سینا',
        friends: [],
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
        ),
        title: const Text(
          'دوستان من',
          style: TextStyle(fontFamily: 'CR', color: Colors.black, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: dummyFriends.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: dummyFriends.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final friend = dummyFriends[index];
                return _buildFriendCard(context, friend);
              },
            ),
    );
  }

  Widget _buildFriendCard(BuildContext context, UserEntity friend) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.cyan.withValues(alpha: 0.2),

            child: const Icon(Icons.person, color: Colors.cyan),
          ),
          title: Text(
            friend.userName,
            style: const TextStyle(fontFamily: 'GB', fontSize: 16),
          ),
          subtitle: Text(
            friend.name.isNotEmpty ? friend.name : 'بدون نام',
            style: const TextStyle(
              fontFamily: 'CR',
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          trailing: Container(
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.chat_bubble_rounded,
                color: Colors.green,
                size: 20,
              ),
              onPressed: () {
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'شما هنوز دوستی اضافه نکرده‌اید.',
            style: TextStyle(
              fontFamily: 'CR',
              color: Colors.grey[500],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

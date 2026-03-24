import 'package:flutter/material.dart';
import 'package:flutter_chat_room_app/domain/entity/conversation_entity.dart';
import 'package:flutter_chat_room_app/presentation/screens/chat_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class ChatListItem extends StatelessWidget {
  final List<ConversationEntity> chatList;
  const ChatListItem(this.chatList, {super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(childCount: chatList.length, (
        context,
        index,
      ) {
        final chat = chatList[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
          child: InkWell(
            onTap: () {
              context.pushNamed(ChatScreen.routeName);
            },
            child: Container(
              width: 180,
              height: 70,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                color: Colors.transparent,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.cyan,
                      child: Center(child: Icon(FontAwesomeIcons.user)),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chat.participants.last.name,
                            style: const TextStyle(
                              fontFamily: 'GB',
                              fontSize: 20,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            chat.lastMessageId,
                            style: const TextStyle(
                              fontFamily: 'cr',
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // const Column(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Padding(
                    //       padding: EdgeInsets.all(8.0),
                    //       child: Text('23:15'),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

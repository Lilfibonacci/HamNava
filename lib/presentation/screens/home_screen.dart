import 'package:flutter/material.dart';
import 'package:flutter_chat_room_app/presentation/customWidget/chat_list_item.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static String get namedRoute => 'HomeScreen';
}

class _HomeScreenState extends State<HomeScreen> {
  FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              title: const Text(
                'هم نوا',
                style: TextStyle(fontFamily: 'CR', fontSize: 24),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(FontAwesomeIcons.userGroup, size: 20),
                ),
                const SizedBox(width: 15),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 15,
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextField(
                    focusNode: searchFocusNode,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      hintText: 'جستجو در گفتگوها...',
                      hintStyle: const TextStyle(
                        fontFamily: 'CR',
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        FontAwesomeIcons.magnifyingGlass,
                        size: 18,
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 14, 208, 211),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const ChatListItem(),
            const SliverPadding(padding: EdgeInsetsGeometry.only(top: 120)),
          ],
        ),
      ),
    );
  }
}

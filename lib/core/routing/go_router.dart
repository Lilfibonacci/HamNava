import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/core/utility/go_router_refresh_stream.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_event.dart';
import 'package:flutter_chat_room_app/presentation/customWidget/navigation_bar.dart';
import 'package:flutter_chat_room_app/presentation/screens/about_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/chat_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/create_group_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/edit_profile_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/friend_list_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/home_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/loading_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/login_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/setting_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/register_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/user_profile_screen.dart';
import 'package:flutter_chat_room_app/presentation/screens/user_search_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';

final appGlobalRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,

  refreshListenable: GoRouterRefreshStream(
    locator<PocketBase>().authStore.onChange,
  ),

  redirect: (context, state) {
    final bool isAuthenticated = locator<PocketBase>().authStore.isValid;
    final String currentPath = state.matchedLocation;

    final bool isAuthRoute =
        currentPath == '/loginScreen' || currentPath == '/RegisterScreen';

    if (!isAuthenticated && !isAuthRoute) {
      return '/';
    }

    if (isAuthenticated && isAuthRoute) {
      return '/HomeScreen';
    }

    if (isAuthenticated && currentPath == '/') {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      name: LoadingScreen.routeName,
      path: '/',
      builder: (context, state) {
        return const LoadingScreen();
      },
    ),

    GoRoute(
      name: LoginScreen.namedRoute,
      path: '/loginScreen',
      builder: (context, state) {
        return BlocProvider(
          create: (context) =>
              AuthBloc(locator.get(), locator.get(), locator.get()),
          child: const LoginScreen(),
        );
      },
    ),
    GoRoute(
      name: RegisterScreen.namedRoute,
      path: '/RegisterScreen',
      builder: (context, state) {
        return BlocProvider(
          create: (context) =>
              AuthBloc(locator.get(), locator.get(), locator.get()),
          child: const RegisterScreen(),
        );
      },
    ),
    GoRoute(
      name: AboutScreen.routeName,
      path: '/AboutScreen',
      builder: (context, state) {
        return const AboutScreen();
      },
    ),
    GoRoute(
      path: '/chatScreen/:friendId',
      name: ChatScreen.routeName,
      builder: (context, state) {
        final friendId = state.pathParameters['friendId']!;

        final friend = state.extra as UserEntity;

        return BlocProvider(
          create: (context) {
            final bloc = ChatBloc(
              locator.get(),
              locator.get(),
              locator.get(),
              locator.get(),
              locator.get(),
              locator.get(),
              locator.get(),
            );
            if (friendId.isNotEmpty) {
              bloc.add(ChatInitializeEvent(friendId));
            }
            return bloc;
          },
          child: ChatScreen(friend),
        );
      },
    ),

    GoRoute(
      name: UserSearchScreen.routeName,
      path: '/UserSearchScreen',
      builder: (context, state) {
        return BlocProvider(
          create: (context) => UserBloc(
            locator.get(),
            locator.get(),
            locator.get(),
            locator.get(),
            updateProfileUseCase: locator.get(),
          ),
          child: const UserSearchScreen(),
        );
      },
    ),

    GoRoute(
      name: UserProfileScreen.routeName,
      path: '/UserProfileScreen',
      builder: (context, state) {
        final user = state.extra as UserEntity;

        return UserProfileScreen(user);
      },
    ),

    GoRoute(
      name: CreateGroupScreen.routeName,
      path: '/CreateGroupScreen',
      builder: (context, state) {
        return const CreateGroupScreen();
      },
    ),
    GoRoute(
      name: EditProfileScreen.routeNmae,
      path: '/editProfile',
      // 👈 بخش redirect را کاملا پاک کنید
      builder: (context, state) {
        // ۱. اگر اطلاعات وجود داشت، صفحه به درستی ساخته می‌شود
        if (state.extra is UserEntity) {
          final user = state.extra as UserEntity;

          return BlocProvider(
            create: (context) => UserBloc(
              updateProfileUseCase: locator.get(),
              locator.get(),
              locator.get(),
              locator.get(),
              locator.get(),
            ),
            child: EditProfileScreen(currentUser: user),
          );
        }

        // ۲. اگر به خاطر رفرش شدن دیتابیس extra خالی شد:
        // این دستور بلافاصله کاربر را به صورت امن به صفحه قبل برمی‌گرداند
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            if (context.canPop()) {
              context.pop();
            } else {
              // اگر به هر دلیلی pop کار نکرد، مستقیما بفرست به مسیر اصلی تنظیمات
              context.goNamed(
                'setting',
              ); // 👈 نام روت تنظیمات خود را اینجا بنویسید (اگر متفاوت است)
            }
          }
        });

        // ۳. در آن کسری از ثانیه، به جای یک صفحه کاملا خالی سفید یا سیاه،
        // یک لودینگ زیبا نشان می‌دهیم تا تجربه کاربری بهتری داشته باشد
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MyBootomNavigationBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/HomeScreen',
              name: HomeScreen.namedRoute,
              builder: (context, state) {
                final userId = locator<PocketBase>().authStore.record!.id;

                return BlocProvider(
                  create: (context) {
                    final bloc = ChatBloc(
                      locator.get(),
                      locator.get(),
                      locator.get(),
                      locator.get(),
                      locator.get(),
                      locator.get(),
                      locator.get(),
                    );
                    if (userId.isNotEmpty) {
                      bloc.add(GetChatListEvent(userId));
                    }
                    return bloc;
                  },
                  child: const HomeScreen(),
                );
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/FriendListScreen',
              name: FriendsListScreen.routeName,
              builder: (context, state) {
                final userId = locator<PocketBase>().authStore.record!.id;

                return BlocProvider(
                  create: (context) {
                    final bloc = UserBloc(
                      locator.get(),
                      locator.get(),
                      locator.get(),
                      locator.get(),
                      updateProfileUseCase: locator.get(),
                    );
                    if (userId.isNotEmpty) {
                      bloc.add(FriendListEvent(userId));
                    }
                    return bloc;
                  },

                  child: const FriendsListScreen(),
                );
              },
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              name: SettingScreen.routeName,
              path: '/SettingScreen',
              builder: (context, state) {
                final currentUserId =
                    locator<PocketBase>().authStore.record?.id ?? '';

                return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) =>
                          AuthBloc(locator.get(), locator.get(), locator.get()),
                    ),

                    BlocProvider(
                      create: (context) {
                        final userBloc = UserBloc(
                          locator.get(),
                          locator.get(),
                          locator.get(),
                          locator.get(),
                          updateProfileUseCase: locator.get(),
                        );

                        userBloc.add(ProfileInfoEvent(currentUserId));

                        return userBloc;
                      },
                    ),
                  ],
                  child: const SettingScreen(),
                );
              },
            ),
          ],
        ),
      ],
    ),
  ],
);

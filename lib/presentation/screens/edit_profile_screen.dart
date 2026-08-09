import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/core/constants/color.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_bloc.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_state.dart';
import 'package:flutter_chat_room_app/presentation/customWidget/custom_snack_bar.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/core/network/pocket_base_config.dart';

class EditProfileScreen extends StatefulWidget {
  final UserEntity currentUser;

  const EditProfileScreen({super.key, required this.currentUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();

  static String get routeNmae => 'editProfileScreens';
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUser.name);
    _emailController = TextEditingController(text: widget.currentUser.email);
    _usernameController = TextEditingController(
      text: widget.currentUser.userName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  File? _avatarFile;

  Future<void> _pickAvatar() async {
    try {
      final result = await FilePicker.pickFiles(type: FileType.image);
      if (result != null && result.files.single.path != null) {
        setState(() {
          _avatarFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      debugPrint('Error picking avatar: $e');
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final newName = _nameController.text.trim();
      final newEmail = _emailController.text.trim();
      final newUsername = _usernameController.text.trim();

      context.read<UserBloc>().add(
        UpdateProfileInfoEvent(
          widget.currentUser.id,
          newUsername,
          newEmail,
          newName,
          avatarFile: _avatarFile,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scaffoldBg = isDark ? Colors.black : const Color(0xFFF2F2F7);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final primaryColor = const Color(0xFF0ED0D3);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: scaffoldBg,
        elevation: 0,
        title: const Text(
          'ویرایش پروفایل',
          style: TextStyle(
            fontFamily: 'CR',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UpdateProfileInfoSuccessState) {
            state.update.fold(
              (failure) {
                final snackBar = buildCustomSnackBar(
                  title: 'failure',
                  message: failure.message,
                  color: CustomColor.red,
                  type: .warning,
                );

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(snackBar);
              },
              (updatedUser) {
                final snackBar = buildCustomSnackBar(
                  title: 'success',
                  message: 'پروفایل با موفقیت به روز رسانی شد',
                  color: CustomColor.green,
                  type: .success,
                );

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(snackBar);
                context.pop();
              },
            );
          }
        },
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 24.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? Colors.white10
                                      : Colors.black12,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: _avatarFile != null
                                    ? Image.file(
                                        _avatarFile!,
                                        fit: BoxFit.cover,
                                      )
                                    : (widget.currentUser.avatar != null &&
                                          widget.currentUser.avatar!.isNotEmpty)
                                    ? CachedNetworkImage(
                                        imageUrl:
                                            '${locator.get<PocketBaseConfig>().client.baseURL}/api/files/users/${widget.currentUser.id}/${widget.currentUser.avatar}',
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const CupertinoActivityIndicator(),
                                        errorWidget: (context, url, error) =>
                                            const Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Colors.grey,
                                            ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.grey,
                                      ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _pickAvatar,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0ED0D3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.camera_fill,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _nameController,
                                icon: CupertinoIcons.person_solid,
                                iconColor: CupertinoColors.activeBlue,
                                label: 'نام و نام خانوادگی',
                                isDark: isDark,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'لطفاً نام خود را وارد کنید';
                                  }
                                  return null;
                                },
                              ),
                              Divider(
                                height: 1,
                                thickness: 0.5,
                                color: Colors.grey.withValues(alpha: .2),
                                indent: 56,
                              ),
                              _buildTextField(
                                controller: _usernameController,
                                icon: CupertinoIcons.at,
                                iconColor: CupertinoColors.activeOrange,
                                label: 'نام کاربری (یوزرنیم)',
                                isDark: isDark,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'لطفاً نام کاربری را وارد کنید';
                                  }
                                  if (value.length < 3) {
                                    return 'نام کاربری باید حداقل ۳ حرف باشد';
                                  }
                                  return null;
                                },
                              ),
                              Divider(
                                height: 1,
                                thickness: 0.5,
                                color: Colors.grey.withValues(alpha: .2),
                                indent: 56,
                              ),
                              _buildTextField(
                                controller: _emailController,
                                icon: CupertinoIcons.mail_solid,
                                iconColor: CupertinoColors.systemPink,
                                label: 'ایمیل',
                                keyboardType: TextInputType.emailAddress,
                                isDark: isDark,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'لطفاً ایمیل خود را وارد کنید';
                                  }
                                  if (!value.contains('@') ||
                                      !value.contains('.')) {
                                    return 'ایمیل نامعتبر است';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    final isLoading = state is UpdateProfileInfoLoadingState;
                    return SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? const CupertinoActivityIndicator(
                                color: Colors.black,
                              )
                            : const Text(
                                'ذخیره تغییرات',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'CR',
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool isDark,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          fontFamily: 'CR',
          fontSize: 16,
          color: isDark ? Colors.white : Colors.black,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: 'CR',
            color: Colors.grey[500],
            fontSize: 14,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        validator: validator,
      ),
    );
  }
}

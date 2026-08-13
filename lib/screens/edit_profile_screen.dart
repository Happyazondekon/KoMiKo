import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:komiko/services/user_service.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:komiko/widgets/bubble_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  String? _avatarUrl;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserService>().currentUser;
    _usernameController = TextEditingController(text: user?.username);
    _bioController = TextEditingController(text: user?.bio);
    _avatarUrl = user?.avatarUrl;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final bytes = await file.readAsBytes();
      if (bytes.lengthInBytes > 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.imageTooLarge)),
          );
        }
        return;
      }
      setState(() {
        _imageFile = file;
      });
    }
  }

  void _showImagePickerOptions() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.selectAvatar,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(l10n.predefinedAvatars,
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 8),
              // Predefined avatar grid from DiceBear API
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _kAvatarUrls.map((url) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _avatarUrl = url;
                          _imageFile = null;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _avatarUrl == url ? Colors.amber : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(url),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(height: 24),
              Text(l10n.customAvatar,
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 8),
              Wrap(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.photo_library),
                    title: Text(l10n.gallery),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.photo_camera),
                    title: Text(l10n.camera),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Predefined avatars from DiceBear API (fun-emoji style)
  static const List<String> _kAvatarUrls = [
    'https://api.dicebear.com/9.x/fun-emoji/png?seed=komiko1',
    'https://api.dicebear.com/9.x/fun-emoji/png?seed=komiko2',
    'https://api.dicebear.com/9.x/fun-emoji/png?seed=komiko3',
    'https://api.dicebear.com/9.x/fun-emoji/png?seed=rire4',
    'https://api.dicebear.com/9.x/fun-emoji/png?seed=rire5',
    'https://api.dicebear.com/9.x/fun-emoji/png?seed=blague6',
    'https://api.dicebear.com/9.x/adventurer/png?seed=alice',
    'https://api.dicebear.com/9.x/adventurer/png?seed=bob',
    'https://api.dicebear.com/9.x/adventurer/png?seed=charlie',
    'https://api.dicebear.com/9.x/adventurer/png?seed=diana',
    'https://api.dicebear.com/9.x/adventurer/png?seed=eve',
    'https://api.dicebear.com/9.x/adventurer/png?seed=frank',
  ];

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isUpdating = true);

    try {
      String? finalAvatarUrl = _avatarUrl;
      if (_imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        final base64Image = base64Encode(bytes);
        finalAvatarUrl = 'base64:$base64Image';
      }

      await context.read<UserService>().updateProfile(
        username: _usernameController.text.trim(),
        bio: _bioController.text.trim(),
        avatarUrl: finalAvatarUrl,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdateSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Widget _buildAvatar() {
    if (_imageFile != null) {
      return CircleAvatar(radius: 60, backgroundImage: FileImage(_imageFile!));
    }
    if (_avatarUrl != null && _avatarUrl!.startsWith('base64:')) {
      return CircleAvatar(
        radius: 60,
        backgroundImage: MemoryImage(base64Decode(_avatarUrl!.substring(7))),
      );
    }
    return const CircleAvatar(radius: 60, child: Icon(Icons.person, size: 60));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _showImagePickerOptions,
                child: Stack(
                  children: [
                    _buildAvatar(),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.yellow, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, size: 20, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: l10n.username,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.isEmpty ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.bio,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),
              BubbleButton(
                onTap: _isUpdating ? null : _updateProfile,
                label: l10n.save,
                fullWidth: true,
                isLoading: _isUpdating,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
import 'package:komiko/models/joke_model.dart';
import 'package:komiko/models/user_model.dart';
import 'package:komiko/services/follow_service.dart';
import 'package:komiko/services/joke_service.dart';
import 'package:komiko/services/user_service.dart';
import 'package:komiko/theme/app_colors.dart';
import 'package:komiko/widgets/bubble_button.dart';
import 'package:komiko/widgets/joke_card.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _jokeService = JokeService();
  final _followService = FollowService();
  late Future<UserModel?> _userFuture;
  late Future<Map<String, int>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    _userFuture = _loadUserData();
    _statsFuture = _jokeService.getUserStats(widget.userId);
  }

  Future<UserModel?> _loadUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentUser = context.watch<UserService>().currentUser;
    final isMe = currentUser?.uid == widget.userId;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<UserModel?>(
      future: _userFuture,
      builder: (context, userSnap) {
        if (userSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final user = userSnap.data;
        if (user == null) {
          return Scaffold(appBar: AppBar(), body: Center(child: Text(l10n.errorOops)));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(user.username ?? l10n.anonymous, 
                style: GoogleFonts.poppins(fontWeight: FontWeight.w800)),
            centerTitle: true,
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Avatar
                      AuthorAvatar(
                        url: user.avatarUrl,
                        name: user.username ?? '?',
                        radius: 50,
                      ),
                      const SizedBox(height: 16),
                      // Name + verified
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user.username ?? l10n.anonymous,
                            style: GoogleFonts.poppins(
                                fontSize: 22, fontWeight: FontWeight.w800),
                          ),
                          if (user.isVerified) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.verified,
                                color: AppColors.primary, size: 22),
                          ],
                        ],
                      ),
                      if (user.bio != null && user.bio!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 8),
                          child: Text(
                            user.bio!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                color: AppColors.textSecondaryDark,
                                fontSize: 14),
                          ),
                        ),
                      const SizedBox(height: 20),
                      
                      // Stats Row
                      FutureBuilder<Map<String, int>>(
                        future: _statsFuture,
                        builder: (context, statsSnap) {
                          final stats = statsSnap.data ?? {};
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStat(user.followersCount.toString(), l10n.followers),
                              _buildStat(user.followingCount.toString(), l10n.following),
                              _buildStat((stats['totalLikes'] ?? 0).toString(), l10n.likesReceived),
                            ],
                          );
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Follow Button
                      if (!isMe)
                        StreamBuilder<bool>(
                          stream: _followService.isFollowingStream(user.uid),
                          builder: (context, followingSnap) {
                            final isFollowing = followingSnap.data ?? false;
                            return BubbleButton(
                              onTap: () async {
                                if (isFollowing) {
                                  await _followService.unfollowUser(user.uid);
                                } else {
                                  await _followService.followUser(
                                    targetUid: user.uid,
                                    targetName: user.username ?? '',
                                    targetAvatar: user.avatarUrl,
                                    currentUserName: currentUser?.username ?? '',
                                    currentUserAvatar: currentUser?.avatarUrl,
                                  );
                                }
                                setState(() {
                                  _userFuture = _loadUserData();
                                });
                              },
                              variant: isFollowing
                                  ? BubbleVariant.secondary
                                  : BubbleVariant.primary,
                              label: isFollowing ? l10n.unfollow : l10n.follow,
                              size: BubbleSize.small,
                            );
                          },
                        ),
                      
                      const SizedBox(height: 32),
                      // Jokes Section Header
                      Row(
                        children: [
                          Text(
                            l10n.jokes,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Jokes List
              StreamBuilder<List<Joke>>(
                stream: _jokeService.getUserJokes(user.uid),
                builder: (context, jokesSnap) {
                  if (jokesSnap.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()));
                  }
                  final jokes = jokesSnap.data ?? [];
                  if (jokes.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: Text(l10n.noMyJokes)),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => JokeCard(joke: jokes[i]),
                      childCount: jokes.length,
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
              fontSize: 12, color: AppColors.textSecondaryDark),
        ),
      ],
    );
  }
}

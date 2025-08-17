import 'package:flutter/material.dart';
import 'package:piksel_mos/main.dart';

import 'package:video_player/video_player.dart';
import 'package:readmore/readmore.dart';
import 'package:piksel_mos/information/notification_screen.dart';
import 'package:piksel_mos/information/message_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<List<dynamic>> _fetchPosts() async {
    try {
      final response = await supabase
          .from('posts')
          .select()
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: userRole,
      builder: (context, role, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Piksel Mos Feed',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => const NotificationScreen(),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
builder: (context) => MessageScreen(),
                  );
                },
              ),
            ],
            backgroundColor: const Color(0xFF069494),
            elevation: 0,
          ),
          floatingActionButton: null, // Remove FAB
          body: FutureBuilder<List<dynamic>>(
            future: _fetchPosts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: const CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No posts found.'));
              }

              final posts = snapshot.data!;
              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index] as Map<String, dynamic>;
                  return PostCard(post: post);
                },
              );
            },
          ),
        );
      },
    );
  }
}

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final mediaUrl = post['media_url'] as String?;
    final mediaType = post['media_type'] as String?;
    final caption = post['caption'] as String?;

    final title = post['title'] as String?;

    final aspectRatioValue = post['media_aspect_ratio'];
    final double aspectRatio = (aspectRatioValue as num? ?? 1.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null && title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        if (title != null && title.isNotEmpty) const SizedBox(height: 4),

        if (mediaUrl != null && mediaType != null)
          AspectRatio(
            aspectRatio: aspectRatio,
            child: mediaType == 'video'
                ? VideoPlayerWidget(videoUrl: mediaUrl)
                : Image.network(
                    mediaUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error, color: Colors.red),
                      );
                    },
                  ),
          ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {},
              ),
            ],
          ),
        ),

        if (caption != null && caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ).copyWith(bottom: 24.0),
            child: ReadMoreText(
              caption,
              trimLines: 2,
              colorClickableText: Colors.blue,
              trimMode: TrimMode.Line,
              trimCollapsedText: '...more',
              trimExpandedText: ' less',
            ),
          ),
      ],
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      _controller.setLooping(true);
      _controller.play();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !_controller.value.hasError) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

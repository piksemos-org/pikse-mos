import 'package:flutter/material.dart';
import 'package:piksel_mos/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:readmore/readmore.dart';
import 'package:piksel_mos/information/notification_screen.dart';
import 'package:piksel_mos/information/message_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = _fetchPosts();
  }

  Future<List<dynamic>> _fetchPosts() async {
    try {
      final response = await supabase
          .from('posts')
          .select()
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat postingan: $e')));
      }
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
                    builder: (context) => const MessageScreen(),
                  );
                },
              ),
            ],
            backgroundColor: const Color(0xFF069494),
            elevation: 0,
          ),
          body: FutureBuilder<List<dynamic>>(
            future: _postsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
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
          floatingActionButton: role == 'admin'
              ? FloatingActionButton(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      '/upload',
                    );
                    if (result == true) {
                      setState(() {
                        _postsFuture = _fetchPosts();
                      });
                    }
                  },
                  backgroundColor: const Color(0xFF069494),
                  child: const Icon(
                    Icons.add_a_photo_outlined,
                    color: Colors.white,
                  ),
                )
              : null,
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
    final title = post['title'] as String?; // Ambil judul dari data

    // PERBAIKAN: Konversi nilai aspect ratio dengan aman
    final aspectRatioValue = post['media_aspect_ratio'];
    final double aspectRatio = (aspectRatioValue as num? ?? 1.0).toDouble();

    // Menggunakan Column untuk layout edge-to-edge
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Postingan (Sekarang hanya judul)
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

        // Konten Media dengan AspectRatio dinamis
        if (mediaUrl != null && mediaType != null)
          AspectRatio(
            aspectRatio: aspectRatio, // Menggunakan nilai yang sudah dikonversi
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

        // Tombol Aksi
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

        // Deskripsi/Caption
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

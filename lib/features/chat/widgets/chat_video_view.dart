import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:video_player/video_player.dart';
class ChatVideoView extends StatefulWidget {
  final String url;
  const ChatVideoView({super.key, required this.url});

  @override
  State<ChatVideoView> createState() => _ChatVideoViewState();
}

class _ChatVideoViewState extends State<ChatVideoView> {
  late VideoPlayerController videoPlayerController;
  ChewieController? _chewieController;

  Future<void> initializePlayer() async {
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.url));

    await Future.wait([
      videoPlayerController.initialize(),
    ]);

    _createChewieController();
    setState(() {});
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: false,
      aspectRatio: videoPlayerController.value.aspectRatio,
    );
    _chewieController?.setVolume(0);
  }

  @override
  void initState() {
    super.initState();

    initializePlayer();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: Stack(
          children: [
            _chewieController != null &&  _chewieController!.videoPlayerController.value.isInitialized ? Stack(
              children: [
                Chewie(controller: _chewieController!),
              ],
            ) : const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

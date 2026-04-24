import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:progress_group/core/constants/colors.dart';
import 'package:progress_group/features/inbox/data/arguments/inbox_detail_args.dart';
import 'package:progress_group/features/inbox/domain/entities/chat_message_entity.dart';
import 'package:progress_group/features/inbox/presentation/state/message/message_bloc.dart';
import 'package:progress_group/features/inbox/presentation/state/message/message_event.dart';
import 'package:progress_group/features/inbox/presentation/state/message/message_state.dart';

class InboxDetailPage extends StatefulWidget {
  final InboxDetailArgs args;
  const InboxDetailPage({super.key, required this.args});

  @override
  State<InboxDetailPage> createState() => _InboxDetailPageState();
}

class _InboxDetailPageState extends State<InboxDetailPage> {
  late ScrollController _scrollController;
  int _page = 1;
  bool _isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _fetchMessages();
  }

  void _onScroll() {
    // Detect scroll to bottom (older messages)
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isFetchingMore) {
      _loadMore();
    }
  }

  void _fetchMessages({int page = 1, bool isLoadMore = false}) {
    context.read<MessageBloc>().add(
      GetChatHistoryEvent(
        sessionId: widget.args.data.sessionCode,
        jid: widget.args.data.jid,
        page: page,
        isLoadMore: isLoadMore,
      ),
    );
  }

  Future<void> _loadMore() async {
    _isFetchingMore = true;
    _page++;
    _fetchMessages(page: _page, isLoadMore: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // --- LOGIKA TANGGAL ---
  String _formatDateHeader(int timestamp) {
    if (timestamp == 0) return "";
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return "Hari ini";
    } else if (messageDate == yesterday) {
      return "Kemarin";
    } else {
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
    }
  }

  bool _shouldShowDate(int index, List messages) {
    if (index == 0) return true;

    final currentMsgDate = DateTime.fromMillisecondsSinceEpoch(messages[index].timestamp * 1000);
    final prevMsgDate = DateTime.fromMillisecondsSinceEpoch(messages[index - 1].timestamp * 1000);

    return currentMsgDate.day != prevMsgDate.day ||
           currentMsgDate.month != prevMsgDate.month ||
           currentMsgDate.year != prevMsgDate.year;
  }
  // ----------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER INFO KONTAK
            Container(
              color: Color(whiteColor),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, color: Color(primaryColor), size: 27),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: widget.args.data.photo != null &&
                                  widget.args.data.photo!.isNotEmpty
                              ? Image.network(
                                  widget.args.data.photo!,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _detailAvatarPlaceholder(),
                                )
                              : _detailAvatarPlaceholder(),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.args.data.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                widget.args.data.ownerName ?? widget.args.data.jid,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            /// KOTAK CHAT HISTORY
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(whiteColor),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Color(shadowColor).withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: BlocBuilder<MessageBloc, MessageState>(
                  builder: (context, state) {
                    if (state is MessageLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is MessageError) {
                      _isFetchingMore = false;
                      return Center(child: Text(state.message));
                    }

                    if (state is MessageLoaded) {
                      _isFetchingMore = state.isFetchingMore;
                      final messages = state.chatHistory.messages;

                      if (messages.isEmpty) {
                        return const Center(child: Text("Tidak ada pesan"));
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length + (state.isFetchingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (state.isFetchingMore && index == messages.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final actualIndex = index;
                          if (actualIndex >= messages.length) return const SizedBox();

                          final msg = messages[actualIndex];
                          final isMe = msg.isFromMe;
                          final senderName = isMe 
                              ? "Saya" 
                              : (msg.senderName ?? widget.args.data.name);

                          return Column(
                            children: [
                              // 1. Tampilkan Tanggal (Jika diperlukan)
                              if (_shouldShowDate(actualIndex, messages))
                                Padding(
                                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Color(grey1Color).withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      _formatDateHeader(msg.timestamp),
                                      style: TextStyle(
                                        color: Color(grey2Color),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                              // 2. Tampilkan Bubble Chat (Dipisah menjadi fungsi)
                              isMe 
                                  ? _buildRightMessage(msg, senderName) 
                                  : _buildLeftMessage(msg, senderName),
                            ],
                          );
                        },
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET FUNGSI CHAT KE KANAN (DARI SAYA)
  // ==========================================
  Widget _buildRightMessage(ChatMessage msg, String senderName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(msg.formattedTime, style: TextStyle(fontSize: 12, color: Color(grey2Color))),
                    const SizedBox(width: 8),
                    Text(senderName, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.all((msg.mediaUrl != null && msg.mediaUrl!.isNotEmpty) ? 4 : 10),
                  decoration: BoxDecoration(
                    color: Color(primaryColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12).copyWith(
                      topLeft: const Radius.circular(12),
                      topRight: Radius.zero,
                    ),
                  ),
                  child: _buildMessageContent(msg), // Panggil isi pesan
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Avatar Lingkaran Admin/Agent
          CircleAvatar(
            radius: 22,
            backgroundColor: Color(grey1Color),
            child: Icon(Icons.support_agent, color: Color(blue3Color)),
          ),
        ],
      ),
    );
  }


  Widget _buildLeftMessage(ChatMessage msg, String senderName) {
    final contactPhoto = widget.args.data.photo;
    final showContactPhoto = contactPhoto != null && contactPhoto.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Avatar Lingkaran Customer
          showContactPhoto
              ? CircleAvatar(
                  radius: 22,
                  foregroundImage: NetworkImage(contactPhoto),
                  backgroundColor: Color(grey1Color),
                  child: widget.args.data.initials.isNotEmpty
                      ? Text(widget.args.data.initials,
                          style: TextStyle(color: Color(blue3Color), fontWeight: FontWeight.bold))
                      : Icon(Icons.person, color: Color(blue3Color)),
                )
              : _detailAvatarPlaceholder(),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(senderName, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Text(msg.formattedTime, style: TextStyle(fontSize: 12, color: Color(grey2Color))),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.all((msg.mediaUrl != null && msg.mediaUrl!.isNotEmpty) ? 4 : 10),
                  decoration: BoxDecoration(
                    color: Color(grey1Color).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12).copyWith(
                      topLeft: Radius.zero,
                      topRight: const Radius.circular(12),
                    ),
                  ),
                  child: _buildMessageContent(msg), // Panggil isi pesan
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET FUNGSI ISI PESAN (GAMBAR & TEKS)
  // ==========================================
  Widget _buildMessageContent(ChatMessage msg) {
    bool isVideo = msg.messageType == 'video';
    String displayBody = msg.body.replaceAll("[REACTION]", "").trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (msg.mediaUrl != null && msg.mediaUrl!.isNotEmpty) ...[
          if (isVideo)
             _VideoPlayerWidget(url: msg.mediaUrl!)
          else
            GestureDetector(
              onTap: () => _showImagePreview(msg.mediaUrl!),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  msg.mediaUrl!,
                  width: MediaQuery.of(context).size.width * 0.6,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 150,
                    color: Color(grey1Color),
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                    ),
                  ),
                ),
              ),
            ),
          if (displayBody.isNotEmpty) const SizedBox(height: 6),
        ],
        if (displayBody.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: (msg.mediaUrl != null && msg.mediaUrl!.isNotEmpty) ? 6 : 0,
              vertical: (msg.mediaUrl != null && msg.mediaUrl!.isNotEmpty) ? 4 : 0,
            ),
            child: Text(
              displayBody,
              softWrap: true,
              style: const TextStyle(fontSize: 14),
            ),
          ),
      ],
    );
  }

  void _showImagePreview(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(child: Image.network(url)),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET AVATAR PLACEHOLDER
  // ==========================================
  Widget _detailAvatarPlaceholder() {
    return CircleAvatar(
      radius: 22, // diameter 44
      backgroundColor: Color(grey1Color),
      child: widget.args.data.initials.isNotEmpty
          ? Text(widget.args.data.initials, style: TextStyle(color: Color(blue3Color), fontWeight: FontWeight.bold))
          : Icon(widget.args.icon, color: Color(blue3Color)),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String url;
  const _VideoPlayerWidget({required this.url});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      errorBuilder: (context, errorMessage) {
        return Center(child: Text(errorMessage, style: const TextStyle(color: Colors.white)));
      },
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Chewie(controller: _chewieController!),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class NotificationPanel extends StatefulWidget {
  final VoidCallback? onChanged;
  const NotificationPanel({super.key, this.onChanged});

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel> {
  static const Color _primaryColor = Color(0xFF8E59B3);

  bool _loading = true;
  List<Map<String, dynamic>> _requests = [];
  final Set<int> _processingIds = {};

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final userId = SupabaseService.instance.currentUser?.id;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final results = await Future.wait([
        SupabaseService.instance.getIncomingFriendRequests(userId),
        SupabaseService.instance.getIncomingMatchRequests(userId),
        SupabaseService.instance.getNotifications(userId),
      ]);

      final friendRequests = results[0].map<Map<String, dynamic>>((r) => {...r, 'type': 'friend'}).toList();
      final matchRequests = results[1].map<Map<String, dynamic>>((r) => {...r, 'type': 'match'}).toList();
      final notifications = results[2].map<Map<String, dynamic>>((r) => {...r, 'type': 'notification'}).toList();

      final combined = [...friendRequests, ...matchRequests, ...notifications];
      
      
      
      // Sort by created_at desc, fallback to id desc
      combined.sort((a, b) {
        DateTime parseDate(dynamic val) {
          if (val == null) return DateTime.fromMillisecondsSinceEpoch(0);
          final s = val.toString();
          if (s.isEmpty || s == 'null') return DateTime.fromMillisecondsSinceEpoch(0);
          final dt = DateTime.tryParse(s);
          if (dt != null) return dt;
          return DateTime.fromMillisecondsSinceEpoch(0);
        }

        final aTime = parseDate(a['created_at']);
        final bTime = parseDate(b['created_at']);
        
        final cmp = bTime.compareTo(aTime);
        if (cmp != 0) return cmp;
        
        // Fallback to ID if times are equal or both missing
        final aId = (a['id'] as num?)?.toInt() ?? 0;
        final bId = (b['id'] as num?)?.toInt() ?? 0;
        return bId.compareTo(aId);
      });

      if (!mounted) return;
      setState(() {
        _requests = combined;
        _loading = false;
      });
      widget.onChanged?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _accept(int requestId, String type) async {
    if (_processingIds.contains(requestId)) return;
    setState(() => _processingIds.add(requestId));
    try {
      if (type == 'friend') {
        await SupabaseService.instance.acceptFriendRequest(requestId);
      } else {
        await SupabaseService.instance.acceptMatchRequest(requestId);
      }
      if (!mounted) return;
      setState(() {
        _requests.removeWhere((r) => (r['id'] as int) == requestId && r['type'] == type);
        _processingIds.remove(requestId);
      });
      widget.onChanged?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(type == 'friend'
              ? 'Permintaan pertemanan diterima! 🎉'
              : 'Permintaan match diterima! 🎉'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _processingIds.remove(requestId));
    }
  }

  Future<void> _reject(int requestId, String type) async {
    if (_processingIds.contains(requestId)) return;
    setState(() => _processingIds.add(requestId));
    try {
      if (type == 'friend') {
        await SupabaseService.instance.rejectFriendRequest(requestId);
      } else if (type == 'match') {
        await SupabaseService.instance.rejectMatchRequest(requestId);
      } else if (type == 'notification') {
        await SupabaseService.instance.deleteNotification(requestId);
      }
      if (!mounted) return;
      setState(() {
        _requests.removeWhere((r) => (r['id'] as int) == requestId && r['type'] == type);
        _processingIds.remove(requestId);
      });
      widget.onChanged?.call();
    } catch (_) {
      if (!mounted) return;
      setState(() => _processingIds.remove(requestId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E3FC),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifikasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2D2132),
                  ),
                ),
                Row(
                  children: [
                    if (_requests.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_requests.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: _loadRequests,
                      child: Icon(Icons.refresh_rounded,
                          size: 20, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                  child: CircularProgressIndicator(color: _primaryColor)),
            )
          else if (_requests.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.notifications_none_rounded,
                        size: 32, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    const Text(
                      'Belum ada notifikasi',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2132)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Permintaan pertemanan dan pembaruan\nlainnya akan muncul di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          height: 1.4),
                    ),
                  ],
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: _requests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _buildRequestItem(_requests[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRequestItem(Map<String, dynamic> request) {
    final requestId = request['id'] as int;
    final type = request['type'] as String? ?? 'friend';
    final sender = request['sender'] as Map<String, dynamic>?;
    final username = sender?['username'] as String? ?? 'Pengguna';
    final profilePic = sender?['profile_picture'] as String?;
    final hasImage = profilePic != null &&
        profilePic.isNotEmpty &&
        profilePic != 'default.png';
    final isProcessing = _processingIds.contains(requestId);

    final text = type == 'friend'
        ? '$username ingin berteman dengan anda'
        : type == 'match'
            ? '$username mengajak anda mencocokkan MBTI'
            : request['message'] as String? ?? 'Notifikasi baru';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
                color: Color(0xFFFCE3EC), shape: BoxShape.circle),
            clipBehavior: Clip.antiAlias,
            child: type == 'notification'
                ? const Icon(Icons.favorite, size: 22, color: Colors.redAccent)
                : hasImage
                    ? Image.network(
                        profilePic,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(Icons.person,
                            size: 22, color: Colors.grey),
                      )
                    : const Icon(Icons.person, size: 22, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2132),
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isProcessing)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: _primaryColor),
            )
          else if (type != 'notification')
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildChip(
                    label: 'Setuju',
                    color: _primaryColor,
                    onTap: () => _accept(requestId, type)),
                const SizedBox(width: 6),
                _buildChip(
                    label: 'Tolak',
                    color: Colors.grey[400]!,
                    onTap: () => _reject(requestId, type)),
              ],
            )
          else
            GestureDetector(
              onTap: () => _reject(requestId, type),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 18,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChip(
      {required String label,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
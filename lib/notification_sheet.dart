import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import 'widgets/mbti_avatar.dart';

class NotificationPanel extends StatefulWidget {
  const NotificationPanel({super.key});

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel> {
  static const Color _primaryColor = Color(0xFF8E59B3);

  bool _loading = true;
  List<Map<String, dynamic>> _requests = [];
  final Set<int> _processingIds = {};
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _loadRequests();
    _setupRealtime();
  }

  void _setupRealtime() {
    final userId = SupabaseService.instance.currentUser?.id;
    if (userId == null) return;

    _channel = Supabase.instance.client
        .channel('public:friend_requests_sheet')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'friend_requests',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'receiver_id',
            value: userId,
          ),
          callback: (payload) {
            // Jika ada perubahan pada tabel, refresh data notifikasi
            _loadRequests();
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  Future<void> _loadRequests() async {
  if (!mounted) return;
  setState(() => _loading = true);

  final userId = SupabaseService.instance.currentUser?.id;
  
  // Tambah ini untuk debug
  print('=== NOTIF DEBUG ===');
  print('currentUser?.id: $userId');
  
  if (userId == null) {
    print('userId NULL — berhenti');
    setState(() => _loading = false);
    return;
  }

  try {
    final requests =
        await SupabaseService.instance.getIncomingFriendRequests(userId);
    
    // Tambah ini juga
    print('Jumlah request masuk: ${requests.length}');
    print('Data: $requests');
    
    if (!mounted) return;
    setState(() {
      _requests = requests;
      _loading = false;
    });
  } catch (e) {
    print('ERROR: $e'); // Sudah ada tapi pastikan dilihat
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error Notif: $e'),
        duration: const Duration(seconds: 10),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  Future<void> _accept(int requestId) async {
    if (_processingIds.contains(requestId)) return;
    setState(() => _processingIds.add(requestId));
    try {
      await SupabaseService.instance.acceptFriendRequest(requestId);
      if (!mounted) return;
      setState(() {
        _requests.removeWhere((r) => (r['id'] as int) == requestId);
        _processingIds.remove(requestId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Permintaan pertemanan diterima! 🎉'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('DEBUG accept error: $e');
      if (!mounted) return;
      setState(() => _processingIds.remove(requestId));
    }
  }

  Future<void> _reject(int requestId) async {
    if (_processingIds.contains(requestId)) return;
    setState(() => _processingIds.add(requestId));
    try {
      await SupabaseService.instance.rejectFriendRequest(requestId);
      if (!mounted) return;
      setState(() {
        _requests.removeWhere((r) => (r['id'] as int) == requestId);
        _processingIds.remove(requestId);
      });
    } catch (e) {
      print('DEBUG reject error: $e');
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
          // Header
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
                    // Tombol refresh manual
                    GestureDetector(
                      onTap: _loadRequests,
                      child: Icon(
                        Icons.refresh_rounded,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(color: _primaryColor),
              ),
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
                    Text(
                      'Kosong. ID Anda:\n${SupabaseService.instance.currentUser?.id}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2132),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Permintaan pertemanan dan pembaruan\nlainnya akan muncul di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.separated(
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
    final sender = request['sender'] as Map<String, dynamic>?;
    final username = sender?['username'] as String? ?? 'Pengguna';
    final avatarEmoji = sender?['avatar_emoji'] as String?;
    final isProcessing = _processingIds.contains(requestId);

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
          // Avatar
          MbtiAvatar(mbtiCode: avatarEmoji, size: 44),
          const SizedBox(width: 12),

          // Teks
          Expanded(
            child: Text(
              '$username ingin berteman dengan anda',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2132),
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Tombol atau loading
          if (isProcessing)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _primaryColor,
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildChip(
                  label: 'Setuju',
                  color: _primaryColor,
                  onTap: () => _accept(requestId),
                ),
                const SizedBox(width: 6),
                _buildChip(
                  label: 'Tolak',
                  color: Colors.grey[400]!,
                  onTap: () => _reject(requestId),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
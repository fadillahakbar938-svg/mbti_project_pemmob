import 'package:flutter/material.dart';

import '../services/supabase_service.dart';

class CardDetailPage extends StatefulWidget {
  final String code;
  final String title;
  final String emoji;

  const CardDetailPage({
    super.key,
    required this.code,
    required this.title,
    required this.emoji,
  });

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  bool _isLoading = true;
  String _summary = 'Memuat deskripsi kepribadian...';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await SupabaseService.instance.getMbtiProfile(widget.code);
      if (profile != null) {
        _summary = profile['description'] ?? profile['short_description'] ?? 'Deskripsi belum tersedia untuk tipe ini.';
      } else {
        _summary = 'Deskripsi belum tersedia untuk tipe ini.';
      }
    } catch (_) {
      _summary = 'Gagal memuat deskripsi.';
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D2132)),
        title: Text(widget.code, style: const TextStyle(color: Color(0xFF2D2132))),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'card-${widget.code}',
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(widget.emoji, style: const TextStyle(fontSize: 80)),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                if (_isLoading)
                  const CircularProgressIndicator(color: Color(0xFF8E59B3))
                else
                  Text(
                    _summary,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.4),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

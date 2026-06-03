import 'package:flutter/material.dart';

/// Panel notifikasi dropdown (desain lavender) — overlay di dashboard.
class NotificationPanel extends StatelessWidget {
  const NotificationPanel({super.key});

  static const Color _panelBg = Color(0xFFF3E8FF);
  static const Color _textDark = Color(0xFF2D2132);
  static const Color _textMuted = Color(0xFF7D6F83);
  static const Color _avatarPlaceholder = Color(0xFFFCE3EC);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 16,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        decoration: BoxDecoration(
          color: _panelBg,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification',
              style: TextStyle(
                color: _textDark,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            _buildEmptyStateCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: _avatarPlaceholder,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Belum ada notifikasi',
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Permintaan pertemanan dan pembaruan lainnya akan muncul di sini.',
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu permintaan pertemanan — dipakai saat ada data notifikasi.
class FriendRequestNotificationCard extends StatelessWidget {
  const FriendRequestNotificationCard({
    super.key,
    required this.username,
    this.onApprove,
    this.onReject,
  });

  final String username;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  static const Color _textDark = Color(0xFF2D2132);
  static const Color _purpleMain = Color(0xFF8B5CF6);
  static const Color _purpleLightBtn = Color(0xFFF5F3FF);
  static const Color _avatarPlaceholder = Color(0xFFFCE3EC);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: _avatarPlaceholder,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _textDark,
                      height: 1.35,
                    ),
                    children: [
                      TextSpan(
                        text: username,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const TextSpan(
                        text: ' ingin berteman dengan anda',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Setujui',
                  backgroundColor: _purpleMain,
                  textColor: Colors.white,
                  onTap: onApprove,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  label: 'Tolak',
                  backgroundColor: _purpleLightBtn,
                  textColor: _textDark,
                  onTap: onReject,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ButtonSection extends StatefulWidget {
  const ButtonSection({super.key});

  @override
  _BottomButtonSectionState createState() => _BottomButtonSectionState();
}

class _BottomButtonSectionState extends State<ButtonSection> {
  bool isWatchlistSelected = false;
  bool isReminderSelected = false;
  bool isShareSelected = false;
  bool isCommentsSelected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildButton(
            icon: Icons.notifications,
            label: 'Reminder',
            isSelected: isReminderSelected,
            onTap: () {
              setState(() {
                isReminderSelected = !isReminderSelected;
              });
            },
          ),
          _buildButton(
            icon: Icons.share_outlined,
            label: 'Share',
            isSelected: isShareSelected,
            onTap: () {
              setState(() {
                isShareSelected = !isShareSelected;
              });
              final String videoUrl =
                  'https://example.com/your-video-link';
              Share.share('Check out this video: $videoUrl',
                  subject: 'Amazing Video');
            },
          ),
          _buildButton(
            icon: Icons.comment_outlined,
            label: 'Comments',
            isSelected: isCommentsSelected,
            onTap: () {
              setState(() {
                isCommentsSelected = !isCommentsSelected;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

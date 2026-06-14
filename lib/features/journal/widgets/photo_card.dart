import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/models/models.dart';
import '../journal_detail_screen.dart';

class PhotoCard extends StatelessWidget {
  final JournalEntry entry;
  final bool isSelected;
  final bool isCompareMode;
  final VoidCallback onToggleSelection;

  const PhotoCard({
    super.key,
    required this.entry,
    required this.isSelected,
    required this.isCompareMode,
    required this.onToggleSelection,
  });

  Widget _photoPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      child: Icon(Icons.face, color: isDark ? Colors.grey.shade600 : Colors.grey, size: 40),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLocalFile = (entry.photoPath?.startsWith('/') ?? false) || (entry.photoPath?.startsWith('C:') ?? false);
    final bool isNetwork = entry.photoPath?.startsWith('http') ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (isCompareMode) {
          onToggleSelection();
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JournalDetailScreen(entry: entry),
            ),
          );
        }
      },
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.pinkAccent : (isDark ? Colors.white30 : Colors.black),
            width: isSelected ? 2.5 : 1.2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            ClipRRect(
              borderRadius: BorderRadius.circular(2.5),
              child: isLocalFile
                  ? Image.file(
                      File(entry.photoPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => _photoPlaceholder(context),
                    )
                  : isNetwork
                      ? Image.network(
                          entry.photoPath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => _photoPlaceholder(context),
                        )
                      : _photoPlaceholder(context),
            ),

            // Notes Overlay snippet if notes exist
            if (entry.notes != null && entry.notes!.isNotEmpty)
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Text(
                    entry.notes!,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

            // Date overlay bottom-left
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  border: Border.all(color: isDark ? Colors.white30 : Colors.black, width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  entry.loggedDate,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),

            // Score overlay bottom-right
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.pink.shade900.withValues(alpha: 0.4) : Colors.pink.shade50,
                  border: Border.all(color: isDark ? Colors.white30 : Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(2),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'Score ${entry.skinScore}',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.pink.shade300 : Colors.pinkAccent,
                  ),
                ),
              ),
            ),

            // Selection Circle Indicator
            if (isCompareMode)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.pinkAccent : (isDark ? Colors.black.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8)),
                    border: Border.all(color: isDark ? Colors.white : Colors.black, width: 1.5),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

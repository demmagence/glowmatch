import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'journal_viewmodel.dart';
import '../../core/viewmodels/auth_viewmodel.dart';
import '../../core/models/models.dart';
import '../profile/profile_screen.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/widgets/error_state_widget.dart';
import 'journal_chart_widget.dart';
import 'journal_detail_screen.dart';
import 'journal_compare_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  bool _isCompareMode = false;
  final Set<String> _selectedEntryIds = {};

  DateTime _parseLoggedDate(String dateStr) {
    final now = DateTime.now();
    if (dateStr.toLowerCase() == 'today') {
      return DateTime(now.year, now.month, now.day);
    }
    final parts = dateStr.trim().split(' ');
    if (parts.length >= 2) {
      final monthStr = parts[0].toLowerCase();
      final dayStr = parts[1];
      final day = int.tryParse(dayStr) ?? 1;
      int month = now.month;
      const months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
      final idx = months.indexOf(monthStr);
      if (idx != -1) {
        month = idx + 1;
      }
      return DateTime(now.year, month, day);
    }
    return now;
  }

  String _getWeekLabel(DateTime entryDate, DateTime now) {
    final entryDay = DateTime(entryDate.year, entryDate.month, entryDate.day);
    final today = DateTime(now.year, now.month, now.day);
    final diffDays = today.difference(entryDay).inDays;

    if (diffDays < 0) {
      return 'This Week';
    }
    if (diffDays < 7) {
      return 'This Week';
    } else if (diffDays < 14) {
      return 'Last Week';
    } else {
      final weeks = diffDays ~/ 7;
      return '$weeks Weeks Ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final journalVm = Provider.of<JournalViewModel>(context);
    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final borderColor = isDark ? Colors.white : Colors.black;
    final shadowColor = isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black;

    // Fallback stock images if no real photo
    final List<String> mockImageUrls = [
      'https://images.unsplash.com/photo-1512290923902-8a9f81dc236c?auto=format&fit=crop&q=80&w=400',
      'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&q=80&w=400',
      'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?auto=format&fit=crop&q=80&w=400',
    ];

    // Merge real entries + mock for display
    final List<JournalEntry> displayEntries = journalVm.entries.isNotEmpty
        ? journalVm.entries
        : [
            JournalEntry(
              id: 'j-mock-1',
              loggedDate: 'Today',
              photoPath: mockImageUrls[0],
              skinScore: 84,
              notes: 'Skin feels deeply hydrated and bright today.',
            ),
            JournalEntry(
              id: 'j-mock-2',
              loggedDate: 'Oct 24',
              photoPath: mockImageUrls[1],
              skinScore: 80,
              notes: 'Slight redness on cheeks. Sticking to cleanser.',
            ),
            JournalEntry(
              id: 'j-mock-3',
              loggedDate: 'Oct 17',
              photoPath: mockImageUrls[2],
              skinScore: 76,
              notes: 'Starting my regular morning and evening routines.',
            ),
          ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: RichText(
          text: TextSpan(
            text: 'GlowMatch',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: textColor,
              letterSpacing: -0.5,
            ),
            children: const [
              TextSpan(
                text: '.',
                style: TextStyle(color: Colors.red, fontSize: 26),
              )
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isCompareMode ? Icons.close : Icons.compare_arrows,
              color: textColor,
            ),
            tooltip: _isCompareMode ? 'Cancel Compare' : 'Compare Mode',
            onPressed: () {
              setState(() {
                _isCompareMode = !_isCompareMode;
                _selectedEntryIds.clear();
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle_outlined, color: textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: journalVm.isUploading,
        message: 'Uploading your glow...',
        child: RefreshIndicator(
          onRefresh: () => journalVm.fetchJournal(authVm.userId),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (journalVm.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 64.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (journalVm.errorMessage != null)
                  ErrorStateWidget(
                    message: journalVm.errorMessage!,
                    onRetry: () => journalVm.fetchJournal(authVm.userId),
                  )
                else ...[
                  // ── Header Row: Title + Score ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Journal',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Track your glow progress.',
                            style: TextStyle(
                              fontSize: 14,
                              color: subtextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      // Consistency Score Badge
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${journalVm.currentScore}',
                                style: TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w900,
                                  color: textColor,
                                  letterSpacing: -2,
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(left: 2),
                                decoration: const BoxDecoration(
                                  color: Colors.pinkAccent,
                                  shape: BoxShape.rectangle,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'CURRENT SCORE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: isDark ? Colors.white24 : Colors.grey.shade300),
                  const SizedBox(height: 20),

                  // ── Skin Progress Line Chart ──
                  JournalChartWidget(entries: displayEntries),
                  const SizedBox(height: 32),

                  // ── Photo Grid — grouped into pairs ──
                  ..._buildPhotoGrid(context, displayEntries, authVm.userId, journalVm),
                ],
                const SizedBox(height: 100), // bottom padding for FAB / BottomSheet
              ],
            ),
          ),
        ),
      ),

      // ── FAB: Camera picker ──
      floatingActionButton: journalVm.isUploading || _isCompareMode
          ? null
          : FloatingActionButton(
              backgroundColor: isDark ? Colors.white : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
              shape: const CircleBorder(),
              tooltip: 'Add Progress Photo',
              onPressed: () => _showPhotoSourceSheet(context, authVm.userId, journalVm),
              child: const Icon(Icons.add_a_photo_outlined),
            ),

      // ── Floating comparison bottom banner ──
      bottomSheet: _selectedEntryIds.isEmpty
          ? null
          : Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                border: Border.all(color: borderColor, width: 2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    offset: const Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selected: ${_selectedEntryIds.length}/2 entries',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedEntryIds.length == 2
                          ? (isDark ? Colors.white : Colors.black)
                          : (isDark ? Colors.grey.shade800 : Colors.grey.shade400),
                      foregroundColor: _selectedEntryIds.length == 2
                          ? (isDark ? Colors.black : Colors.white)
                          : (isDark ? Colors.white30 : Colors.white60),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(color: borderColor, width: 1.5),
                      ),
                    ),
                    onPressed: _selectedEntryIds.length == 2
                        ? () {
                            final selectedList = displayEntries.where((x) => _selectedEntryIds.contains(x.id)).toList();
                            if (selectedList.length == 2) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JournalCompareScreen(
                                    entryA: selectedList[0],
                                    entryB: selectedList[1],
                                  ),
                                ),
                              ).then((_) {
                                // Clear selection when returning
                                setState(() {
                                  _selectedEntryIds.clear();
                                  _isCompareMode = false;
                                });
                              });
                            }
                          }
                        : null,
                    child: const Text('Compare', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
    );
  }

  // ── Build photo rows (2 per row) ──
  List<Widget> _buildPhotoGrid(
    BuildContext context,
    List<JournalEntry> entries,
    String userId,
    JournalViewModel vm,
  ) {
    final List<Widget> rows = [];
    final now = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Group by week label based on real DateTime values
    final sections = <String, List<JournalEntry>>{};
    for (final entry in entries) {
      final entryDate = _parseLoggedDate(entry.loggedDate);
      final label = _getWeekLabel(entryDate, now).toUpperCase();
      sections.putIfAbsent(label, () => []);
      sections[label]!.add(entry);
    }

    sections.forEach((sectionLabel, sectionEntries) {
      rows.add(
        Text(
          sectionLabel,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: isDark ? Colors.grey.shade400 : Colors.black87,
          ),
        ),
      );
      rows.add(const SizedBox(height: 16));

      // Pair up entries in rows of 2
      for (int i = 0; i < sectionEntries.length; i += 2) {
        final a = sectionEntries[i];
        final b = i + 1 < sectionEntries.length ? sectionEntries[i + 1] : null;

        rows.add(Row(
          children: [
            Expanded(
              child: _buildPhotoCard(
                context: context,
                entry: a,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: b != null
                  ? _buildPhotoCard(
                      context: context,
                      entry: b,
                    )
                  : _buildEmptySlot(context, userId, vm),
            ),
          ],
        ));
        rows.add(const SizedBox(height: 16));
      }

      rows.add(const SizedBox(height: 16));
    });

    return rows;
  }

  // ── Single photo card ──
  Widget _buildPhotoCard({
    required BuildContext context,
    required JournalEntry entry,
  }) {
    final bool isSelected = _selectedEntryIds.contains(entry.id);
    final bool isLocalFile = (entry.photoPath?.startsWith('/') ?? false) || (entry.photoPath?.startsWith('C:') ?? false);
    final bool isNetwork = entry.photoPath?.startsWith('http') ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (_isCompareMode) {
          setState(() {
            if (isSelected) {
              _selectedEntryIds.remove(entry.id);
            } else {
              if (_selectedEntryIds.length < 2) {
                _selectedEntryIds.add(entry.id);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You can only select up to 2 entries for comparison.'),
                    duration: Duration(milliseconds: 1500),
                  ),
                );
              }
            }
          });
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
            if (_isCompareMode)
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

  // ── Empty slot — tap to add photo ──
  Widget _buildEmptySlot(BuildContext context, String userId, JournalViewModel vm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _showPhotoSourceSheet(context, userId, vm),
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade400, width: 1.2),
          borderRadius: BorderRadius.circular(4),
          color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 32, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'Add Photo',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      child: Icon(Icons.face, color: isDark ? Colors.grey.shade600 : Colors.grey, size: 40),
    );
  }

  // ── Bottom sheet: pilih Camera atau Gallery ──
  void _showPhotoSourceSheet(BuildContext context, String userId, JournalViewModel vm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ADD PROGRESS PHOTO',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose how to capture your glow.',
                  style: TextStyle(fontSize: 13, color: subtextColor),
                ),
                const SizedBox(height: 24),

                // Camera option
                _sourceOption(
                  context: context,
                  icon: Icons.camera_alt_outlined,
                  label: 'Take Photo',
                  subtitle: 'Use camera right now',
                  onTap: () async {
                    Navigator.pop(context);
                    await _doUpload(context, userId, vm, ImageSource.camera);
                  },
                ),
                const SizedBox(height: 12),

                // Gallery option
                _sourceOption(
                  context: context,
                  icon: Icons.photo_library_outlined,
                  label: 'Choose from Gallery',
                  subtitle: 'Pick an existing photo',
                  onTap: () async {
                    Navigator.pop(context);
                    await _doUpload(context, userId, vm, ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sourceOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? Colors.white : Colors.black,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isDark ? Colors.black : Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: subtextColor),
          ],
        ),
      ),
    );
  }

  Future<void> _doUpload(
    BuildContext context,
    String userId,
    JournalViewModel vm,
    ImageSource source,
  ) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1080,
        maxHeight: 1920,
      );

      if (picked == null) return; // cancelled

      if (!context.mounted) return;

      final isDark = Theme.of(context).brightness == Brightness.dark;
      final textColor = isDark ? Colors.white : Colors.black;
      final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
      final borderColor = isDark ? Colors.white : Colors.black;

      // Show preview and notes dialog
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          final notesController = TextEditingController();
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: borderColor, width: 2),
            ),
            title: Text(
              'Add Progress Note',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image preview
                  Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor, width: 1.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2.5),
                      child: Image.file(
                        File(picked.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'How does your skin feel today? (optional)',
                      hintStyle: TextStyle(color: subtextColor, fontSize: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: borderColor, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: borderColor, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: borderColor, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('Cancel', style: TextStyle(color: textColor)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(dialogContext); // dismiss dialog

                  // Show uploading overlay or notify loading via VM
                  final notesText = notesController.text.trim();
                  final success = await vm.addJournalEntryWithPhoto(
                    userId: userId,
                    localFilePath: picked.path,
                    notes: notesText,
                  );

                  if (context.mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '📸 Skin log uploaded! Score updated.',
                            style: TextStyle(color: isDark ? Colors.black : Colors.white),
                          ),
                          backgroundColor: isDark ? Colors.white : Colors.black,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Upload failed. Try again.',
                            style: TextStyle(color: isDark ? Colors.black : Colors.white),
                          ),
                          backgroundColor: isDark ? Colors.white : Colors.black,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Log Progress', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }
}

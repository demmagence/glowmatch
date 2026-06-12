import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'journal_viewmodel.dart';
import '../../core/viewmodels/auth_viewmodel.dart';
import '../../core/models/models.dart';
import '../profile/profile_screen.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final journalVm = Provider.of<JournalViewModel>(context);
    final authVm = Provider.of<AuthViewModel>(context, listen: false);

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
            JournalEntry(id: 'j-mock-1', loggedDate: 'Today', photoPath: mockImageUrls[0], skinScore: 84),
            JournalEntry(id: 'j-mock-2', loggedDate: 'Oct 24', photoPath: mockImageUrls[1], skinScore: 80),
            JournalEntry(id: 'j-mock-3', loggedDate: 'Oct 17', photoPath: mockImageUrls[2], skinScore: 76),
          ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'GLOWMATCH',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: Colors.black,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header Row: Title + Score ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Journal',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Track your glow progress.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
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
                              style: const TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
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
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 20),

                // ── Photo Grid — grouped into pairs ──
                ..._buildPhotoGrid(context, displayEntries, authVm.userId, journalVm),

                const SizedBox(height: 100), // bottom padding for FAB
              ],
            ),
          ),

          // ── Uploading Overlay ──
          if (journalVm.isUploading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Uploading your glow...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),

      // ── FAB: Camera picker ──
      floatingActionButton: journalVm.isUploading
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              tooltip: 'Add Progress Photo',
              onPressed: () => _showPhotoSourceSheet(context, authVm.userId, journalVm),
              child: const Icon(Icons.add_a_photo_outlined),
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

    // Group by week label — simplified: first 2 = "THIS WEEK", rest = "OLDER"
    final sections = <String, List<JournalEntry>>{};
    for (int i = 0; i < entries.length; i++) {
      final label = i < 2 ? 'THIS WEEK' : 'OLDER';
      sections.putIfAbsent(label, () => []);
      sections[label]!.add(entries[i]);
    }

    sections.forEach((sectionLabel, sectionEntries) {
      rows.add(
        Text(
          sectionLabel,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
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
                date: a.loggedDate,
                photoPath: a.photoPath ?? '',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: b != null
                  ? _buildPhotoCard(
                      context: context,
                      date: b.loggedDate,
                      photoPath: b.photoPath ?? '',
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
    required String date,
    required String photoPath,
  }) {
    final bool isLocalFile = photoPath.startsWith('/') || photoPath.startsWith('C:');
    final bool isNetwork = photoPath.startsWith('http');

    return Container(
      height: 190,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.2),
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
                    File(photoPath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => _photoPlaceholder(),
                  )
                : isNetwork
                    ? Image.network(
                        photoPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => _photoPlaceholder(),
                      )
                    : _photoPlaceholder(),
          ),
          // Date overlay bottom-left
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                date,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty slot — tap to add photo ──
  Widget _buildEmptySlot(BuildContext context, String userId, JournalViewModel vm) {
    return GestureDetector(
      onTap: () => _showPhotoSourceSheet(context, userId, vm),
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400, width: 1.2),
          borderRadius: BorderRadius.circular(4),
          color: Colors.grey.shade50,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 32, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'Add Photo',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.face, color: Colors.grey, size: 40),
    );
  }

  // ── Bottom sheet: pilih Camera atau Gallery ──
  void _showPhotoSourceSheet(BuildContext context, String userId, JournalViewModel vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
                const Text(
                  'ADD PROGRESS PHOTO',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose how to capture your glow.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
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
    final success = await vm.pickAndUploadPhoto(
      userId: userId,
      source: source,
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📸 Skin log uploaded! Score updated.'),
          backgroundColor: Colors.black,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Upload cancelled or failed. Try again.'),
          backgroundColor: Colors.grey.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

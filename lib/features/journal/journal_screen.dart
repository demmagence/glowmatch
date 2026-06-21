import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'journal_viewmodel.dart';
import '../../core/viewmodels/auth_viewmodel.dart';
import '../../core/models/models.dart';
import '../../core/widgets/glowmatch_header.dart';
import '../../core/widgets/loading_overlay.dart';
import '../../core/widgets/error_state_widget.dart';
import 'journal_chart_widget.dart';
import 'journal_compare_screen.dart';
import 'widgets/photo_grid_widget.dart';
import 'widgets/photo_source_sheet.dart';
import 'widgets/add_progress_note_dialog.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  bool _isCompareMode = false;
  final Set<String> _selectedEntryIds = {};

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

      if (picked == null) return;

      if (!context.mounted) return;

      showAddProgressNoteDialog(
        context: context,
        userId: userId,
        vm: vm,
        pickedPath: picked.path,
      );
    } catch (e) {
      debugPrint('Error picking image: $e');
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
    final shadowColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black;

    final List<String> mockImageUrls = [
      'https://images.unsplash.com/photo-1512290923902-8a9f81dc236c?auto=format&fit=crop&q=80&w=400',
      'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&q=80&w=400',
      'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?auto=format&fit=crop&q=80&w=400',
    ];

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
      body: LoadingOverlay(
        isLoading: journalVm.isUploading,
        message: 'Uploading your glow...',
        child: RefreshIndicator(
          onRefresh: () => journalVm.fetchJournal(authVm.userId),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(child: GlowMatchHeader()),
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
                  ],
                ),
                const SizedBox(height: 8),
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
                  Divider(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                  const SizedBox(height: 20),

                  JournalChartWidget(entries: displayEntries),
                  const SizedBox(height: 32),

                  PhotoGridWidget(
                    entries: displayEntries,
                    userId: authVm.userId,
                    vm: journalVm,
                    selectedEntryIds: _selectedEntryIds,
                    isCompareMode: _isCompareMode,
                    onToggleSelection: (id) {
                      setState(() {
                        if (_selectedEntryIds.contains(id)) {
                          _selectedEntryIds.remove(id);
                        } else {
                          if (_selectedEntryIds.length < 2) {
                            _selectedEntryIds.add(id);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'You can only select up to 2 entries for comparison.',
                                ),
                                duration: Duration(milliseconds: 1500),
                              ),
                            );
                          }
                        }
                      });
                    },
                    onShowPhotoSourceSheet: (ctx, uid, v) =>
                        showPhotoSourceSheet(ctx, uid, v, _doUpload),
                  ),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: journalVm.isUploading || _isCompareMode
          ? null
          : FloatingActionButton(
              backgroundColor: isDark ? Colors.white : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
              shape: const CircleBorder(),
              tooltip: 'Add Progress Photo',
              onPressed: () => showPhotoSourceSheet(
                context,
                authVm.userId,
                journalVm,
                _doUpload,
              ),
              child: const Icon(Icons.add_a_photo_outlined),
            ),
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedEntryIds.length == 2
                          ? (isDark ? Colors.white : Colors.black)
                          : (isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade400),
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
                            final selectedList = displayEntries
                                .where((x) => _selectedEntryIds.contains(x.id))
                                .toList();
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
                                setState(() {
                                  _selectedEntryIds.clear();
                                  _isCompareMode = false;
                                });
                              });
                            }
                          }
                        : null,
                    child: const Text(
                      'Compare',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glowmatch/l10n/app_localizations.dart';
import '../../core/models/models.dart';
import 'journal_viewmodel.dart';
import '../../core/viewmodels/auth_viewmodel.dart';

class JournalDetailScreen extends StatelessWidget {
  final JournalEntry entry;

  const JournalDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authVm = Provider.of<AuthViewModel>(context, listen: false);
    final journalVm = Provider.of<JournalViewModel>(context, listen: false);

    final bool isLocalFile =
        (entry.photoPath?.startsWith('/') ?? false) ||
        (entry.photoPath?.startsWith('C:') ?? false);
    final bool isNetwork = entry.photoPath?.startsWith('http') ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.logEntry,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 380,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: isLocalFile
                    ? Image.file(
                        File(entry.photoPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => _placeholder(),
                      )
                    : isNetwork
                    ? Image.network(
                        entry.photoPath!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    entry.loggedDate.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),

                Row(
                  children: [
                    Text(
                      l10n.scoreLabel(0).split(':').first,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade50,
                        border: Border.all(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${entry.skinScore}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.pinkAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              l10n.notesUpper,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                (entry.notes == null || entry.notes!.isEmpty)
                    ? l10n.noNotesLogged
                    : entry.notes!,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8A80),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                onPressed: () =>
                    _confirmDelete(context, authVm.userId, journalVm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.delete_outline, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.deleteLogEntry,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.face, color: Colors.grey, size: 60),
    );
  }

  void _confirmDelete(
    BuildContext context,
    String userId,
    JournalViewModel vm,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          title: Text(
            l10n.deleteEntryDialogTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(l10n.deleteEntryConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                l10n.cancel,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A80),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Colors.black, width: 1.5),
                ),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                await vm.deleteEntry(entry.id, userId);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.entryDeletedSnackbar),
                      backgroundColor: Colors.black,
                    ),
                  );
                }
              },
              child: Text(
                l10n.delete,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'journal_viewmodel.dart';
import '../../core/viewmodels/auth_viewmodel.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final journalVm = Provider.of<JournalViewModel>(context);
    final authVm = Provider.of<AuthViewModel>(context);

    // Hardcoded high-resolution premium skincare portraits for visual wow factor
    final List<String> mockImageUrls = [
      'https://images.unsplash.com/photo-1512290923902-8a9f81dc236c?auto=format&fit=crop&q=80&w=400',
      'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&q=80&w=400',
      'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?auto=format&fit=crop&q=80&w=400',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
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
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Score Header Row
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

            // Section 1: This Week
            const Text(
              'THIS WEEK',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            
            // Grid of items for This Week
            Row(
              children: [
                Expanded(
                  child: _buildProgressCard(
                    date: 'Today',
                    imageUrl: mockImageUrls[0],
                    context: context,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProgressCard(
                    date: 'Oct 24',
                    imageUrl: mockImageUrls[1],
                    context: context,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Section 2: Last Week
            const Text(
              'LAST WEEK',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildProgressCard(
                    date: 'Oct 17',
                    imageUrl: mockImageUrls[2],
                    context: context,
                  ),
                ),
                const SizedBox(width: 16),
                // Empty photo card as in design (Oct 15 placeholder)
                Expanded(
                  child: GestureDetector(
                    onTap: () => _simulateAddPhoto(context, authVm.userId, journalVm),
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400, width: 1.2),
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.grey.shade50,
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 32,
                              color: Colors.grey,
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 12,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              child: const Text(
                                'Oct 15',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () => _simulateAddPhoto(context, authVm.userId, journalVm),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProgressCard({
    required String date,
    required String imageUrl,
    required BuildContext context,
  }) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Skin Closeup Picture
          ClipRRect(
            borderRadius: BorderRadius.circular(2.5),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.person, color: Colors.grey),
                );
              },
            ),
          ),
          // Date overlay label (bottom-left)
          Positioned(
            bottom: 12,
            left: 12,
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

  void _simulateAddPhoto(BuildContext context, String userId, JournalViewModel vm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Progress Log', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Simulate uploading skin progress photo to Supabase storage. Consistency score will be updated.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () {
                vm.addEntry(
                  userId: userId,
                  photoPath: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9',
                  score: 86,
                  notes: 'Routine completion log added photo.',
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Skin log photo uploaded successfully!'),
                    backgroundColor: Colors.black,
                  ),
                );
              },
              child: const Text('Upload', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

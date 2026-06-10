import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routine_viewmodel.dart';
import '../../core/viewmodels/auth_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routineVm = Provider.of<RoutineViewModel>(context);
    final authVm = Provider.of<AuthViewModel>(context);
    final weather = routineVm.weather;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: GlowMatch.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: const TextSpan(
                    text: 'GlowMatch',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                    children: [
                      TextSpan(
                        text: '.',
                        style: TextStyle(color: Colors.red, fontSize: 32),
                      )
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle_outlined, size: 28),
                  onPressed: () {
                    // Profile screen integration
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Title and Weather Metadata
            Text(
              routineVm.activeRoutine == 'AM' ? 'Morning Routine' : 'Evening Routine',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.wb_sunny_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  weather != null
                      ? '${weather.locationName} • ${weather.temperature.toStringAsFixed(0)}°C'
                      : 'Los Angeles, CA • 33°C',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // AM / PM Switcher Toggles
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: _buildToggleItem(
                      label: 'AM',
                      isActive: routineVm.activeRoutine == 'AM',
                      onTap: () => routineVm.setActiveRoutine('AM'),
                    ),
                  ),
                  Expanded(
                    child: _buildToggleItem(
                      label: 'PM',
                      isActive: routineVm.activeRoutine == 'PM',
                      onTap: () => routineVm.setActiveRoutine('PM'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Steps Progress Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Steps',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                    child: Text(
                      '${routineVm.completedCount}/${routineVm.totalCount} Completed',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.pink.shade300,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Steps Routine Checklist cards
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: routineVm.currentSteps.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final step = routineVm.currentSteps[index];
                final isCompleted = routineVm.completedStepIds.contains(step['id']);

                return GestureDetector(
                  onTap: () => routineVm.toggleStep(step['id']),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Custom circular check indicator
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1.5),
                            color: isCompleted ? Colors.black : Colors.transparent,
                          ),
                          child: isCompleted
                              ? const Icon(Icons.check, color: Colors.white, size: 14)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        // Titles and subtitles
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step['name'] ?? 'Custom Step',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                step['description'] ?? '',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Step number label
                        Text(
                          'Step ${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Click to add Card
            GestureDetector(
              onTap: () => _showAddStepDialog(context, authVm.userId, routineVm),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 22),
                child: const Center(
                  child: Text(
                    'Click to add',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Complete Routine Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  routineVm.completeRoutine(authVm.userId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Routine Completed! Consistency score updated.'),
                      backgroundColor: Colors.black,
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Complete Routine',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.check_circle_outline, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  void _showAddStepDialog(BuildContext context, String userId, RoutineViewModel vm) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Add Routine Step', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Step Name (e.g., Toner)'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Instructions (e.g., Apply with pad)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  vm.addCustomStep(userId, titleController.text, descController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

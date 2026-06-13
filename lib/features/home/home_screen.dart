import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routine_viewmodel.dart';
import '../../core/viewmodels/auth_viewmodel.dart';
import '../../core/models/models.dart';
import '../shelf/shelf_viewmodel.dart';
import '../../core/widgets/glowmatch_header.dart';
import '../../core/widgets/error_state_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routineVm = Provider.of<RoutineViewModel>(context);
    final authVm = Provider.of<AuthViewModel>(context);
    final weather = routineVm.weather;
    final shelfVm = Provider.of<ShelfViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: GlowMatch.
            const GlowMatchHeader(),
            const SizedBox(height: 24),

            if (routineVm.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 64.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (routineVm.errorMessage != null)
              ErrorStateWidget(
                message: routineVm.errorMessage!,
                onRetry: () => routineVm.init(authVm.userId),
              )
            else ...[
              // Title and Weather Metadata
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      routineVm.activeRoutine == 'AM' ? 'Morning Routine' : 'Evening Routine',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  if (routineVm.streakData != null && routineVm.streakData!.currentStreak > 0)
                    _buildStreakBadge(routineVm.streakData!.currentStreak),
                ],
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
              if (routineVm.streakData != null)
                _buildMotivationalBanner(routineVm.streakData!.currentStreak),
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
              if (routineVm.currentSteps.isEmpty)
                const ErrorStateWidget(
                  icon: Icons.event_note,
                  message: 'No routine steps yet. Tap below to add your first step!',
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: routineVm.currentSteps.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final RoutineStep step = routineVm.currentSteps[index];
                    final isCompleted = routineVm.completedStepIds.contains(step.id);

                    return GestureDetector(
                      onTap: () {
                        final bool isCompleting = !isCompleted;
                        routineVm.toggleStep(step.id, shelfVm);

                        if (isCompleting && step.shelfItemId != null && step.shelfItemId!.isNotEmpty) {
                          final product = shelfVm.shelfItems.firstWhere(
                            (p) => p.id == step.shelfItemId,
                            orElse: () => ShelfItem(
                              id: '',
                              name: '',
                              brand: '',
                              category: '',
                              price: 0,
                              estimatedUses: 0,
                              remainingUses: 0,
                              indicatorColor: '',
                              ingredients: [],
                            ),
                          );
                          final productName = product.name.isNotEmpty ? product.name : step.name;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Used 1 apply of $productName!'),
                              backgroundColor: Colors.black,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
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
                                    step.name.isEmpty ? 'Custom Step' : step.name,
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
                                    step.description ?? '',
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
              if (routineVm.currentSteps.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: routineVm.completedToday ? Colors.grey.shade300 : Colors.black,
                      foregroundColor: routineVm.completedToday ? Colors.grey.shade600 : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: routineVm.completedToday ? Colors.grey.shade400 : Colors.black,
                          width: 1.5,
                        ),
                      ),
                      elevation: 0,
                    ),
                    onPressed: routineVm.completedToday
                        ? null
                        : () async {
                            await routineVm.completeRoutine(authVm.userId);
                            final newStreak = routineVm.streakData?.currentStreak ?? 0;
                            String msg = 'Routine Completed! Consistency score updated.';
                            if (newStreak == 7) {
                              msg = '🎉 7 Day Milestone! Awesome dedication!';
                            } else if (newStreak == 14) {
                              msg = '🎉 14 Day Milestone! You are unstoppable!';
                            } else if (newStreak == 30) {
                              msg = '🎉 30 Day Milestone! You are a skincare master!';
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(msg),
                                  backgroundColor: Colors.black,
                                ),
                              );
                            }
                          },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          routineVm.completedToday ? 'Completed for Today' : 'Complete Routine',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          routineVm.completedToday ? Icons.check : Icons.check_circle_outline,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
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

  Widget _buildStreakBadge(int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD54F), // Amber/Orange
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            '$streak Day Streak',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalBanner(int streak) {
    String message;
    Color bgColor;
    if (streak == 0) {
      message = 'Start your routine today to begin your glowing skin streak! 🔥';
      bgColor = Colors.grey.shade100;
    } else if (streak >= 30) {
      message = '👑 30+ Day Milestone! Skincare Master status unlocked!';
      bgColor = const Color(0xFFE040FB); // Pink/Purple
    } else if (streak >= 14) {
      message = '🌟 14 Day Milestone! Your skin barrier is thanking you!';
      bgColor = const Color(0xFF64DD17); // Light Green
    } else if (streak >= 7) {
      message = '🏆 7 Day Milestone! You are building a solid skincare habit!';
      bgColor = const Color(0xFF29B6F6); // Blue
    } else {
      message = '✨ Keep it up! Consistency is the key to glowing skin.';
      bgColor = const Color(0xFFFF8A80); // Coral/Red
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}

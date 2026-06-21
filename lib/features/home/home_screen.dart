import 'dart:async';
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
    final shelfVm = Provider.of<ShelfViewModel>(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final switcherBg = isDark ? Colors.grey.shade900 : Colors.grey.shade100;
    final stepBadgeBg = isDark
        ? Colors.pink.shade900.withValues(alpha: 0.4)
        : Colors.pink.shade50;
    final stepBadgeText = isDark ? Colors.pink.shade300 : Colors.pink.shade400;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GlowMatchHeader(),
            const SizedBox(height: 12),
            const _LiveClock(),
            const SizedBox(height: 16),

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      routineVm.activeRoutine == 'AM'
                          ? 'Morning Routine'
                          : 'Evening Routine',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  if (routineVm.streakData != null &&
                      routineVm.streakData!.currentStreak > 0)
                    _buildStreakBadge(
                      context,
                      routineVm.streakData!.currentStreak,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.wb_sunny_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    weather != null
                        ? '${weather.locationName} • ${weather.temperature.toStringAsFixed(0)}°C'
                        : 'Los Angeles, CA • 33°C',
                    style: TextStyle(
                      fontSize: 14,
                      color: subtextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (routineVm.streakData != null)
                _buildMotivationalBanner(
                  context,
                  routineVm.streakData!.currentStreak,
                ),
              const SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  color: switcherBg,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildToggleItem(
                        context,
                        label: 'AM',
                        isActive: routineVm.activeRoutine == 'AM',
                        onTap: () => routineVm.setActiveRoutine('AM'),
                      ),
                    ),
                    Expanded(
                      child: _buildToggleItem(
                        context,
                        label: 'PM',
                        isActive: routineVm.activeRoutine == 'PM',
                        onTap: () => routineVm.setActiveRoutine('PM'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Steps',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: stepBadgeBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 2.0,
                      ),
                      child: Text(
                        '${routineVm.completedCount}/${routineVm.totalCount} Completed',
                        style: TextStyle(
                          fontSize: 12,
                          color: stepBadgeText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (routineVm.currentSteps.isEmpty)
                const ErrorStateWidget(
                  icon: Icons.event_note,
                  message:
                      'No routine steps yet. Tap below to add your first step!',
                )
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  itemCount: routineVm.currentSteps.length,
                  onReorder: (oldIndex, newIndex) {
                    routineVm.reorderStepsDirect(authVm.userId, oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final RoutineStep step = routineVm.currentSteps[index];
                    final isCompleted = routineVm.completedStepIds.contains(
                      step.id,
                    );

                    ShelfItem? linkedProduct;
                    if (step.shelfItemId != null &&
                        step.shelfItemId!.isNotEmpty) {
                      try {
                        linkedProduct = shelfVm.shelfItems.firstWhere(
                          (p) => p.id == step.shelfItemId,
                        );
                      } catch (_) {
                        linkedProduct = null;
                      }
                    }

                    return Dismissible(
                      key: ValueKey(step.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (dialogCtx) {
                            final isDarkDlg =
                                Theme.of(dialogCtx).brightness ==
                                    Brightness.dark;
                            return AlertDialog(
                              backgroundColor: isDarkDlg
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isDarkDlg
                                      ? Colors.white
                                      : Colors.black,
                                  width: 2,
                                ),
                              ),
                              title: Text(
                                'Delete Step?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDarkDlg
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              content: Text(
                                'Remove "${step.name.isEmpty ? 'Custom Step' : step.name}" from your ${routineVm.activeRoutine} routine?',
                                style: TextStyle(
                                  color: isDarkDlg
                                      ? Colors.grey.shade300
                                      : Colors.black87,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogCtx, false),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDarkDlg
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  onPressed: () =>
                                      Navigator.pop(dialogCtx, true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ) ??
                            false;
                      },
                      onDismissed: (_) {
                        routineVm.deleteStep(authVm.userId, step.id);
                      },
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      child: Container(
                        key: ValueKey('inner_${step.id}'),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: textColor, width: 1.2),
                          borderRadius: BorderRadius.circular(8),
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            ReorderableDragStartListener(
                              index: index,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Icon(
                                  Icons.drag_handle,
                                  color: subtextColor,
                                  size: 20,
                                ),
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                final bool isCompleting = !isCompleted;
                                routineVm.toggleStep(step.id, shelfVm);

                                if (isCompleting &&
                                    step.shelfItemId != null &&
                                    step.shelfItemId!.isNotEmpty) {
                                  final productName =
                                      linkedProduct != null &&
                                          linkedProduct.name.isNotEmpty
                                      ? linkedProduct.name
                                      : step.name;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Used 1 apply of $productName!',
                                      ),
                                      backgroundColor: isDark
                                          ? Colors.grey.shade900
                                          : Colors.black,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: textColor,
                                    width: 1.5,
                                  ),
                                  color: isCompleted
                                      ? textColor
                                      : Colors.transparent,
                                ),
                                child: isCompleted
                                    ? Icon(
                                        Icons.check,
                                        color: isDark
                                            ? Colors.black
                                            : Colors.white,
                                        size: 14,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),

                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  final bool isCompleting = !isCompleted;
                                  routineVm.toggleStep(step.id, shelfVm);

                                  if (isCompleting &&
                                      step.shelfItemId != null &&
                                      step.shelfItemId!.isNotEmpty) {
                                    final productName =
                                        linkedProduct != null &&
                                            linkedProduct.name.isNotEmpty
                                        ? linkedProduct.name
                                        : step.name;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Used 1 apply of $productName!',
                                        ),
                                        backgroundColor: isDark
                                            ? Colors.grey.shade900
                                            : Colors.black,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      step.name.isEmpty
                                          ? 'Custom Step'
                                          : step.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                        decoration: isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    if (step.description != null &&
                                        step.description!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        step.description!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: subtextColor,
                                        ),
                                      ),
                                    ],
                                    if (linkedProduct != null) ...[
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.link,
                                            size: 12,
                                            color: stepBadgeText,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              '${linkedProduct.brand} - ${linkedProduct.name} (${linkedProduct.remainingUses} left)',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: stepBadgeText,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Step ${index + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.grey.shade500
                                        : Colors.grey.shade400,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    color: subtextColor,
                                    size: 18,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    _showEditStepDialog(
                                      context,
                                      authVm.userId,
                                      routineVm,
                                      step,
                                      shelfVm,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },

                ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () => _showAddStepDialog(
                  context,
                  authVm.userId,
                  routineVm,
                  shelfVm,
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: textColor, width: 1.2),
                    borderRadius: BorderRadius.circular(8),
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  child: Center(
                    child: Text(
                      'Click to add',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              if (routineVm.currentSteps.isNotEmpty)
                Builder(
                  builder: (context) {
                    final isButtonDisabled = routineVm.completedToday ||
                        routineVm.completedCount < routineVm.totalCount ||
                        routineVm.totalCount == 0;

                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isButtonDisabled
                              ? (isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300)
                              : (isDark ? Colors.white : Colors.black),
                          foregroundColor: isButtonDisabled
                              ? (isDark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade600)
                              : (isDark ? Colors.black : Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isButtonDisabled
                                  ? (isDark
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade400)
                                  : (isDark ? Colors.white : Colors.black),
                              width: 1.5,
                            ),
                          ),
                          elevation: 0,
                        ),
                        onPressed: isButtonDisabled
                            ? null
                            : () async {
                                await routineVm.completeRoutine(authVm.userId);
                                final newStreak =
                                    routineVm.streakData?.currentStreak ?? 0;
                                String msg =
                                    'Routine Completed! Consistency score updated.';
                                if (newStreak == 7) {
                                  msg = '🎉 7 Day Milestone! Awesome dedication!';
                                } else if (newStreak == 14) {
                                  msg = '🎉 14 Day Milestone! You are unstoppable!';
                                } else if (newStreak == 30) {
                                  msg =
                                      '🎉 30 Day Milestone! You are a skincare master!';
                                }
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(msg),
                                      backgroundColor: isDark
                                          ? Colors.grey.shade900
                                          : Colors.black,
                                    ),
                                  );
                                }
                              },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              routineVm.completedToday
                                  ? 'Completed for Today'
                                  : 'Complete Routine',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              routineVm.completedToday
                                  ? Icons.check
                                  : Icons.check_circle_outline,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(
    BuildContext context, {
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBg = isDark ? Colors.white : Colors.black;
    final activeFg = isDark ? Colors.black : Colors.white;
    final inactiveFg = isDark ? Colors.white70 : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isActive ? activeFg : inactiveFg,
            ),
          ),
        ),
      ),
    );
  }

  void _showAddStepDialog(
    BuildContext context,
    String userId,
    RoutineViewModel vm,
    ShelfViewModel shelfVm,
  ) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String? selectedShelfItemId;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white : Colors.black;
    final textColor = isDark ? Colors.white : Colors.black;
    final buttonBg = isDark ? Colors.white : Colors.black;
    final buttonFg = isDark ? Colors.black : Colors.white;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: dialogBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: borderColor, width: 2),
              ),
              title: Text(
                'Add Routine Step',
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: 'Step Name (e.g., Toner)',
                        labelStyle: TextStyle(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade700,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark ? Colors.white30 : Colors.black26,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: 'Instructions (e.g., Apply with pad)',
                        labelStyle: TextStyle(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade700,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark ? Colors.white30 : Colors.black26,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Link Shelf Product (Optional)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor, width: 1.2),
                        borderRadius: BorderRadius.circular(6),
                        color: isDark
                            ? Colors.grey.shade900
                            : Colors.grey.shade50,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: selectedShelfItemId,
                          isExpanded: true,
                          dropdownColor: dialogBg,
                          style: TextStyle(color: textColor, fontSize: 14),
                          hint: Text(
                            'Select product',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade400,
                            ),
                          ),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(
                                'None',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                            ...shelfVm.shelfItems.map((item) {
                              return DropdownMenuItem<String?>(
                                value: item.id,
                                child: Text(
                                  '${item.brand} - ${item.name} (${item.remainingUses} left)',
                                ),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setState(() {
                              selectedShelfItemId = val;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonBg,
                    foregroundColor: buttonFg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: BorderSide(color: borderColor, width: 1.5),
                    ),
                  ),
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      vm.addCustomStep(
                        userId,
                        titleController.text,
                        descController.text,
                        shelfItemId: selectedShelfItemId,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditStepDialog(
    BuildContext context,
    String userId,
    RoutineViewModel vm,
    RoutineStep step,
    ShelfViewModel shelfVm,
  ) {
    final titleController = TextEditingController(text: step.name);
    final descController = TextEditingController(text: step.description ?? '');
    String? selectedShelfItemId = step.shelfItemId;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white : Colors.black;
    final textColor = isDark ? Colors.white : Colors.black;
    final buttonBg = isDark ? Colors.white : Colors.black;
    final buttonFg = isDark ? Colors.black : Colors.white;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: dialogBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: borderColor, width: 2),
              ),
              title: Text(
                'Edit Routine Step',
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: 'Step Name',
                        labelStyle: TextStyle(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade700,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark ? Colors.white30 : Colors.black26,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: 'Instructions',
                        labelStyle: TextStyle(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade700,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark ? Colors.white30 : Colors.black26,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Link Shelf Product',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor, width: 1.2),
                        borderRadius: BorderRadius.circular(6),
                        color: isDark
                            ? Colors.grey.shade900
                            : Colors.grey.shade50,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: selectedShelfItemId,
                          isExpanded: true,
                          dropdownColor: dialogBg,
                          style: TextStyle(color: textColor, fontSize: 14),
                          hint: Text(
                            'Select product',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade400,
                            ),
                          ),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(
                                'None',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                            ...shelfVm.shelfItems.map((item) {
                              return DropdownMenuItem<String?>(
                                value: item.id,
                                child: Text(
                                  '${item.brand} - ${item.name} (${item.remainingUses} left)',
                                ),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setState(() {
                              selectedShelfItemId = val;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () {
                        _showDeleteConfirmDialog(context, userId, vm, step);
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonBg,
                            foregroundColor: buttonFg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: BorderSide(color: borderColor, width: 1.5),
                            ),
                          ),
                          onPressed: () {
                            if (titleController.text.isNotEmpty) {
                              final updatedStep = step.copyWith(
                                name: titleController.text,
                                description: descController.text,
                                shelfItemId: selectedShelfItemId,
                              );
                              vm.updateStep(userId, updatedStep);
                              Navigator.pop(context);
                            }
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    String userId,
    RoutineViewModel vm,
    RoutineStep step,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white : Colors.black;
    final textColor = isDark ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderColor, width: 2),
          ),
          title: Text(
            'Delete Step?',
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
          content: Text(
            'Are you sure you want to delete this step? Remaining steps will be renumbered.',
            style: TextStyle(color: textColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(color: borderColor, width: 1.5),
                ),
              ),
              onPressed: () {
                vm.deleteStep(userId, step.id);

                Navigator.pop(context);

                Navigator.pop(context);
              },
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStreakBadge(BuildContext context, int streak) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white : Colors.black;
    final shadowColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD54F),
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(2, 2),
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

  Widget _buildMotivationalBanner(BuildContext context, int streak) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white : Colors.black;
    final shadowColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black;

    String message;
    Color bgColor;
    Color messageColor = Colors.black;

    if (streak == 0) {
      message =
          'Start your routine today to begin your glowing skin streak! 🔥';
      bgColor = isDark ? Colors.grey.shade900 : Colors.grey.shade100;
      messageColor = isDark ? Colors.white : Colors.black;
    } else if (streak >= 30) {
      message = '👑 30+ Day Milestone! Skincare Master status unlocked!';
      bgColor = const Color(0xFFE040FB);
    } else if (streak >= 14) {
      message = '🌟 14 Day Milestone! Your skin barrier is thanking you!';
      bgColor = const Color(0xFF64DD17);
    } else if (streak >= 7) {
      message = '🏆 7 Day Milestone! You are building a solid skincare habit!';
      bgColor = const Color(0xFF29B6F6);
    } else {
      message = '✨ Keep it up! Consistency is the key to glowing skin.';
      bgColor = const Color(0xFFFF8A80);
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: messageColor,
        ),
      ),
    );
  }
}

// ── Real-time clock ───────────────────────────────────────────────────────────

class _LiveClock extends StatefulWidget {
  const _LiveClock();

  @override
  State<_LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<_LiveClock> {
  late DateTime _now;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatted(bool use24Hour) {
    if (use24Hour) {
      final h = _now.hour.toString().padLeft(2, '0');
      final m = _now.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } else {
      final raw = _now.hour % 12 == 0 ? 12 : _now.hour % 12;
      final h = raw.toString().padLeft(2, '0');
      final m = _now.minute.toString().padLeft(2, '0');
      final period = _now.hour < 12 ? 'AM' : 'PM';
      return '$h:$m $period';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final use24Hour = MediaQuery.of(context).alwaysUse24HourFormat;
    final subtextColor =
        isDark ? Colors.grey.shade500 : Colors.grey.shade400;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          _formatted(use24Hour),
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : Colors.black,
            letterSpacing: -2,
            height: 1,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _now.hour < 12 ? 'AM' : 'PM',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: subtextColor,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

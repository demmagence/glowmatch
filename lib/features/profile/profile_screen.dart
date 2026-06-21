import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/viewmodels/auth_viewmodel.dart';
import '../../core/viewmodels/theme_viewmodel.dart';
import 'profile_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);
    final themeVm = Provider.of<ThemeViewModel>(context);

    return ChangeNotifierProvider<ProfileViewModel>(
      create: (_) => ProfileViewModel(authViewModel: authVm),
      child: Consumer<ProfileViewModel>(
        builder: (context, profileVm, child) {
          final isDark = themeVm.isDarkMode;
          final borderColor = isDark ? Colors.white : Colors.black;
          final shadowColor = isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.black;
          final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Profile & Settings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(color: borderColor, height: 1.2),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardBg,
                      border: Border.all(color: borderColor, width: 2.0),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          offset: const Offset(4, 4),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.pink.shade100,
                            shape: BoxShape.circle,
                            border: Border.all(color: borderColor, width: 2.0),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 48,
                            color: isDark ? Colors.black : Colors.pink,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          authVm.isAnonymous ? 'Guest User' : 'Secured User',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authVm.isAnonymous
                              ? 'ID: ${authVm.userId.substring(0, 8)}...'
                              : (authVm.currentUser?.email ?? ''),
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (authVm.isAnonymous) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              border: Border.all(
                                color: borderColor,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Guest Account (Data is temporary)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (authVm.isAnonymous) ...[
                    Text(
                      'Secure Your Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        border: Border.all(color: borderColor, width: 2.0),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            offset: const Offset(4, 4),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Link an email and password to avoid losing your skincare shelf and routines.',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                filled: true,
                                fillColor: isDark
                                    ? Colors.black38
                                    : Colors.grey.shade50,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: borderColor,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? Colors.pinkAccent
                                        : Colors.pink,
                                    width: 2.0,
                                  ),
                                ),
                                labelStyle: TextStyle(
                                  color: isDark
                                      ? Colors.grey.shade300
                                      : Colors.black54,
                                ),
                              ),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    !value.contains('@')) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                filled: true,
                                fillColor: isDark
                                    ? Colors.black38
                                    : Colors.grey.shade50,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: borderColor,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? Colors.pinkAccent
                                        : Colors.pink,
                                    width: 2.0,
                                  ),
                                ),
                                labelStyle: TextStyle(
                                  color: isDark
                                      ? Colors.grey.shade300
                                      : Colors.black54,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              validator: (value) {
                                if (value == null || value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                filled: true,
                                fillColor: isDark
                                    ? Colors.black38
                                    : Colors.grey.shade50,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: borderColor,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? Colors.pinkAccent
                                        : Colors.pink,
                                    width: 2.0,
                                  ),
                                ),
                                labelStyle: TextStyle(
                                  color: isDark
                                      ? Colors.grey.shade300
                                      : Colors.black54,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            if (profileVm.errorMessage != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                profileVm.errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark
                                      ? Colors.pinkAccent
                                      : Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: borderColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: profileVm.isSubmittingLink
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          final success = await profileVm
                                              .linkEmail(
                                                _emailController.text.trim(),
                                                _passwordController.text,
                                              );
                                          if (success && context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Account successfully secured!',
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                child: profileVm.isSubmittingLink
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.0,
                                        ),
                                      )
                                    : const Text(
                                        'Link Email Account',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  Text(
                    'App Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      border: Border.all(color: borderColor, width: 2.0),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          offset: const Offset(4, 4),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text(
                            'Dark Mode',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            'Toggle app-wide dark theme',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                          value: isDark,
                          activeThumbColor: isDark
                              ? Colors.pinkAccent
                              : Colors.pink,
                          activeTrackColor: isDark
                              ? Colors.pinkAccent.withValues(alpha: 0.5)
                              : Colors.pink.withValues(alpha: 0.5),
                          onChanged: (value) {
                            themeVm.toggleThemeMode(value);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Notifications section ──────────────────────────────
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      border: Border.all(color: borderColor, width: 2.0),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          offset: const Offset(4, 4),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    child: Column(
                      children: [
                        // Master toggle
                        SwitchListTile(
                          title: Text(
                            'Routine Reminders',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            'Enable AM & PM routine notifications',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                          value: profileVm.isNotificationsEnabled,
                          activeThumbColor:
                              isDark ? Colors.pinkAccent : Colors.pink,
                          activeTrackColor: isDark
                              ? Colors.pinkAccent.withValues(alpha: 0.5)
                              : Colors.pink.withValues(alpha: 0.5),
                          onChanged: (value) {
                            profileVm.toggleNotifications(value);
                          },
                        ),

                        if (profileVm.isNotificationsEnabled) ...[
                          Divider(
                            color: borderColor,
                            thickness: 1.0,
                            height: 1,
                          ),

                          // AM reminder row
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4.0,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      '🌅  AM Reminder',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Morning routine alert',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                    value: profileVm.amEnabled,
                                    activeThumbColor: isDark
                                        ? Colors.pinkAccent
                                        : Colors.pink,
                                    activeTrackColor: isDark
                                        ? Colors.pinkAccent
                                              .withValues(alpha: 0.5)
                                        : Colors.pink.withValues(alpha: 0.5),
                                    onChanged: (v) =>
                                        profileVm.toggleAmReminder(v),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: profileVm.amEnabled
                                      ? () async {
                                          final picked =
                                              await showTimePicker(
                                            context: context,
                                            initialTime: profileVm.amTime,
                                          );
                                          if (picked != null) {
                                            profileVm.setAmTime(picked);
                                          }
                                        }
                                      : null,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: profileVm.amEnabled
                                          ? (isDark
                                                ? Colors.white12
                                                : Colors.grey.shade100)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: profileVm.amEnabled
                                            ? borderColor
                                            : Colors.transparent,
                                        width: 1.2,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      profileVm.amTime.format(context),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: profileVm.amEnabled
                                            ? (isDark
                                                  ? Colors.white
                                                  : Colors.black)
                                            : (isDark
                                                  ? Colors.grey.shade700
                                                  : Colors.grey.shade400),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                              ],
                            ),
                          ),

                          Divider(
                            color: borderColor,
                            thickness: 1.0,
                            height: 1,
                          ),

                          // PM reminder row
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4.0,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      '🌙  PM Reminder',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Evening routine alert',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                    value: profileVm.pmEnabled,
                                    activeThumbColor: isDark
                                        ? Colors.pinkAccent
                                        : Colors.pink,
                                    activeTrackColor: isDark
                                        ? Colors.pinkAccent
                                              .withValues(alpha: 0.5)
                                        : Colors.pink.withValues(alpha: 0.5),
                                    onChanged: (v) =>
                                        profileVm.togglePmReminder(v),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: profileVm.pmEnabled
                                      ? () async {
                                          final picked =
                                              await showTimePicker(
                                            context: context,
                                            initialTime: profileVm.pmTime,
                                          );
                                          if (picked != null) {
                                            profileVm.setPmTime(picked);
                                          }
                                        }
                                      : null,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: profileVm.pmEnabled
                                          ? (isDark
                                                ? Colors.white12
                                                : Colors.grey.shade100)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: profileVm.pmEnabled
                                            ? borderColor
                                            : Colors.transparent,
                                        width: 1.2,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      profileVm.pmTime.format(context),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: profileVm.pmEnabled
                                            ? (isDark
                                                  ? Colors.white
                                                  : Colors.black)
                                            : (isDark
                                                  ? Colors.grey.shade700
                                                  : Colors.grey.shade400),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: borderColor, width: 2.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: isDark
                            ? const Color(0xFF331010)
                            : Colors.red.shade50,
                        foregroundColor: Colors.red,
                      ),
                      onPressed: () => _showSignOutDialog(context, authVm),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text(
                            'Sign Out',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  Center(
                    child: Text(
                      'GlowMatch v0.1.0+1',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade400,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AuthViewModel authVm) {
    final isAnonymous = authVm.isAnonymous;
    final themeVm = Provider.of<ThemeViewModel>(context, listen: false);
    final borderColor = themeVm.isDarkMode ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderColor, width: 2.0),
          ),
          backgroundColor: themeVm.isDarkMode
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          title: Text(
            'Confirm Sign Out',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: themeVm.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            isAnonymous
                ? 'Warning: You are currently using a Guest account. Signing out will permanently delete your skincare shelf and routines. Are you sure you want to sign out?'
                : 'Are you sure you want to sign out of your account?',
            style: TextStyle(
              color: themeVm.isDarkMode ? Colors.grey.shade300 : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: themeVm.isDarkMode ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: borderColor, width: 1.0),
                ),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                await authVm.signOut();
                if (mounted) {
                  await authVm.loginAnonymously();
                  if (mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                        content: Text('Successfully signed out.'),
                        backgroundColor: Colors.black,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}

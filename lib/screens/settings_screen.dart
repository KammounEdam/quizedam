import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/preferences_service.dart';
import '../services/audio_manager.dart';
import '../services/audio_service.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _audioService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: Consumer2<PreferencesService, AuthProvider>(
        builder: (context, preferences, authProvider, _) {
          return ListView(
            children: [
              // Section Profil Utilisateur
              _buildUserProfileSection(context, authProvider, l10n),
              const Divider(),
              ListTile(
                title: Text(l10n.darkMode),
                trailing: Switch(
                  value: preferences.isDarkMode,
                  onChanged: (value) {
                    preferences.setThemeMode(value ? 'dark' : 'light');
                  },
                ),
              ),
              ListTile(
                title: Text(l10n.language),
                trailing: DropdownButton<String>(
                  value: preferences.getLanguage(),
                  items: const [
                    DropdownMenuItem(
                      value: 'en',
                      child: Text('English'),
                    ),
                    DropdownMenuItem(
                      value: 'ar',
                      child: Text('العربية'),
                    ),
                    DropdownMenuItem(
                      value: 'fr',
                      child: Text('Français'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      preferences.setLanguage(value);
                    }
                  },
                ),
              ),
              ListTile(
                leading: Icon(
                  preferences.getSoundEnabled()
                      ? Icons.volume_up
                      : Icons.volume_off,
                  color:
                      preferences.getSoundEnabled() ? Colors.blue : Colors.grey,
                ),
                title: Text(l10n.soundEffects),
                subtitle: Text(
                  preferences.getSoundEnabled() ? l10n.enabled : l10n.disabled,
                  style: TextStyle(
                    color: preferences.getSoundEnabled()
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
                trailing: Switch(
                  value: preferences.getSoundEnabled(),
                  onChanged: (value) {
                    preferences.setSoundEnabled(value);
                    // Test sound when enabled
                    if (value) {
                      _audioService.playButtonSound();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.soundEffectsEnabled),
                          duration: const Duration(milliseconds: 1000),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.soundEffectsDisabled),
                          duration: const Duration(milliseconds: 1000),
                        ),
                      );
                    }
                  },
                ),
              ),
              ListTile(
                leading: Icon(
                  preferences.getVibrationEnabled()
                      ? Icons.vibration
                      : Icons.phone_android,
                  color: preferences.getVibrationEnabled()
                      ? Colors.blue
                      : Colors.grey,
                ),
                title: Text(l10n.vibration),
                subtitle: Text(
                  preferences.getVibrationEnabled()
                      ? l10n.enabled
                      : l10n.disabled,
                  style: TextStyle(
                    color: preferences.getVibrationEnabled()
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
                trailing: Switch(
                  value: preferences.getVibrationEnabled(),
                  onChanged: (value) {
                    preferences.setVibrationEnabled(value);
                    // Test vibration when enabled
                    if (value) {
                      _audioService.vibrateButton();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.vibrationEnabled),
                          duration: const Duration(milliseconds: 1500),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.vibrationDisabled),
                          duration: const Duration(milliseconds: 1000),
                        ),
                      );
                    }
                  },
                ),
              ),

              // Section de test audio
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.testAudio,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Text(
                      l10n.testAudioDescription,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Bouton son correct
                        ElevatedButton.icon(
                          onPressed: () {
                            AudioManager().playCorrect();
                          },
                          icon: const Icon(Icons.check_circle,
                              color: Colors.green),
                          label: Text(l10n.correct),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade50,
                            foregroundColor: Colors.green.shade700,
                          ),
                        ),

                        // Bouton son incorrect
                        ElevatedButton.icon(
                          onPressed: () {
                            AudioManager().playWrong();
                          },
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          label: Text(l10n.incorrect),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Bouton son clic
                    ElevatedButton.icon(
                      onPressed: () {
                        AudioManager().playClick();
                      },
                      icon: const Icon(Icons.touch_app, color: Colors.blue),
                      label: Text(l10n.clickSound),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade50,
                        foregroundColor: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.audioFallbackMessage,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserProfileSection(
      BuildContext context, AuthProvider authProvider, AppLocalizations l10n) {
    if (!authProvider.isSignedIn) {
      return _buildSignInPrompt(context, l10n);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            l10n.userProfile,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildUserInfoCard(context, authProvider, l10n),
        _buildSignOutButton(context, authProvider, l10n),
      ],
    );
  }

  Widget _buildSignInPrompt(BuildContext context, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.account_circle,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Not Signed In',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to save your progress and access all features',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(
      BuildContext context, AuthProvider authProvider, AppLocalizations l10n) {
    final user = authProvider.user;
    final userModel = authProvider.userModel;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? Icon(
                          authProvider.isAnonymous
                              ? Icons.person_outline
                              : Icons.person,
                          size: 30,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authProvider.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!authProvider.isAnonymous) ...[
                        const SizedBox(height: 4),
                        Text(
                          authProvider.email,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        authProvider.isAnonymous
                            ? l10n.anonymousUser
                            : l10n.signedInAs,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (userModel?.createdAt != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${l10n.memberSince}: ${DateFormat.yMMMd().format(userModel!.createdAt!)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (userModel.lastLoginAt != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${l10n.lastLogin}: ${DateFormat.yMMMd().add_Hm().format(userModel.lastLoginAt!)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton(
      BuildContext context, AuthProvider authProvider, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _showSignOutDialog(context, authProvider, l10n),
          icon: const Icon(Icons.logout, color: Colors.red),
          label: Text(
            l10n.signOut,
            style: const TextStyle(color: Colors.red),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(
      BuildContext context, AuthProvider authProvider, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.confirmSignOut),
          content: Text(l10n.signOutMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await authProvider.signOut();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.signOutSuccess),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );
  }
}

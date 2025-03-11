import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../providers/student_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/asset_image_with_fallback.dart';
import '../widgets/placeholder_logo.dart';
import '../widgets/multi_format_image.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _importFromJson(BuildContext context, WidgetRef ref) async {
    // Use an empty string to indicate we want to load the bundled JSON file
    try {
      // Empty string indicates to use the bundled assets/data/students.json file
      const String jsonData = '';
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Importing student data...'),
              ],
            ),
          );
        },
      );
      
      // Import data
      await ref.read(studentRepositoryProvider).importFromJson(jsonData);
      
      if (context.mounted) {
        // Close loading dialog
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.importSuccess),
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Refresh student list
        ref.refresh(allStudentsProvider);
      }
    } catch (e) {
      if (context.mounted) {
        // Close loading dialog if it's open
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppConstants.importError}: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _getThemeModeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
    }
  }

  String _getColorSchemeName(AppColorScheme colorScheme) {
    switch (colorScheme) {
      case AppColorScheme.blue:
        return 'Blue';
      case AppColorScheme.green:
        return 'Green';
      case AppColorScheme.purple:
        return 'Purple';
      case AppColorScheme.orange:
        return 'Orange';
      case AppColorScheme.pink:
        return 'Pink';
    }
  }

  Future<void> _showThemeModeDialog(BuildContext context, WidgetRef ref, ThemeMode currentMode) async {
    final ThemeMode? result = await showDialog<ThemeMode>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme Mode'),
        contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeModeOption(
              title: 'System Default',
              description: 'Follow system settings',
              icon: Icons.brightness_auto,
              selected: currentMode == ThemeMode.system,
              onTap: () => Navigator.pop(context, ThemeMode.system),
            ),
            const SizedBox(height: 16),
            _ThemeModeOption(
              title: 'Light Mode',
              description: 'Light theme for daytime',
              icon: Icons.brightness_high,
              selected: currentMode == ThemeMode.light,
              onTap: () => Navigator.pop(context, ThemeMode.light),
            ),
            const SizedBox(height: 16),
            _ThemeModeOption(
              title: 'Dark Mode',
              description: 'Dark theme for nighttime',
              icon: Icons.brightness_4,
              selected: currentMode == ThemeMode.dark,
              onTap: () => Navigator.pop(context, ThemeMode.dark),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (result != null) {
      await ref.read(themeModeProvider.notifier).setThemeMode(result);
    }
  }
  
  Future<void> _showColorSchemeDialog(BuildContext context, WidgetRef ref, AppColorScheme currentScheme) async {
    final AppColorScheme? result = await showDialog<AppColorScheme>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color Scheme'),
        contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ColorSchemeOption(
              title: 'Blue',
              color: getColorFromColorScheme(AppColorScheme.blue),
              selected: currentScheme == AppColorScheme.blue,
              onTap: () => Navigator.pop(context, AppColorScheme.blue),
            ),
            const SizedBox(height: 16),
            _ColorSchemeOption(
              title: 'Green',
              color: getColorFromColorScheme(AppColorScheme.green),
              selected: currentScheme == AppColorScheme.green,
              onTap: () => Navigator.pop(context, AppColorScheme.green),
            ),
            const SizedBox(height: 16),
            _ColorSchemeOption(
              title: 'Purple',
              color: getColorFromColorScheme(AppColorScheme.purple),
              selected: currentScheme == AppColorScheme.purple,
              onTap: () => Navigator.pop(context, AppColorScheme.purple),
            ),
            const SizedBox(height: 16),
            _ColorSchemeOption(
              title: 'Orange',
              color: getColorFromColorScheme(AppColorScheme.orange),
              selected: currentScheme == AppColorScheme.orange,
              onTap: () => Navigator.pop(context, AppColorScheme.orange),
            ),
            const SizedBox(height: 16),
            _ColorSchemeOption(
              title: 'Pink',
              color: getColorFromColorScheme(AppColorScheme.pink),
              selected: currentScheme == AppColorScheme.pink,
              onTap: () => Navigator.pop(context, AppColorScheme.pink),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (result != null) {
      await ref.read(colorSchemeProvider.notifier).setColorScheme(result);
    }
  }
  
  Future<void> _launchSocialLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final colorScheme = ref.watch(colorSchemeProvider);
    final isDarkMode = themeMode == ThemeMode.dark || 
                      (themeMode == ThemeMode.system && 
                       MediaQuery.of(context).platformBrightness == Brightness.dark);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // App logo
          Container(
            padding: const EdgeInsets.all(16),
            child: Hero(
              tag: 'app_logo',
              child: MultiFormatImage(
                imagePath: 'assets/images/logo.png',
                width: 100,
                height: 100,
              ),
            ),
          ),
          
          // App name and version
          Text(
            AppConstants.appName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          Text(
            'Version ${AppConstants.appVersion}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          
          const SizedBox(height: 24),
          
          // Settings list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Appearance section
                _SectionHeader(
                  title: 'Appearance',
                  icon: Icons.palette_outlined,
                ),
                
                const SizedBox(height: 12),
                
                // Theme card
                _SettingsCard(
                  child: Column(
                    children: [
                      _SettingsItemWithAction(
                        title: 'Theme Mode',
                        subtitle: _getThemeModeText(themeMode),
                        icon: Icons.brightness_6,
                        hasNavigation: true,
                        onTap: () => _showThemeModeDialog(context, ref, themeMode),
                      ),
                      
                      Divider(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                      
                      _SettingsItemWithAction(
                        title: 'Color Scheme',
                        subtitle: _getColorSchemeName(colorScheme),
                        icon: Icons.palette,
                        hasNavigation: true,
                        onTap: () => _showColorSchemeDialog(context, ref, colorScheme),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Data Management section
                _SectionHeader(
                  title: 'Data Management',
                  icon: Icons.storage_outlined,
                ),
                
                const SizedBox(height: 12),
                
                // Data management card
                _SettingsCard(
                  child: _SettingsItemWithAction(
                    title: 'Update Database',
                    subtitle: 'Import data from JSON file',
                    icon: Icons.file_upload_outlined,
                    onTap: () => _importFromJson(context, ref),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // About section
                _SectionHeader(
                  title: 'About',
                  icon: Icons.info_outline,
                ),
                
                const SizedBox(height: 12),
                
                // About card
                _SettingsCard(
                  child: Column(
                    children: [
                      _SettingsItem(
                        title: 'Description',
                        subtitle: AppConstants.appDescription,
                        icon: Icons.description_outlined,
                      ),
                      
                      Divider(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                      
                      _SettingsItem(
                        title: 'Developer',
                        subtitle: AppConstants.appDeveloper,
                        icon: Icons.code,
                      ),
                      
                      Divider(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                      
                      _SettingsItemWithAction(
                        title: 'Contact',
                        subtitle: AppConstants.appContactEmail,
                        icon: Icons.email_outlined,
                        onTap: () => _launchSocialLink('mailto:${AppConstants.appContactEmail}'),
                      ),
                      
                      Divider(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.link,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Social Links',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _SocialButton(
                                  icon: Icons.language,
                                  label: 'GitHub',
                                  color: Colors.grey.shade800,
                                  onTap: () => _launchSocialLink(AppConstants.developerGithub),
                                ),
                                _SocialButton(
                                  icon: Icons.webhook,
                                  label: 'Twitter',
                                  color: const Color(0xFF1DA1F2),
                                  onTap: () => _launchSocialLink(AppConstants.developerTwitter),
                                ),
                                _SocialButton(
                                  icon: Icons.facebook,
                                  label: 'Facebook',
                                  color: const Color(0xFF4267B2),
                                  onTap: () => _launchSocialLink(AppConstants.developerFacebook),
                                ),
                                _SocialButton(
                                  icon: Icons.camera_alt,
                                  label: 'Instagram',
                                  color: const Color(0xFFE1306C),
                                  onTap: () => _launchSocialLink(AppConstants.developerInstagram),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Section header with icon
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
        ),
      ],
    );
  }
}

// Settings card with rounded corners
class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: child,
      ),
    );
  }
}

// Basic settings item
class _SettingsItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SettingsItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Settings item with a tap action
class _SettingsItemWithAction extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool hasNavigation;
  final bool isDestructive;

  const _SettingsItemWithAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.hasNavigation = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDestructive 
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: isDestructive
                    ? Theme.of(context).colorScheme.error.withOpacity(0.2)
                    : Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDestructive
                              ? Theme.of(context).colorScheme.error
                              : null,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDestructive
                              ? Theme.of(context).colorScheme.error.withOpacity(0.7)
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
            if (hasNavigation)
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
          ],
        ),
      ),
    );
  }
}

// Color scheme option widget
class _ColorSchemeOption extends StatelessWidget {
  final String title;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorSchemeOption({
    required this.title,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            if (selected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

// Theme mode option widget
class _ThemeModeOption extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeModeOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: selected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

// Social button widget
class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
} 
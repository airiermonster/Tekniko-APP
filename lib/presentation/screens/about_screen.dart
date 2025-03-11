import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../../core/constants/app_constants.dart';
import '../widgets/multi_format_image.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Create rotation animation
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Create scale animation
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _toggleAnimation() {
    setState(() {
      _expanded = !_expanded;
    });
    
    if (_expanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    
    // Add haptic feedback
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const SizedBox(height: 20),
            
            // Animated logo
            Center(
              child: GestureDetector(
                onTap: _toggleAnimation,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Hero(
                          tag: 'app_logo',
                          child: MultiFormatImage(
                            imagePath: 'assets/images/logo.png',
                            width: 120,
                            height: 120,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // App name with animated appearance
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Center(
                child: Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Version with animated appearance
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                // Apply a slight delay effect
                final delayedValue = value < 0.25 ? 0.0 : (value - 0.25) * (1 / 0.75);
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - delayedValue)),
                  child: Opacity(
                    opacity: delayedValue,
                    child: child,
                  ),
                );
              },
              child: Center(
                child: Text(
                  'Version ${AppConstants.appVersion}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // About section with animated entrance
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                // Apply a delay effect
                final delayedValue = value < 0.4 ? 0.0 : (value - 0.4) * (1 / 0.6);
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - delayedValue)),
                  child: Opacity(
                    opacity: delayedValue,
                    child: child,
                  ),
                );
              },
              child: _buildInfoCard(
                context,
                title: "About This App",
                content: "This app was created as a fun project because I was bored and wanted to explore Flutter's capabilities. It demonstrates various patterns and best practices in mobile app development.",
                icon: Icons.info_outline,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Privacy policy section with animated entrance
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                // Apply a delay effect
                final delayedValue = value < 0.6 ? 0.0 : (value - 0.6) * (1 / 0.4);
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - delayedValue)),
                  child: Opacity(
                    opacity: delayedValue,
                    child: child,
                  ),
                );
              },
              child: _buildInfoCard(
                context,
                title: "Privacy Policy",
                content: "This app doesn't collect or share any personal data. All information is stored locally on your device and is not transmitted to any server. Feel free to use the app without any privacy concerns.",
                icon: Icons.privacy_tip_outlined,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // How to use section with animated entrance
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                // Apply a delay effect
                final delayedValue = value < 0.8 ? 0.0 : (value - 0.8) * (1 / 0.2);
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - delayedValue)),
                  child: Opacity(
                    opacity: delayedValue,
                    child: child,
                  ),
                );
              },
              child: _buildInfoCard(
                context,
                title: "How to Use",
                content: "Tap on the logo to see a fun animation! This app demonstrates various UI patterns, animations, and features in Flutter. Explore the different screens and features to see what's possible.",
                icon: Icons.touch_app_outlined,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Footer with animated appearance
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                // Apply a delay effect
                final delayedValue = value < 0.9 ? 0.0 : (value - 0.9) * (1 / 0.1);
                return Opacity(
                  opacity: delayedValue,
                  child: child,
                );
              },
              child: Center(
                child: Text(
                  "© ${DateTime.now().year} • Made with ❤️ in Flutter",
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
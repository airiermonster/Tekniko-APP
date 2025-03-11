import 'package:flutter/material.dart';

class AnimatedSlideTransition extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Duration delay;
  
  const AnimatedSlideTransition({
    super.key,
    required this.child,
    required this.index,
    this.duration = const Duration(milliseconds: 350),
    this.delay = const Duration(milliseconds: 30),
  });

  @override
  State<AnimatedSlideTransition> createState() => _AnimatedSlideTransitionState();
}

class _AnimatedSlideTransitionState extends State<AnimatedSlideTransition> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Calculate a staggered delay based on the index
    final staggeredDelay = Duration(
      milliseconds: widget.delay.inMilliseconds * widget.index,
    );
    
    Future.delayed(staggeredDelay, () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
} 
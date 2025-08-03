import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../theme/app_colors.dart';

class AnimatedPieChart extends StatefulWidget {
  final Map<String, double> data;
  final Map<String, Color> colors;
  final double size;
  final Duration animationDuration;

  const AnimatedPieChart({
    super.key,
    required this.data,
    required this.colors,
    this.size = 200,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<AnimatedPieChart> createState() => _AnimatedPieChartState();
}

class _AnimatedPieChartState extends State<AnimatedPieChart>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: Duration(milliseconds: widget.animationDuration.inMilliseconds ~/ 2),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    // Start animations with a slight delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _scaleController.forward();
      _rotationController.forward();
    });
  }
  
  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
  
  List<PieChartSectionData> _generateSections() {
    final total = widget.data.values.fold(0.0, (sum, value) => sum + value);
    if (total == 0) return [];
    
    final sections = <PieChartSectionData>[];
    
    widget.data.entries.forEach((entry) {
      final percentage = (entry.value / total) * 100;
      
      sections.add(PieChartSectionData(
        color: widget.colors[entry.key] ?? AppColors.chartColors[0],
        value: entry.value,
        title: percentage > 5 ? '${percentage.toInt()}%' : '',
        radius: 80 * _scaleAnimation.value,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.cardBackground,
        ),
      ));
    });
    
    return sections;
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          child: PieChart(
            PieChartData(
              sections: _generateSections(),
              borderData: FlBorderData(show: false),
        sectionsSpace: 2,
              centerSpaceRadius: 30,
              startDegreeOffset: -90,
            ),
          ),
        );
      },
    );
  }
}

class AnimatedBarChart extends StatefulWidget {
  final Map<String, double> data;
  final Color barColor;
  final double maxHeight;
  final Duration animationDuration;
  final Duration staggerDelay;

  const AnimatedBarChart({
    super.key,
    required this.data,
    this.barColor = Colors.blue,
    this.maxHeight = 200,
    this.animationDuration = const Duration(milliseconds: 1200),
    this.staggerDelay = const Duration(milliseconds: 100),
  });

  @override
  State<AnimatedBarChart> createState() => _AnimatedBarChartState();
}

class _AnimatedBarChartState extends State<AnimatedBarChart>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  
  @override
  void initState() {
    super.initState();
    
    final itemCount = widget.data.length;
    _controllers = List.generate(itemCount, (index) {
      return AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      );
    });
    
    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      ));
    }).toList();
    
    // Start animations with staggered delay
    _startStaggeredAnimations();
  }
  
  void _startStaggeredAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(
        Duration(milliseconds: 500 + (i * widget.staggerDelay.inMilliseconds)),
        () {
          if (mounted) {
            _controllers[i].forward();
          }
        },
      );
    }
  }
  
  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final maxValue = widget.data.values.isEmpty 
        ? 1.0 
        : widget.data.values.reduce(math.max);
    
    return Container(
      height: widget.maxHeight + 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: widget.data.entries.map((entry) {
          final index = widget.data.keys.toList().indexOf(entry.key);
          final normalizedHeight = (entry.value / maxValue) * widget.maxHeight;
          
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Value label
                  AnimatedBuilder(
                    animation: _animations[index],
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 10 * (1 - _animations[index].value)),
                        child: Opacity(
                          opacity: _animations[index].value,
                          child: Text(
                            '₹${entry.value.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  
                  // Animated bar
                  AnimatedBuilder(
                    animation: _animations[index],
                    builder: (context, child) {
                      return Container(
                        width: 40,
                        height: normalizedHeight * _animations[index].value,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              widget.barColor,
                              widget.barColor.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.barColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Category label
                  Text(
                    entry.key.length > 8 
                        ? '${entry.key.substring(0, 8)}...' 
                        : entry.key,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class AnalysisLoader extends StatefulWidget {
  final String message;
  final Duration duration;

  const AnalysisLoader({
    super.key,
    this.message = 'Analyzing your expenses...',
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<AnalysisLoader> createState() => _AnalysisLoaderState();
}

class _AnalysisLoaderState extends State<AnalysisLoader>
    with TickerProviderStateMixin {
  late AnimationController _walletController;
  late AnimationController _dotsController;
  late Animation<double> _walletRotation;
  late Animation<double> _dotsOpacity;
  
  @override
  void initState() {
    super.initState();
    
    _walletController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _walletRotation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _walletController,
      curve: Curves.easeInOut,
    ));
    
    _dotsOpacity = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dotsController,
      curve: Curves.easeInOut,
    ));
    
    _walletController.repeat();
    _dotsController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _walletController.dispose();
    _dotsController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Rotating wallet icon
          AnimatedBuilder(
            animation: _walletRotation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _walletRotation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Loading message
          Text(
            widget.message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Progress dots
          AnimatedBuilder(
            animation: _dotsOpacity,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(
                        _dotsOpacity.value * (index == 0 ? 1.0 : index == 1 ? 0.7 : 0.4)
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CalmButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const CalmButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
  });

  @override
  State<CalmButton> createState() => _CalmButtonState();
}

class _CalmButtonState extends State<CalmButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }
  
  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }
  
  void _handleTapCancel() {
    _controller.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: widget.padding ?? const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Theme.of(context).primaryColor,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (widget.backgroundColor ?? Theme.of(context).primaryColor)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  color: widget.foregroundColor ?? Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}

class CalmPageTransition extends PageRouteBuilder {
  final Widget child;
  final TransitionType transitionType;

  CalmPageTransition({
    required this.child,
    this.transitionType = TransitionType.fade,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    switch (transitionType) {
      case TransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      case TransitionType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      case TransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
    }
  }
}

enum TransitionType { fade, slide, scale }

// Helper function for calm navigation
void navigateWithCalmTransition(
  BuildContext context,
  Widget destination, {
  TransitionType transitionType = TransitionType.fade,
}) {
  Navigator.of(context).push(
    CalmPageTransition(
      child: destination,
      transitionType: transitionType,
    ),
  );
}

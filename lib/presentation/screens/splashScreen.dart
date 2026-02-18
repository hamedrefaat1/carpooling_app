import 'dart:async';
import 'dart:math' as math;
import 'package:carpooling_app/constants/constStrings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _backgroundController;
  late AnimationController _particlesController;
  late AnimationController _logoController;
  late AnimationController _carsController;
  late AnimationController _pathController;
  late AnimationController _transitionController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _car1Animation;
  late Animation<double> _car2Animation;
  late Animation<double> _car3Animation;
  late Animation<double> _pathAnimation;
  late Animation<double> _transitionAnimation;

  bool _showTypingAnimation = false;
  bool _showCarpoolingAnimation = false;
  bool _showDescription = false;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 15000),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 20000),
      vsync: this,
    )..repeat();

    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    )..repeat();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _carsController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );

    _pathController = AnimationController(
      duration: const Duration(milliseconds: 6000),
      vsync: this,
    );

    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.15, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.05, 0.25, curve: Curves.elasticOut),
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 4 * math.pi).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );

    _colorAnimation = ColorTween(
      begin: const Color(0xFF6C5CE7),
      end: const Color(0xFF00D4FF),
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeInOut),
      ),
    );

    // car animations - scaled relative to screen width (390 base design width)
    _car1Animation = Tween<double>(begin: -0.51.sw, end: 0.51.sw).animate(
      CurvedAnimation(
        parent: _carsController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _car2Animation = Tween<double>(begin: -0.46.sw, end: 0.46.sw).animate(
      CurvedAnimation(
        parent: _carsController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );

    _car3Animation = Tween<double>(begin: -0.41.sw, end: 0.41.sw).animate(
      CurvedAnimation(
        parent: _carsController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    _pathAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pathController, curve: Curves.easeInOut),
    );

    _transitionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _transitionController, curve: Curves.easeInOut),
    );
  }

  void _startAnimationSequence() {
    _mainController.forward();
    _logoController.forward();

    Timer(const Duration(milliseconds: 4000), () {
      if (mounted) {
        setState(() => _showTypingAnimation = true);
      }
    });

    Timer(const Duration(milliseconds: 7000), () {
      if (mounted) {
        setState(() => _showCarpoolingAnimation = true);
        _pathController.forward();
        _carsController.forward();
      }
    });

    Timer(const Duration(milliseconds: 12000), () {
      if (mounted) {
        setState(() => _showDescription = true);
      }
    });

    Timer(const Duration(milliseconds: 15000), () {
      if (mounted) {
        _startTransitionAnimation();
      }
    });
  }

  void _startTransitionAnimation() async {
    setState(() => _isTransitioning = true);
    await _transitionController.forward();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(signUpScreen);
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _backgroundController.dispose();
    _particlesController.dispose();
    _logoController.dispose();
    _carsController.dispose();
    _pathController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          _buildFloatingParticles(),
          _buildMainContent(),
          _buildGlowEffect(),
          if (_isTransitioning) _buildTransitionOverlay(),
        ],
      ),
    );
  }

  // ─── Animated Background ────────────────────────────────────────────────────

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                math.sin(_backgroundController.value * 2 * math.pi) * 0.3,
                math.cos(_backgroundController.value * 2 * math.pi) * 0.3,
              ),
              radius: 1.8,
              colors: const [
                Color(0xFF0A0A0A),
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
                Color(0xFF0F3460),
                Color(0xFF0A0A0A),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Floating Particles ──────────────────────────────────────────────────────

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particlesController,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: ParticlesPainter(_particlesController.value),
        );
      },
    );
  }

  // ─── Main Content ────────────────────────────────────────────────────────────

  Widget _buildMainContent() {
    return SafeArea(
      child: Center(
        child: AnimatedBuilder(
          animation: _mainController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20.h),

                        // Logo
                        _buildAnimatedLogo(),

                        SizedBox(height: 40.h),

                        // Carpooling Animation
                        if (_showCarpoolingAnimation)
                          _buildCarpoolingAnimation(),

                        if (!_showCarpoolingAnimation) SizedBox(height: 150.h),

                        SizedBox(height: 40.h),

                        // App Name Typing
                        if (_showTypingAnimation) _buildTypingAnimation(),

                        if (!_showTypingAnimation) SizedBox(height: 70.h),

                        SizedBox(height: 30.h),

                        // Description
                        if (_showDescription) _buildAnimatedDescription(),

                        if (!_showDescription) SizedBox(height: 80.h),

                        SizedBox(height: 40.h),

                        // Loader
                        _buildModernLoader(),

                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Animated Logo ───────────────────────────────────────────────────────────

  Widget _buildAnimatedLogo() {
    final logoSize = 160.r;
    final innerSize = 100.r;

    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return SizedBox(
          width: logoSize,
          height: logoSize,
          child: Stack(
            children: [
              // rotating rings
              for (int i = 0; i < 3; i++)
                Positioned.fill(
                  child: Transform.rotate(
                    angle: _rotationAnimation.value + (i * math.pi / 3),
                    child: Container(
                      margin: EdgeInsets.all(i * 15.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: [
                            const Color(0xFF6C5CE7),
                            const Color(0xFF00D4FF),
                            const Color(0xFF74B9FF),
                          ][i].withOpacity(0.4),
                          width: 2.r,
                        ),
                      ),
                    ),
                  ),
                ),

              // center icon
              Center(
                child: Container(
                  width: innerSize,
                  height: innerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (_colorAnimation.value ?? Colors.blue).withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 3.r,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_colorAnimation.value ?? Colors.blue)
                            .withOpacity(0.6),
                        blurRadius: 30.r,
                        spreadRadius: 8.r,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.directions_car_rounded,
                    color: Colors.white,
                    size: 50.r,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Carpooling Animation ────────────────────────────────────────────────────

  Widget _buildCarpoolingAnimation() {
    final containerWidth = 1.sw - 48.w; // full width minus horizontal padding
    final containerHeight = containerWidth * 0.43;
    final centerX = containerWidth / 2;

    return SizedBox(
      width: containerWidth,
      height: containerHeight,
      child: Stack(
        children: [
          // animated path
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pathAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: CarpoolingPathPainter(_pathAnimation.value),
                );
              },
            ),
          ),

          // cars
          AnimatedBuilder(
            animation: _carsController,
            builder: (context, child) {
              return Stack(
                children: [
                  // cyan car
                  Positioned(
                    left: centerX + _car1Animation.value,
                    top: containerHeight * 0.40,
                    child: _buildCarWidget(const Color(0xFF00D4FF)),
                  ),

                  // purple car
                  Positioned(
                    left: centerX + _car2Animation.value,
                    top: containerHeight * 0.25,
                    child: _buildCarWidget(const Color(0xFF6C5CE7)),
                  ),

                  // light blue car
                  Positioned(
                    left: centerX + _car3Animation.value,
                    top: containerHeight * 0.55,
                    child: _buildCarWidget(const Color(0xFF74B9FF)),
                  ),

                  // start point
                  Positioned(
                    left: containerWidth * 0.04,
                    top: containerHeight * 0.42,
                    child: Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 30.r,
                    ),
                  ),

                  // end point
                  Positioned(
                    right: containerWidth * 0.04,
                    top: containerHeight * 0.42,
                    child: Icon(
                      Icons.flag,
                      color: Colors.red,
                      size: 30.r,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 1000.ms).slideY(begin: 0.5);
  }

  Widget _buildCarWidget(Color color) {
    return Transform.scale(
      scale: 0.8,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 10.r,
              spreadRadius: 2.r,
            ),
          ],
        ),
        child: Icon(
          Icons.directions_car,
          color: Colors.white,
          size: 24.r,
        ),
      ),
    );
  }

  // ─── Typing Animation ────────────────────────────────────────────────────────

  Widget _buildTypingAnimation() {
    return AnimatedTextKit(
      animatedTexts: [
        TypewriterAnimatedText(
          'HOPIN',
          textStyle: TextStyle(
            fontSize: 56.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 12.w,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [
                  Colors.white,
                  _colorAnimation.value ?? const Color(0xFF00D4FF),
                  const Color(0xFF6C5CE7),
                  Colors.white,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ).createShader(
                Rect.fromLTWH(0.0, 0.0, 0.7.sw, 70.h),
              ),
            shadows: [
              Shadow(
                color:
                    (_colorAnimation.value ?? Colors.blue).withOpacity(0.8),
                blurRadius: 20.r,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          speed: const Duration(milliseconds: 300),
        ),
      ],
      totalRepeatCount: 1,
      displayFullTextOnTap: false,
      stopPauseOnTap: false,
    );
  }

  // ─── Description ─────────────────────────────────────────────────────────────

  Widget _buildAnimatedDescription() {
    return Column(
      children: [
        AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              'Share Your Journey, Save Together',
              textStyle: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18.sp,
                fontWeight: FontWeight.w400,
                letterSpacing: 2.w,
              ),
              speed: const Duration(milliseconds: 100),
              textAlign: TextAlign.center,
            ),
          ],
          totalRepeatCount: 1,
          displayFullTextOnTap: false,
          stopPauseOnTap: false,
        ),
        SizedBox(height: 15.h),
        Animate(
          effects: const [
            FadeEffect(
              duration: Duration(milliseconds: 1200),
              delay: Duration(milliseconds: 1500),
            ),
            SlideEffect(
              begin: Offset(0, 0.3),
              duration: Duration(milliseconds: 800),
              delay: Duration(milliseconds: 1500),
            ),
          ],
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                'Connect • Travel • Save Money • Help Environment',
                textStyle: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.w,
                ),
                speed: const Duration(milliseconds: 80),
                textAlign: TextAlign.center,
              ),
            ],
            totalRepeatCount: 1,
            displayFullTextOnTap: false,
            stopPauseOnTap: false,
          ),
        ),
      ],
    );
  }

  // ─── Modern Loader ───────────────────────────────────────────────────────────

  Widget _buildModernLoader() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: SizedBox(
            width: 80.r,
            height: 80.r,
            child: CustomPaint(
              painter: ModernLoaderPainter(_mainController.value),
            ),
          ),
        );
      },
    );
  }

  // ─── Glow Effect ─────────────────────────────────────────────────────────────

  Widget _buildGlowEffect() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _mainController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  (_colorAnimation.value ?? Colors.blue).withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Transition Overlay ───────────────────────────────────────────────────────

  Widget _buildTransitionOverlay() {
    return AnimatedBuilder(
      animation: _transitionController,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(_transitionAnimation.value * 0.9),
          child: Center(
            child: Transform.scale(
              scale: 1.0 + (_transitionAnimation.value * 2),
              child: Opacity(
                opacity: 1.0 - _transitionAnimation.value,
                child: Icon(
                  Icons.directions_car_rounded,
                  color: Colors.white,
                  size: 100.r,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Custom Painters ───────────────────────────────────────────────────────────

class CarpoolingPathPainter extends CustomPainter {
  final double animationValue;

  CarpoolingPathPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width * 0.08, size.height / 2);
    path.quadraticBezierTo(
      size.width / 2,
      size.height / 2 - size.height * 0.2,
      size.width * 0.92,
      size.height / 2,
    );

    final pathMetric = path.computeMetrics().first;
    final extractedPath = pathMetric.extractPath(
      0,
      pathMetric.length * animationValue,
    );
    canvas.drawPath(extractedPath, paint);

    if (animationValue > 0.2) {
      final pointPaint = Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..style = PaintingStyle.fill;

      for (double i = 0; i <= animationValue; i += 0.1) {
        final position =
            pathMetric.getTangentForOffset(pathMetric.length * i);
        if (position != null) {
          canvas.drawCircle(position.position, 2, pointPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ParticlesPainter extends CustomPainter {
  final double animationValue;
  final List<Particle> particles = [];

  ParticlesPainter(this.animationValue) {
    for (int i = 0; i < 80; i++) {
      particles.add(Particle());
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final x = (particle.x + animationValue * particle.speedX) % size.width;
      final y = (particle.y + animationValue * particle.speedY) % size.height;

      paint.color = particle.color.withOpacity(
        0.4 *
            (0.5 +
                0.5 *
                    math.sin(
                      animationValue * 2 * math.pi + particle.phase,
                    )),
      );

      canvas.drawCircle(
        Offset(x, y),
        particle.size *
            (0.8 +
                0.4 *
                    math.sin(
                      animationValue * 3 * math.pi + particle.phase,
                    )),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Particle {
  late double x;
  late double y;
  late double speedX;
  late double speedY;
  late double size;
  late Color color;
  late double phase;

  Particle() {
    x = math.Random().nextDouble() * 400;
    y = math.Random().nextDouble() * 800;
    speedX = (math.Random().nextDouble() - 0.5) * 50;
    speedY = (math.Random().nextDouble() - 0.5) * 50;
    size = math.Random().nextDouble() * 4 + 1;
    phase = math.Random().nextDouble() * 2 * math.pi;

    final colors = [
      Colors.white,
      const Color(0xFF6C5CE7),
      const Color(0xFF00D4FF),
      const Color(0xFF74B9FF),
    ];
    color = colors[math.Random().nextInt(colors.length)];
  }
}

class ModernLoaderPainter extends CustomPainter {
  final double animationValue;

  ModernLoaderPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 4; i++) {
      final paint = Paint()
        ..color = [
          const Color(0xFF6C5CE7),
          const Color(0xFF00D4FF),
          const Color(0xFF74B9FF),
          const Color(0xFFFFFFFF),
        ][i].withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      final currentRadius = radius - (i * 6);
      final startAngle = (animationValue * 3 * math.pi) + (i * math.pi / 2);
      const sweepAngle = math.pi * 0.8;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: currentRadius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
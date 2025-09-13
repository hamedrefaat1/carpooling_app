import 'dart:async';
import 'dart:math' as math;
import 'package:carpooling_app/constants/constStrings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    // timer inimation 15 second
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

    _colorAnimation =
        ColorTween(
          begin: const Color(0xFF6C5CE7),
          end: const Color(0xFF00D4FF),
        ).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.2, 0.6, curve: Curves.easeInOut),
          ),
        );

    _car1Animation = Tween<double>(begin: -200.0, end: 200.0).animate(
      CurvedAnimation(
        parent: _carsController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _car2Animation = Tween<double>(begin: -180.0, end: 180.0).animate(
      CurvedAnimation(
        parent: _carsController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );

    _car3Animation = Tween<double>(begin: -160.0, end: 160.0).animate(
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
        setState(() {
          _showTypingAnimation = true;
        });
      }
    });

    Timer(const Duration(milliseconds: 7000), () {
      if (mounted) {
        setState(() {
          _showCarpoolingAnimation = true;
        });
        _pathController.forward();
        _carsController.forward();
      }
    });

    Timer(const Duration(milliseconds: 12000), () {
      if (mounted) {
        setState(() {
          _showDescription = true;
        });
      }
    });

    Timer(const Duration(milliseconds: 15000), () {
      if (mounted) {
        _startTransitionAnimation();
      }
    });
  }

  void _startTransitionAnimation() async {
    setState(() {
      _isTransitioning = true;
    });

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
              colors: [
                const Color(0xFF0A0A0A),
                const Color(0xFF1A1A2E),
                const Color(0xFF16213E),
                const Color(0xFF0F3460),
                const Color(0xFF0A0A0A),
              ],
            ),
          ),
        );
      },
    );
  }

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

  Widget _buildMainContent() {
    return Center(
      child: AnimatedBuilder(
        animation: _mainController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // logo app
                  _buildAnimatedLogo(),

                  const SizedBox(height: 60),

                  // inamiation carpooling
                  if (_showCarpoolingAnimation) _buildCarpoolingAnimation(),

                  const SizedBox(height: 60),

                  // name app and slowly weirning
                  if (_showTypingAnimation) _buildTypingAnimation(),

                  const SizedBox(height: 40),

                  // descripuion
                  if (_showDescription) _buildAnimatedDescription(),

                  const SizedBox(height: 80),

                  // loading pionter
                  _buildModernLoader(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Container(
          width: 160,
          height: 160,
          child: Stack(
            children: [
              // moving circle
              for (int i = 0; i < 3; i++)
                Positioned.fill(
                  child: Transform.rotate(
                    angle: _rotationAnimation.value + (i * math.pi / 3),
                    child: Container(
                      margin: EdgeInsets.all(i * 15.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: [
                            const Color(0xFF6C5CE7),
                            const Color(0xFF00D4FF),
                            const Color(0xFF74B9FF),
                          ][i].withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),

              // centeral logo
              Center(
                child: Container(
                  width: 100,
                  height: 100,
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
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_colorAnimation.value ?? Colors.blue)
                            .withOpacity(0.6),
                        blurRadius: 30,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_car_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCarpoolingAnimation() {
    return Container(
      width: 350,
      height: 150,
      child: Stack(
        children: [
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

          AnimatedBuilder(
            animation: _carsController,
            builder: (context, child) {
              return Stack(
                children: [
                  // blue car
                  Positioned(
                    left: 175 + _car1Animation.value,
                    top: 60,
                    child: Transform.scale(
                      scale: 0.8,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D4FF),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00D4FF).withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.directions_car,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),

                  // praple car
                  Positioned(
                    left: 175 + _car2Animation.value,
                    top: 40,
                    child: Transform.scale(
                      scale: 0.8,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C5CE7),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C5CE7).withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.directions_car,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),

                  //car 3 blue 2
                  Positioned(
                    left: 175 + _car3Animation.value,
                    top: 80,
                    child: Transform.scale(
                      scale: 0.8,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF74B9FF),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF74B9FF).withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.directions_car,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),

                  // start piont
                  const Positioned(
                    left: 20,
                    top: 65,
                    child: Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 30,
                    ),
                  ),

                  // end piont
                  const Positioned(
                    right: 20,
                    top: 65,
                    child: Icon(Icons.flag, color: Colors.red, size: 30),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 1000.ms).slideY(begin: 0.5);
  }

  Widget _buildTypingAnimation() {
    return AnimatedTextKit(
      animatedTexts: [
        TypewriterAnimatedText(
          'HOPIN',
          textStyle: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w900,
            letterSpacing: 12,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [
                  Colors.white,
                  _colorAnimation.value ?? const Color(0xFF00D4FF),
                  const Color(0xFF6C5CE7),
                  Colors.white,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ).createShader(const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0)),
            shadows: [
              Shadow(
                color: (_colorAnimation.value ?? Colors.blue).withOpacity(0.8),
                blurRadius: 20,
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

  Widget _buildAnimatedDescription() {
    return Column(
      children: [
        AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              'Share Your Journey, Save Together',
              textStyle: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 20,
                fontWeight: FontWeight.w400,
                letterSpacing: 2,
              ),
              speed: const Duration(milliseconds: 100),
              textAlign: TextAlign.center,
            ),
          ],
          totalRepeatCount: 1,
          displayFullTextOnTap: false,
          stopPauseOnTap: false,
        ),
        const SizedBox(height: 15),

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
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1,
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

  Widget _buildModernLoader() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: SizedBox(
            width: 80,
            height: 80,
            child: CustomPaint(
              painter: ModernLoaderPainter(_mainController.value),
            ),
          ),
        );
      },
    );
  }

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
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: Colors.white,
                  size: 100,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

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

    path.moveTo(40, size.height / 2);
    path.quadraticBezierTo(
      size.width / 2,
      size.height / 2 - 20,
      size.width - 40,
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
        final position = pathMetric.getTangentForOffset(pathMetric.length * i);
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
                0.5 * math.sin(animationValue * 2 * math.pi + particle.phase)),
      );

      canvas.drawCircle(
        Offset(x, y),
        particle.size *
            (0.8 +
                0.4 * math.sin(animationValue * 3 * math.pi + particle.phase)),
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
      final sweepAngle = math.pi * 0.8;

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

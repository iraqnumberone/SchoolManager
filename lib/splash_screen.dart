import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/auth/auth_screen.dart';
import 'package:school_app/core/app_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _dotsController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _dotsAnimation;

  @override
  void initState() {
    super.initState();

    // متحكم تأثير الشعار
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // متحكم تأثير النص
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // متحكم تأثير النقاط المتحركة
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    // تأثير تكبير الشعار
    _logoScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 1.2).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_logoController);

    // تأثير ظهور الشعار
    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // تأثير انزلاق النص من الأسفل
    _textSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    // تأثير النقاط المتحركة
    _dotsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dotsController,
      curve: Curves.easeInOut,
    ));

    // بدء التأثيرات بالتسلسل
    _startAnimations();
  }

  void _startAnimations() async {
    // انتظار قصير ثم بدء تأثير الشعار
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    // انتظار ثم بدء تأثير النص
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    // بدء تأثير النقاط مباشرة
    _dotsController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 3500,
      splash: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConfig.primaryColor.withValues(alpha: 0.9),
              AppConfig.primaryDark.withValues(alpha: 0.8),
              AppConfig.secondaryColor.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Stack(
          children: [
            // خلفية متحركة مع دوائر متداخلة
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _dotsController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: AnimatedBackgroundPainter(_dotsAnimation.value),
                  );
                },
              ),
            ),

            // محتوى الشاشة الرئيسي
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // الشعار المتحرك
                  AnimatedBuilder(
                    animation: Listenable.merge([_logoController, _logoOpacityAnimation]),
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacityAnimation.value,
                        child: Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.9),
                                  AppConfig.primaryLight.withValues(alpha: 0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  spreadRadius: 8,
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                                BoxShadow(
                                  color: AppConfig.primaryColor.withValues(alpha: 0.2),
                                  spreadRadius: 4,
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.school_rounded,
                              size: 80,
                              color: AppConfig.primaryColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // النص المتحرك
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _textSlideAnimation.value),
                        child: Opacity(
                          opacity: _textController.value,
                          child: Column(
                            children: [
                              Text(
                                AppConfig.appName,
                                style: GoogleFonts.cairo(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      offset: const Offset(2, 2),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'نظام إدارة تعليمي متطور',
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  letterSpacing: 0.8,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      offset: const Offset(1, 1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 60),

                  // مؤشر التحميل المتحرك
                  AnimatedBuilder(
                    animation: _dotsController,
                    builder: (context, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(
                                alpha: index == 0
                                    ? (_dotsAnimation.value > 0.66 ? 1.0 : 0.3)
                                    : index == 1
                                        ? (_dotsAnimation.value > 0.33 && _dotsAnimation.value <= 0.66 ? 1.0 : 0.3)
                                        : (_dotsAnimation.value <= 0.33 ? 1.0 : 0.3),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      nextScreen: const AuthScreen(),
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Colors.transparent,
      splashIconSize: 400,
    );
  }
}

// رسام الخلفية المتحركة
class AnimatedBackgroundPainter extends CustomPainter {
  final double animationValue;

  AnimatedBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05 * animationValue)
      ..style = PaintingStyle.fill;

    // رسم دوائر متحركة في الخلفية
    for (int i = 0; i < 5; i++) {
      final radius = (size.width * 0.3 + i * 40) * animationValue;
      final center = Offset(
        size.width * (0.2 + i * 0.15),
        size.height * (0.8 - i * 0.1),
      );

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// شاشة البداية المخصصة مع خلفية Gradient
class CustomSplashScreen extends StatelessWidget {
  const CustomSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppConfig.primaryColor.withValues(alpha: 0.9),
            AppConfig.primaryDark.withValues(alpha: 0.8),
            AppConfig.secondaryColor.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: const SplashScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:task/route.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Stay Focused",
      "subtitle": "Organize your day and increase productivity with smart task management.",
      "icon": Icons.center_focus_strong,
      "iconColor": Colors.blue
    },
    {
      "title": "Track Your Tasks",
      "subtitle": "Manage your daily goals efficiently and never miss important deadlines.",
      "icon": Icons.check_circle_outline,
      "iconColor": Colors.green
    },
    {
      "title": "Achieve Your Goals",
      "subtitle": "Complete tasks and improve every day with our productivity tools.",
      "icon": Icons.emoji_events_outlined,
      "iconColor": Colors.orange
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.white,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  _animationController.reset();
                  _animationController.forward();
                },
                itemBuilder: (context, index) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: EdgeInsets.all(isTablet ? 60.0 : 40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated Icon
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              width: isTablet ? 180 : 140,
                              height: isTablet ? 180 : 140,
                              decoration: BoxDecoration(
                                color: _onboardingData[index]['iconColor'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(isTablet ? 90 : 70),
                                boxShadow: [
                                  BoxShadow(
                                    color: _onboardingData[index]['iconColor'].withOpacity(0.2),
                                    spreadRadius: 0,
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _onboardingData[index]['icon'],
                                size: isTablet ? 90 : 70,
                                color: _onboardingData[index]['iconColor'],
                              ),
                            ),
                            
                            SizedBox(height: isTablet ? 50 : 40),
                            
                            // Title
                            Text(
                              _onboardingData[index]['title'],
                              style: TextStyle(
                                fontSize: isTablet ? 32 : 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            SizedBox(height: isTablet ? 20 : 15),
                            
                            // Subtitle
                            Text(
                              _onboardingData[index]['subtitle'],
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom navigation (dots + buttons)
            Container(
              padding: EdgeInsets.all(isTablet ? 30.0 : 20.0),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? (isTablet ? 30 : 24) : (isTablet ? 12 : 8),
                        height: isTablet ? 12 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? Colors.blue : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(isTablet ? 6 : 4),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: isTablet ? 30 : 25),
                  
                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip button
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, Routes.home);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 24 : 20,
                            vertical: isTablet ? 12 : 10,
                          ),
                        ),
                        child: Text(
                          "Skip",
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),

                      // Next / Get Started button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 32 : 24,
                            vertical: isTablet ? 16 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (_currentPage == _onboardingData.length - 1) {
                            Navigator.pushReplacementNamed(context, Routes.home);
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Text(
                          _currentPage == _onboardingData.length - 1
                              ? "Get Started"
                              : "Next",
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

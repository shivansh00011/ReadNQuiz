import 'package:flutter/material.dart';
import 'package:readnquiz/screens%20and%20logic/chatpdf.dart';
import 'package:readnquiz/screens%20and%20logic/homepage.dart';
import 'package:readnquiz/screens%20and%20logic/profile.dart';

class Nav extends StatefulWidget {
  const Nav({super.key});

  @override
  State<Nav> createState() => _NavState();
}

class _NavState extends State<Nav> with TickerProviderStateMixin{
 int _currentIndex = 0;
  late final PageController _pageController;
  late final AnimationController _navAnimationController;
  late final Animation<double> _bounceAnimation;

  final List<Widget> _pages = const [
    Homepage(),
    PDFHomePage(),
    Profile()
    
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _navAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _bounceAnimation = CurvedAnimation(
      parent: _navAnimationController,
      curve: Curves.elasticOut,
    );
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    _navAnimationController.forward(from: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _navAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 30, 60, 114),
            Color.fromARGB(255, 42, 82, 152),
            Color.fromARGB(255, 109, 213, 250)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          itemCount: _pages.length,
          itemBuilder: (context, index) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _pages[index],
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 239, 218, 103),
        
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            )
          ],
        ),
        child: BottomNavigationBar(
          
          currentIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey.shade600,
          selectedFontSize: 12,
          
          unselectedFontSize: 10,
          items: [
            _navItem(Icons.home_outlined, "Home", 0),
            _navItem(Icons.notes, "Chat with PDF", 1),
            _navItem(Icons.person_outline, "Profile", 2),
           
          ],
          onTap: _onTabTapped,
        ),
      ),
    );
  }

  BottomNavigationBarItem _navItem(IconData icon, String label, int index) {
  final isSelected = _currentIndex == index;
  return BottomNavigationBarItem(
    icon: AnimatedScale(
      scale: isSelected ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Icon(icon),
      ),
    ),
    label: label,
  );
}
}
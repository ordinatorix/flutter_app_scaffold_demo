import 'package:flutter/material.dart';

import '../../../logger.dart';

final log = getLogger('SplashScreen');

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    log.i('building splash screen');
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Colors.grey,
              Colors.black,
            ],
            radius: 0.7,
          ),
        ),
        width: double.infinity,
        height: (mediaQuery.size.height),
        child: Container(
          child: Center(
            child: Image.asset(
              'assets/images/flutter_logo1.png',
            ),
          ),
        ),
      ),
    );
  }
}

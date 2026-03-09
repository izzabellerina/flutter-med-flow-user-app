import 'package:flutter/material.dart';
import '../app/theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hospital illustration placeholder
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.bgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.local_hospital,
                      size: 80,
                      color: AppTheme.primaryThemeApp.withValues(alpha: 0.3),
                    ),
                    Positioned(
                      top: 30,
                      right: 30,
                      child: Icon(
                        Icons.airplanemode_active,
                        size: 24,
                        color: AppTheme.primary2.withValues(alpha: 0.5),
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      left: 25,
                      child: Icon(
                        Icons.location_on,
                        size: 28,
                        color: Colors.red.withValues(alpha: 0.5),
                      ),
                    ),
                    Positioned(
                      top: 25,
                      left: 35,
                      child: Icon(
                        Icons.cloud,
                        size: 24,
                        color: Colors.grey.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'พบกับหน้าแรกในเร็ว ๆ นี้',
                style: AppTheme.generalText(
                  20,
                  fonWeight: FontWeight.w500,
                  color: AppTheme.primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Version 1.0.0.1',
                style: AppTheme.generalText(
                  14,
                  color: AppTheme.secondaryText62,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

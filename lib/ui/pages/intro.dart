import 'package:flutter/material.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key, required this.onComplete});

  final Future<void> Function() onComplete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Intro Screen',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              const Text('This is the introduction screen.'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onComplete,
                child: const Text('Complete Intro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

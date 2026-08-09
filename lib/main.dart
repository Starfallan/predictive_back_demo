import 'package:flutter/material.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Predictive back direction bug',
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          },
        ),
      ),
      home: const PageA(),
    );
  }
}

/// Mimics routing packages (e.g. GetX) whose routes never run a secondary
/// animation for the route below.
class NoSecondaryAnimationPageRoute<T> extends MaterialPageRoute<T> {
  NoSecondaryAnimationPageRoute({required super.builder});

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) => false;
}

class PageA extends StatelessWidget {
  const PageA({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page A (root)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: <Widget>[
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PageB(pushFullscreenDialog: true),
                ),
              ),
              child: const Text('Scenario 1: fullscreenDialog on top'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                NoSecondaryAnimationPageRoute<void>(
                  builder: (_) => const PageB(pushFullscreenDialog: false),
                ),
              ),
              child: const Text('Scenario 2: canTransitionTo => false'),
            ),
          ],
        ),
      ),
    );
  }
}

class PageB extends StatelessWidget {
  const PageB({super.key, required this.pushFullscreenDialog});

  final bool pushFullscreenDialog;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade100,
      appBar: AppBar(title: const Text('Page B')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: <Widget>[
              FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    fullscreenDialog: pushFullscreenDialog,
                    builder: (_) => const PageC(),
                  ),
                ),
                child: const Text('Push page C'),
              ),
              const Text(
                '1. Push page C.\n'
                '2. Pop it with a predictive back gesture from the RIGHT edge '
                'and let it commit (page C correctly moves LEFT).\n'
                '3. Back here, gesture again from the RIGHT edge: this page '
                'moves RIGHT (wrong direction).',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PageC extends StatelessWidget {
  const PageC({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade100,
      appBar: AppBar(title: const Text('Page C')),
      body: const Center(
        child: Text('Pop me with a predictive back gesture\n(let it commit)'),
      ),
    );
  }
}

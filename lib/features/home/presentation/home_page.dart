import 'package:flutter/material.dart';

import '../data/repositories/home_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.repository = const HomeRepository()});

  final HomeRepository repository;

  @override
  Widget build(BuildContext context) {
    final welcomeItems = repository.getWelcomeItems();

    return Scaffold(
      appBar: AppBar(title: const Text('UniConnect')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Welcome to UniConnect',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Your university life, connected.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          ...welcomeItems.map(
            (item) => Card(
              child: ListTile(
                title: Text(item.title),
                subtitle: Text(item.description),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

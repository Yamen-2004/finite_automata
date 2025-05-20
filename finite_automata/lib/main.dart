import 'package:finite_automata/providers/automaton_provider.dart';
import 'package:finite_automata/screens/home_screen.dart';
import 'package:finite_automata/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const FiniteAutomataApp());
}

class FiniteAutomataApp extends StatelessWidget {
  const FiniteAutomataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AutomatonProvider(),
      child: MaterialApp(
        title: 'Finite Automata Simulator',
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
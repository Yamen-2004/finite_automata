import 'package:finite_automata/providers/automaton_provider.dart';
import 'package:finite_automata/widgets/app_bar.dart';
import 'package:finite_automata/widgets/automaton_painter.dart';
import 'package:finite_automata/widgets/button_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<String?> _showStateSelectionDialog(BuildContext context, String title) {
    final provider = Provider.of<AutomatonProvider>(context, listen: false);
    return showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: provider.states
            .map(
              (s) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, s.id),
                child: Text(s.id),
              ),
            )
            .toList(),
      ),
    );
  }

  Future<String?> _showSymbolInputDialog(BuildContext context) {
    String? symbol;
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Symbol'),
        content: TextField(
          onChanged: (value) => symbol = value,
          decoration: const InputDecoration(hintText: 'e.g., a, b, 0, 1'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, symbol),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AutomatonProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: const CustomAppBar(title: 'Finite Automata Simulator'),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: provider.setInput,
                  decoration: InputDecoration(
                    labelText: 'Input String (e.g., abba)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.input),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTapDown: (details) {
                    final tapPosition = details.localPosition;
                    String? selectedId;
                    for (var state in provider.states) {
                      final distance = (tapPosition - state.position).distance;
                      if (distance < 30) {
                        selectedId = state.id;
                        break;
                      }
                    }
                    provider.selectState(selectedId);
                  },
                  onPanUpdate: (details) {
                    if (provider.selectedStateId != null) {
                      provider.moveState(provider.selectedStateId!, details.delta);
                    }
                  },
                  child: CustomPaint(
                    painter: AutomatonPainter(
                      states: provider.states,
                      transitions: provider.transitions,
                      selectedStateId: provider.selectedStateId,
                      gridSize: provider.gridSize,
                    ),
                    child: Container(),
                  ),
                ),
              ),
              ButtonBarWidget(
                onAddState: provider.addState,
                onToggleState: provider.toggleState,
                onDeleteState: provider.deleteState,
                onAddTransition: () async {
                  final fromState =
                      await _showStateSelectionDialog(context, 'Select From State');
                  if (fromState == null) return;
                  final toState =
                      await _showStateSelectionDialog(context, 'Select To State');
                  if (toState == null) return;
                  final symbol = await _showSymbolInputDialog(context);
                  if (symbol != null && symbol.isNotEmpty) {
                    try {
                      provider.addTransition(fromState, toState, symbol);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                onDeleteTransition: provider.deleteTransition,
                onResetTransitions: provider.resetTransitions,
                onSetAccepting: () {
                  if (provider.selectedStateId != null) {
                    final state = provider.states
                        .firstWhere((s) => s.id == provider.selectedStateId);
                    provider.setAccepting(!state.isAccept);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a state')),
                    );
                  }
                },
                onSimulateInput: () {
                  final result = provider.simulateInput();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result)),
                  );
                }, onResetInput: () {  },
              ),
            ],
          ),
        );
      },
    );
  }
}
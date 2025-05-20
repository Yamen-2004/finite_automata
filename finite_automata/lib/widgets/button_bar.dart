import 'package:flutter/material.dart';

class ButtonBarWidget extends StatelessWidget {
  final VoidCallback onAddState;
  final VoidCallback onToggleState;
  final VoidCallback onDeleteState;
  final VoidCallback onAddTransition;
  final VoidCallback onDeleteTransition;
  final VoidCallback onResetTransitions;
  final VoidCallback onSetAccepting;
  final VoidCallback onSimulateInput;

  const ButtonBarWidget({
    super.key,
    required this.onAddState,
    required this.onToggleState,
    required this.onDeleteState,
    required this.onAddTransition,
    required this.onDeleteTransition,
    required this.onResetTransitions,
    required this.onSetAccepting,
    required this.onSimulateInput, required Null Function() onResetInput,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButtonColumn(context, 'States', [
              _buildButton('Add State', onAddState, Icons.add_circle),
              _buildButton('Set Start', onToggleState, Icons.swap_horiz),
              _buildButton('Set Accepting', onSetAccepting, Icons.check_circle),
              _buildButton('Delete State', onDeleteState, Icons.delete),
            ]),
            _buildButtonColumn(context, 'Transitions', [
              _buildButton('Add Transition', onAddTransition, Icons.arrow_forward),
              _buildButton('Delete Transition', onDeleteTransition, Icons.remove_circle),
              _buildButton('Reset Transitions', onResetTransitions, Icons.restart_alt),
            ]),
            _buildButtonColumn(context, 'Simulation', [
              _buildButton('Simulate', onSimulateInput, Icons.play_arrow),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonColumn(BuildContext context, String title, List<Widget> buttons) {
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...buttons,
      ],
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Tooltip(
        message: label,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(140, 48),
          ),
        ),
      ),
    );
  }
}
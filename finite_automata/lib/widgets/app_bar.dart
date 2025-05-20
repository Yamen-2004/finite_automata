import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finite_automata/providers/automaton_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AutomatonProvider>(context);
    return AppBar(
      title: Text(title),
      backgroundColor: Theme.of(context).colorScheme.primary,
      actions: [
        IconButton(
          icon: const Icon(Icons.undo, color: Colors.white),
          onPressed: provider.canUndo ? provider.undo : null,
          tooltip: 'Undo',
        ),
        IconButton(
          icon: const Icon(Icons.redo, color: Colors.white),
          onPressed: provider.canRedo ? provider.redo : null,
          tooltip: 'Redo',
        ),
        IconButton(
          icon: const Icon(Icons.save, color: Colors.white),
          onPressed: () async {
            try {
              await provider.saveAutomaton();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Automaton saved')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
          tooltip: 'Save',
        ),
        IconButton(
          icon: const Icon(Icons.folder_open, color: Colors.white),
          onPressed: () async {
            try {
              await provider.loadAutomaton();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Automaton loaded')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
          tooltip: 'Load',
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                double newGridSize = provider.gridSize;
                return AlertDialog(
                  title: const Text('Grid Size'),
                  content: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter grid size (pixels)',
                    ),
                    onChanged: (value) {
                      newGridSize = double.tryParse(value) ?? provider.gridSize;
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        provider.setGridSize(newGridSize);
                        Navigator.pop(context);
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                );
              },
            );
          },
          tooltip: 'Settings',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
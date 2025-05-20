import 'dart:ui';

import 'package:finite_automata/models/state_node.dart';
import 'package:finite_automata/models/transtion.dart';

class AutomatonService {
  String simulateInput(
    List<StateNode> states,
    List<transitionModel> transitions,
    String input,
  ) {
    final startState = states.firstWhere(
      (s) => s.isStart,
      orElse: () => StateNode(id: '', position: Offset.zero),
    );
    if (startState.id.isEmpty) {
      return 'No start state defined';
    }

    String current = startState.id;
    for (var symbol in input.split('')) {
      final match = transitions.firstWhere(
        (t) => t.fromState == current && t.symbol == symbol,
        orElse: () => transitionModel(fromState: '', toState: '', symbol: ''),
      );
      if (match.fromState.isEmpty) {
        return 'Input rejected: No valid transition for symbol "$symbol"';
      }
      current = match.toState;
    }

    final accepted = states.any((s) => s.id == current && s.isAccept);
    return accepted ? 'Input accepted' : 'Input rejected';
  }

  String validateTransition(
    List<StateNode> states,
    String fromState,
    String toState,
    String symbol,
  ) {
    if (states.every((s) => s.id != fromState)) {
      return 'Invalid from state';
    }
    if (states.every((s) => s.id != toState)) {
      return 'Invalid to state';
    }
    if (symbol.isEmpty) {
      return 'Symbol cannot be empty';
    }
    return '';
  }
}
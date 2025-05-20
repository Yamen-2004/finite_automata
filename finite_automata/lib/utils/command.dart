import 'package:finite_automata/models/state_node.dart';
import 'package:finite_automata/models/transtion.dart';

abstract class Command {
  void execute();
  void undo();
}

class AddStateCommand implements Command {
  final List<StateNode> states;
  final StateNode state;

  AddStateCommand(this.states, this.state);

  @override
  void execute() {
    states.add(state);
  }

  @override
  void undo() {
    states.remove(state);
  }
}

class DeleteStateCommand implements Command {
  final List<StateNode> states;
  final List<transitionModel> transitions;
  final StateNode state;
  final List<transitionModel> removedTransitions;

  DeleteStateCommand(this.states, this.transitions, this.state)
      : removedTransitions = transitions
            .where((t) => t.fromState == state.id || t.toState == state.id)
            .toList();

  @override
  void execute() {
    states.remove(state);
    transitions.removeWhere((t) => t.fromState == state.id || t.toState == state.id);
  }

  @override
  void undo() {
    states.add(state);
    transitions.addAll(removedTransitions);
  }
}

class AddTransitionCommand implements Command {
  final List<transitionModel> transitions;
  final transitionModel transition;

  AddTransitionCommand(this.transitions, this.transition);

  @override
  void execute() {
    transitions.add(transition);
  }

  @override
  void undo() {
    transitions.remove(transition);
  }
}
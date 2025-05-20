import 'package:finite_automata/models/state_node.dart';
import 'package:finite_automata/models/transtion.dart';
import 'package:finite_automata/services/automaton_service.dart';
import 'package:finite_automata/services/storage_service.dart';
import 'package:finite_automata/utils/command.dart';
import 'package:flutter/material.dart';

class AutomatonProvider extends ChangeNotifier {
  final AutomatonService _automatonService = AutomatonService();
  final StorageService _storageService = StorageService();
  List<StateNode> _states = [];
  List<transitionModel> _transitions = [];
  String _currentInput = '';
  String? _selectedStateId;
  int _stateCounter = 0;
  double _gridSize = 40.0;
  final List<Command> _commandHistory = [];
  int _commandIndex = -1;

  List<StateNode> get states => _states;
  List<transitionModel> get transitions => _transitions;
  String get currentInput => _currentInput;
  String? get selectedStateId => _selectedStateId;
  double get gridSize => _gridSize;
  bool get canUndo => _commandIndex >= 0;
  bool get canRedo => _commandIndex < _commandHistory.length - 1;

  void addState() {
    final newId = 'q$_stateCounter';
    _stateCounter++;
    final state = StateNode(
      id: newId,
      position: Offset(100.0 + _states.length * 100, 100.0),
    );
    final command = AddStateCommand(_states, state);
    _executeCommand(command);
  }

  void deleteState() {
    if (_selectedStateId == null) return;
    final state = _states.firstWhere((s) => s.id == _selectedStateId);
    final command = DeleteStateCommand(_states, _transitions, state);
    _executeCommand(command);
    _selectedStateId = null;
  }

  void toggleState() {
    if (_selectedStateId == null) return;
    final state = _states.firstWhere((s) => s.id == _selectedStateId);
    if (!state.isStart) {
      for (var s in _states) {
        s.isStart = false;
      }
      state.isStart = true;
    } else {
      state.isStart = false;
    }
    notifyListeners();
  }

  void setAccepting(bool isAccepting) {
    if (_selectedStateId == null) return;
    final state = _states.firstWhere((s) => s.id == _selectedStateId);
    state.isAccept = isAccepting;
    notifyListeners();
  }

  void addTransition(String fromState, String toState, String symbol) {
    final validationError =
        _automatonService.validateTransition(_states, fromState, toState, symbol);
    if (validationError.isNotEmpty) {
      throw Exception(validationError);
    }
    final transition = transitionModel(
      fromState: fromState,
      toState: toState,
      symbol: symbol,
    );
    final command = AddTransitionCommand(_transitions, transition);
    _executeCommand(command);
  }

  void deleteTransition() {
    if (_transitions.isNotEmpty) {
      final transition = _transitions.last;
      final command = AddTransitionCommand(_transitions, transition);
      _transitions.removeLast();
      _commandHistory.add(command);
      _commandIndex++;
      notifyListeners();
    }
  }

  void resetTransitions() {
    _transitions.clear();
    _commandHistory.clear();
    _commandIndex = -1;
    notifyListeners();
  }

  void setInput(String input) {
    _currentInput = input;
    notifyListeners();
  }

  void resetInput() {
    _currentInput = '';
    notifyListeners();
  }

  String simulateInput() {
    return _automatonService.simulateInput(_states, _transitions, _currentInput);
  }

  void selectState(String? stateId) {
    _selectedStateId = stateId;
    notifyListeners();
  }

  void moveState(String stateId, Offset delta) {
    final state = _states.firstWhere((s) => s.id == stateId);
    state.position += delta;
    notifyListeners();
  }

  void setGridSize(double size) {
    _gridSize = size.clamp(10.0, 100.0);
    notifyListeners();
  }

  void undo() {
    if (canUndo) {
      _commandHistory[_commandIndex].undo();
      _commandIndex--;
      notifyListeners();
    }
  }

  void redo() {
    if (canRedo) {
      _commandIndex++;
      _commandHistory[_commandIndex].execute();
      notifyListeners();
    }
  }

  Future<void> saveAutomaton() async {
    await _storageService.saveAutomaton(_states, _transitions);
  }

  Future<void> loadAutomaton() async {
    final data = await _storageService.loadAutomaton();
    _states = (data['states'] as List)
        .map((json) => StateNode.fromJson(json))
        .toList();
    _transitions = (data['transitions'] as List)
        .map((json) => transitionModel.fromJson(json))
        .toList();
    _stateCounter = _states.length;
    notifyListeners();
  }

  void _executeCommand(Command command) {
    if (_commandIndex < _commandHistory.length - 1) {
      _commandHistory.removeRange(_commandIndex + 1, _commandHistory.length);
    }
    command.execute();
    _commandHistory.add(command);
    _commandIndex++;
    notifyListeners();
  }
}
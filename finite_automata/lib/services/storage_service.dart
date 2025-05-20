import 'dart:convert';
import 'dart:io';
import 'package:finite_automata/models/state_node.dart';
import 'package:finite_automata/models/transtion.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/automaton.json');
  }

  Future<void> saveAutomaton(List<StateNode> states, List<transitionModel> transitions) async {
    try {
      final file = await _localFile;
      final data = {
        'states': states.map((s) => s.toJson()).toList(),
        'transitions': transitions.map((t) => t.toJson()).toList(),
      };
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      throw Exception('Failed to save automaton: $e');
    }
  }

  Future<Map<String, dynamic>> loadAutomaton() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        return jsonDecode(contents);
      }
      return {'states': [], 'transitions': []};
    } catch (e) {
      throw Exception('Failed to load automaton: $e');
    }
  }
}
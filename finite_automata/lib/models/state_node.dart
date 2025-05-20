import 'package:flutter/material.dart';

class StateNode {
  final String id;
  Offset position;
  bool isStart;
  bool isAccept;

  StateNode({
    required this.id,
    required this.position,
    this.isStart = false,
    this.isAccept = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'position': {'dx': position.dx, 'dy': position.dy},
        'isStart': isStart,
        'isAccept': isAccept,
      };

  factory StateNode.fromJson(Map<String, dynamic> json) => StateNode(
        id: json['id'],
        position: Offset(json['position']['dx'], json['position']['dy']),
        isStart: json['isStart'],
        isAccept: json['isAccept'],
      );
}
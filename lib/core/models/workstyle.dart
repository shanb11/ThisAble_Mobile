import 'package:flutter/material.dart';

class Workstyle {
  final String id;
  final String title;
  final IconData icon;
  final String badge;
  final String description;
  final String imagePath;
  final List<String> features;

  const Workstyle({
    required this.id,
    required this.title,
    required this.icon,
    required this.badge,
    required this.description,
    required this.imagePath,
    required this.features,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Workstyle && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Workstyle(id: $id, title: $title)';
}

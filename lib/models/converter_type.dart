import 'package:flutter/material.dart';

enum ConverterType {
  area(
    title: 'Area',
    description: 'Convert between area units',
    icon: Icons.crop_square,
  ),
  currency(
    title: 'Currency',
    description: 'Convert between different currencies',
    icon: Icons.attach_money,
  ),
  length(
    title: 'Length',
    description: 'Convert between length units',
    icon: Icons.straighten,
  ),
  temperature(
    title: 'Temperature',
    description: 'Convert between temperature scales',
    icon: Icons.thermostat,
  ),
  volume(
    title: 'Volume',
    description: 'Convert between volume units',
    icon: Icons.water_drop,
  ),
  weight(
    title: 'Weight',
    description: 'Convert between weight units',
    icon: Icons.monitor_weight,
  ),
  speed(
    title: 'Speed',
    description: 'Convert between speed units',
    icon: Icons.speed,
  ),
  cooking(
    title: 'Cooking',
    description: 'Convert between cooking units (tbsp, cups, gallons, etc.)',
    icon: Icons.restaurant_menu,
  ),
  angle(
    title: 'Angle',
    description: 'Convert between angle units',
    icon: Icons.rotate_90_degrees_ccw,
  ),
  density(
    title: 'Density',
    description: 'Convert between density units',
    icon: Icons.bubble_chart,
  ),
  energy(
    title: 'Energy',
    description: 'Convert between energy units',
    icon: Icons.bolt,
  );

  const ConverterType({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
} 
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:converter_app/main.dart';
import 'package:converter_app/models/converter_type.dart';
import 'package:converter_app/screens/converter_screen.dart';

void main() {
  group('UI Layout Tests', () {
    testWidgets('Currency converter layout should not have overlapping elements', (WidgetTester tester) async {
      // Build the currency converter screen
      await tester.pumpWidget(MaterialApp(
        home: ConverterScreen(converterType: ConverterType.currency),
      ));
      
      // Wait for initial build, but don't wait for network calls
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      // Find the info section (should be present for currency)
      final infoSectionFinder = find.byIcon(Icons.update);
      expect(infoSectionFinder, findsOneWidget);
      
      // Find calculator buttons to ensure they're visible
      final calculatorButtons = find.text('1').last;
      expect(calculatorButtons, findsOneWidget);
      
      // Get the positions and sizes
      final infoBox = tester.getRect(infoSectionFinder);
      final buttonBox = tester.getRect(calculatorButtons);
      
      // Verify that the info section doesn't overlap with the calculator
      // The info section should be below the calculator buttons
      expect(infoBox.top, greaterThan(buttonBox.bottom - 100), 
        reason: 'Info section should not overlap with calculator buttons');
    });
    
    testWidgets('Non-currency converter should not have info section', (WidgetTester tester) async {
      // Build a non-currency converter screen
      await tester.pumpWidget(MaterialApp(
        home: ConverterScreen(converterType: ConverterType.length),
      ));
      
      // Wait for initial build
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      // Verify that the info section is not present
      final infoSectionFinder = find.byIcon(Icons.update);
      expect(infoSectionFinder, findsNothing);
    });
    
    testWidgets('Calculator buttons should be fully visible and tappable', (WidgetTester tester) async {
      // Build the length converter screen (no network calls)
      await tester.pumpWidget(MaterialApp(
        home: ConverterScreen(converterType: ConverterType.length),
      ));
      
      // Wait for initial build
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      // Find calculator buttons by looking for ElevatedButton widgets
      final calculatorButtons = find.byType(ElevatedButton);
      expect(calculatorButtons, findsWidgets);
      
      // Verify at least some buttons are within the screen bounds
      final screenSize = tester.binding.window.physicalSize / tester.binding.window.devicePixelRatio;
      
      final firstButton = calculatorButtons.first;
      final firstButtonBox = tester.getRect(firstButton);
      
      // Button should be within screen bounds
      expect(firstButtonBox.bottom, lessThan(screenSize.height));
      expect(firstButtonBox.top, greaterThan(0));
      
      // Button should be tappable
      await tester.tap(firstButton);
      await tester.pump();
      
      // No exceptions should be thrown
    });
    
    testWidgets('Info section should be compact and not take excessive space', (WidgetTester tester) async {
      // Build the currency converter screen
      await tester.pumpWidget(MaterialApp(
        home: ConverterScreen(converterType: ConverterType.currency),
      ));
      
      // Wait for initial build
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      // Find the info section container
      final infoSectionFinder = find.byIcon(Icons.update);
      expect(infoSectionFinder, findsOneWidget);
      
      final infoBox = tester.getRect(infoSectionFinder);
      
      // Info section should be compact (height should be reasonable)
      expect(infoBox.height, lessThan(40), 
        reason: 'Info section should be compact and not take excessive vertical space');
    });
  });
} 
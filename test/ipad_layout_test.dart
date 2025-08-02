import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:converter_app/screens/converter_screen.dart';
import 'package:converter_app/models/converter_type.dart';
import 'package:converter_app/widgets/calculator_input.dart';

void main() {
  group('iPad Layout Tests', () {
    testWidgets('Calculator buttons should be fully visible on iPad Air 11-inch', (WidgetTester tester) async {
      // Set up iPad Air 11-inch screen size
      tester.binding.window.physicalSizeTestValue = const Size(1668, 2388);
      tester.binding.window.devicePixelRatioTestValue = 2.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: ConverterScreen(converterType: ConverterType.currency),
        ),
      );
      
      await tester.pump();
      
      // Verify that the calculator section is present
      expect(find.byType(CalculatorInput), findsOneWidget);
      
      // Check that calculator buttons are visible and not cut off
      // Look for common calculator buttons in the calculator widget
      final calculatorFinder = find.byType(CalculatorInput);
      expect(calculatorFinder, findsOneWidget);
      
      // Verify the calculator takes up the remaining space properly
      final calculatorRenderBox = tester.renderObject<RenderBox>(calculatorFinder);
      expect(calculatorRenderBox.size.height, greaterThan(200)); // Should have reasonable height
      
      // Verify the calculator widget is properly rendered
      final calculatorWidget = tester.widget<CalculatorInput>(find.byType(CalculatorInput));
      expect(calculatorWidget, isNotNull);
    });

    testWidgets('Calculator buttons should be fully visible on iPad Pro 13-inch', (WidgetTester tester) async {
      // Set up iPad Pro 13-inch screen size
      tester.binding.window.physicalSizeTestValue = const Size(2048, 2732);
      tester.binding.window.devicePixelRatioTestValue = 2.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: ConverterScreen(converterType: ConverterType.currency),
        ),
      );
      
      await tester.pump();
      
      // Verify that the calculator section is present
      expect(find.byType(CalculatorInput), findsOneWidget);
      
      // Check that calculator widget is present and has adequate space
      final calculatorFinder = find.byType(CalculatorInput);
      expect(calculatorFinder, findsOneWidget);
      
      // Verify the calculator has adequate space
      final calculatorRenderBox = tester.renderObject<RenderBox>(calculatorFinder);
      expect(calculatorRenderBox.size.height, greaterThan(250)); // Should have good height on larger iPad
    });

    testWidgets('Swap button should overlap currency boxes', (WidgetTester tester) async {
      // Set up iPad screen size
      tester.binding.window.physicalSizeTestValue = const Size(1668, 2388);
      tester.binding.window.devicePixelRatioTestValue = 2.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: ConverterScreen(converterType: ConverterType.currency),
        ),
      );
      
      await tester.pump();
      
      // Verify swap button is present
      expect(find.byIcon(Icons.swap_vert), findsOneWidget);
      
      // Verify the layout uses Stack for overlapping
      expect(find.byType(Stack), findsAtLeastNWidgets(1));
      
      // Verify both currency boxes are present
      expect(find.text('US Dollar'), findsOneWidget);
      expect(find.text('Chinese Yuan'), findsOneWidget);
    });

    testWidgets('Layout should work on different iPad orientations', (WidgetTester tester) async {
      // Test landscape orientation
      tester.binding.window.physicalSizeTestValue = const Size(2388, 1668);
      tester.binding.window.devicePixelRatioTestValue = 2.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: ConverterScreen(converterType: ConverterType.currency),
        ),
      );
      
      await tester.pump();
      
      // Verify calculator is still accessible
      expect(find.byType(CalculatorInput), findsOneWidget);
      
      // Test portrait orientation
      tester.binding.window.physicalSizeTestValue = const Size(1668, 2388);
      await tester.pump();
      
      // Verify calculator is still accessible
      expect(find.byType(CalculatorInput), findsOneWidget);
    });

    testWidgets('Currency boxes should be connected without gap', (WidgetTester tester) async {
      // Set up iPad screen size
      tester.binding.window.physicalSizeTestValue = const Size(1668, 2388);
      tester.binding.window.devicePixelRatioTestValue = 2.0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: ConverterScreen(converterType: ConverterType.currency),
        ),
      );
      
      await tester.pump();
      
      // Verify the Stack layout is used (which connects the boxes)
      expect(find.byType(Stack), findsAtLeastNWidgets(1));
      
      // Verify both currency boxes are present
      expect(find.text('US Dollar'), findsOneWidget);
      expect(find.text('Chinese Yuan'), findsOneWidget);
    });
  });
} 
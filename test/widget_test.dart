import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:km_test/app/app.dart';
import 'package:km_test/features/session/presentation/bloc/session_bloc.dart';

void main() {
  testWidgets('Palindrome Checker dialog test', (WidgetTester tester) async {
    // We need to bypass GetIt for tests or initialize it.
    // Let's just provide the bloc directly in the test if possible.
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SessionBloc()),
        ],
        child: const App(),
      ),
    );

    // Verify Screen 1 is shown
    expect(find.text('CHECK'), findsOneWidget);

    // Enter a palindrome
    await tester.enterText(find.byType(TextField).last, 'kasur rusak');
    await tester.tap(find.text('CHECK'));
    await tester.pumpAndSettle();

    // Verify dialog shows 'isPalindrome'
    expect(find.text('isPalindrome'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Enter a non-palindrome
    await tester.enterText(find.byType(TextField).last, 'suitmedia');
    await tester.tap(find.text('CHECK'));
    await tester.pumpAndSettle();

    // Verify dialog shows 'not palindrome'
    expect(find.text('not palindrome'), findsOneWidget);
  });
}

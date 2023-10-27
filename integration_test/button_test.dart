import 'package:flutter/material.dart';
import 'package:flutter_app_playground/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'counter state is the same after going to Home and switching apps',
    nativeAutomation: true,
    nativeAutomatorConfig: NativeAutomatorConfig(
      packageName: 'com.example.flutter_app_playground',
      bundleId: 'com.example.flutter_app_playground',
    ),
    ($) async {
      print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
      print(' - Running Test....you should see the app....');
      print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
      //final WidgetTester tester = $.tester;
      await $.pumpWidgetAndSettle(const MyApp());
      var tester = $.tester;

      // // Like button
      final likeButton = $(#likeButton);
      expect(likeButton, findsOneWidget, reason: 'Like button should be found');
      // expect(likeButton.visible, equals(true), reason: 'Like button should be found');

      // Next Button
      final nextButton = $(#nextButton);
      expect(nextButton, findsOneWidget, reason: 'Next button should be found');
      // expect(nextButton.visible, equals(true), reason: 'Next button should be found');

      Text wordPairFront = tester.widget(find.byKey(Key('wordPairFront')));
      Text wordPairBack = tester.widget(find.byKey(Key('wordPairBack')));
      var firstWordPair = '${wordPairFront.data}${wordPairBack.data}';
      print('current word pair: $firstWordPair');

      // // Tap the next button
      await nextButton.tap();
      await $.tap(nextButton);
      await $.pump();

      // // Check the new word pair
      Text wordPairFront2 = tester.widget(find.byKey(Key('wordPairFront')));
      Text wordPairBack2 = tester.widget(find.byKey(Key('wordPairBack')));
      var secondWordPair = '${wordPairFront2.data}${wordPairBack2.data}';
      print('new word pair: $secondWordPair');

      // Assert the wordpair has changed after the next button press.
      expect(firstWordPair != secondWordPair, true);
    },
  );
}

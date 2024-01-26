// import 'package:flutter/material.dart';
import 'package:flutter_app_playground/main.dart';
import 'package:patrol/patrol.dart';
import 'support/utils/utils.dart';
import 'support/utils/auth.dart';

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
      await $('Open notifications screen').tap();

      if (await $.native.isPermissionDialogVisible()) {
        await $.native.grantPermissionWhenInUse();
      }

      await wait(delay: 15);
      await validateLoggedIn($);

    },
  );
}
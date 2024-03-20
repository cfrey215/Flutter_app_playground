# flutter_app_playground

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


# Run Test Suite on Browserstack

#### Build the Instrumented Application Under Test (AUT) APK

1. `./gradlew app:assembleStagingDebug` is used to build the instrumented app (AUT) APK.

- ./gradlew app:assembleDebug -Ptarget="/Users/christopher.frey/development/learning/flutter_app_playground/integration_test/button_test.dart"

2./ Upload the AUT to Browserstack:

    ```
    curl -u "<BS_USERNAME>:<BS_ACCESSKEY>" \
    -X POST "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/app" \
    -F "file=@/Users/christopher.frey//development/learning/flutter_app_playground/build/app/outputs/apk/debug/app-debug.apk" \
    -F "custom_id=GoDrive_Test_App"
    ```

3. AUT Browserstack App URL is returned
"app_url":"bs://3ee8adf5b8389fbc2b8bd7bca01a9bab2e1eadfc"

```
./gradlew assembleDebug assembleAndroidTest -DtestBuildType=debug
```

#### Build the Patrol Test Suite APK

1. `./gradlew app:assembleAndroidTest` is used to build the test APK that contains all of the UI tests.
2. Upload the Test Suite APK to Browserstack

    ```
    curl -u "<BS_USERNAME>:<BS_ACCESSKEY>" \
    -X POST "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/test-suite" \
    -F "file=@/Users/christopher.frey//development/learning/flutter_app_playground/build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk"
    ```

3. Test Suite Browserstack App URL is returned
"test_suite_url":"bs://36c13483c5307091f9d12845d49aca6404f9b997"

#### Run Browserstack Test suite

```
curl -u "<BS_USERNAME>:<BS_ACCESSKEY>" \
-X POST "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/build" \
-d '{
  "app": "bs://j3c874f21852ea50957a3fdc33f47514288c4ba4", \
  "testSuite": "bs://f7c874f21852ba57957a3fde31f47514288c4ba4", \
  "devices": ["Google Pixel 3 XL-9.0"], \
  "project": "GoDrive Patrol Android Integratation Tests",  \
  "video": "true", \
  "debug": "true", \
  "networkLogs": "true", \
  "deviceLogs": "true", \
  "video": "true", \
}' \
-H "Content-Type: application/json"
```

# Github -> slack usernames

Used for notifying the user who made a change when their build has failed
 
Steps:
1. Retrieve the Slack Member ID from the Workspace Directory in Slack. Note that the Member ID is workspace specific!

Here's an article on how this can be done.

https://medium.com/@moshfeu/how-to-find-my-member-id-in-slack-workspace-d4bba942e38c

2. Add the GITHUB ID and the Slack Member ID in the slack.json file in this repository in the format below:

{
    "github": "githubUserID",
    "slack": "slackMemberID"
}


###This is a TEST
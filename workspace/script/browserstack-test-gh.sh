#!/bin/bash -l




AUT_UPLOAD_URL="https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/app"
TEST_SUITE_UPLOAD_URL="https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/test-suite"
TEST_BUILD_URL="https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/build"
AUT_APP_PATH="@$GITHUB_WORKSPACE/workspace/build/app/outputs/apk/debug/app-debug.apk"
TEST_APP_PATH="@$GITHUB_WORKSPACE//workspace/build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk"
OUTPUT_FILENAMES=("$GITHUB_WORKSPACE/workspace/build/app/outputs/apk/debug/app-debug.apk" "$GITHUB_WORKSPACE/workspace/build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk")
TEST_REPORT_DIR="$GITHUB_WORKSPACE/workspace/integration_test/reports"
FILES_SUCCESSFULLY_CREATED=true
## Testing Locally
# AUT_APP_PATH="@/Users/christopher.frey/development/learning/flutter_app_playground/workspace/build/app/outputs/apk/debug/app-debug.apk"
# TEST_APP_PATH="@/Users/christopher.frey/development/learning/flutter_app_playground/workspace/build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk"


APP_URL=""
TEST_SUITE_URL=""
BS_PROJECT_NAME="flutter_app_playground-Patrol-2.2.5"
BS_LOCAL_TESTING="false"

echo
echo "==> -load-env: loading environment…"

BS_USERNAME=${1}
BS_ACCESS_TOKEN=${2}

echo "BS_USERNAME =====> ${BS_USERNAME}"
echo "BS_ACCESS_TOKEN =====> ${BS_ACCESS_TOKEN}"

# if [ -f .env ]; then
#     # Load .env vars
#     . .env

#     echo "BS_USERNAME =====> ${BS_USERNAME}"
#     echo "BS_ACCESS_TOKEN =====> ${BS_ACCESS_TOKEN}"
    
#     if [[ "${BS_USERNAME}" = "" || "${BS_ACCESS_TOKEN}" = "" ]]; then
#         echo
#         echo "    ERROR: Missing BS_USERNAME or BS_ACCESS_TOKEN, please supply these values in your .env file."
#         echo
#         exit 1;
#     fi
# else
#     echo
#     echo "    ERROR: Missing .env file."
#     echo
#     exit 1;
# fi


if [[ "${BS_USERNAME}" = "" || "${BS_ACCESS_TOKEN}" = "" ]]; then
    echo
    echo "    ERROR: Missing BS_USERNAME or BS_ACCESS_TOKEN, please supply these values in your .env file."
    echo
    exit 1;
fi

function testing() {
    echo "==> Testing..."
    echo
    echo "==> PATH => $PATH"
    echo
    echo
    cd "$GITHUB_WORKSPACE"/workspace || exit
    echo "==> Current Directory: $(pwd)"
    echo "List of files in the current directory: $(ls)"
    echo

    # echo "===> Checking for flutter and patrol versions..."
    # patrol --version
    # flutter --version
    # echo
    # echo
    # echo "===> Flutter doctor: $(flutter doctor)"
    # echo
    # echo "Build Apps..."
    # flutter build apk --debug --verbose
    # patrol build android \
    #     --target integration_test/button_test.dart \
    #     --debug --verbose
    # echo "Run flutter pub get: $(flutter pub get)"
}

# Build Apps
function build_apps() {
    # cd "$GITHUB_WORKSPACE"/workspace || exit
    cd app/workspace || exit

    patrol build android \
        --target integration_test/button_test.dart \
        --debug --verbose

    # Check for the output files to be available
    for filename in "${OUTPUT_FILENAMES[@]}"; do
        if [ -f "$filename" ]; then
            echo "$filename successfully created."
        else
            echo "$filename failed to be created."
            FILES_SUCCESSFULLY_CREATED=false
            exit 0;
        fi
    done

    echo "==> Finished building AUT and Test Apps…"
    exit 1;
}

function check_build_apps() { 
    # Check for the output files to be available
    for filename in "${OUTPUT_FILENAMES[@]}"; do
        if [ -f "$filename" ]; then
            echo "$filename successfully created."
        else
            echo "$filename failed to be created."
            FILES_SUCCESSFULLY_CREATED=false
        fi
    done
}

# Upload AUT App
function upload_aut_app() {
    BS_USERNAME=${1}
    BS_ACCESS_TOKEN=${2}

    if [ "$FILES_SUCCESSFULLY_CREATED" = true ]; then
        echo
        echo "==> Upload AUT app to Browserstack…"

        curl -u "${BS_USERNAME}:${BS_ACCESS_TOKEN}" \
        -s \
            -X POST "${AUT_UPLOAD_URL}" \
            -F "file=${AUT_APP_PATH}" \
            -F "custom_id=flutter_app_playground_Test_App" \
            --output curl.output \
            --write-out %{http_code} \
            > http.response.code 2> error.messages

            RESPONSE_CODE=$(cat http.response.code)
            RESPONSE=$(cat curl.output)

        echo "Upload AUT app to Browserstack cURL response code => $RESPONSE_CODE"
        echo "Upload AUT app to Browserstack cURL response => $RESPONSE"

        if [ "$RESPONSE_CODE" != "200" ]; then
            RESPONSE_ERROR=$(cat error.messsages)
            echo -e "Error making Upload AUT app to Browserstack request, http response code: $RESPONSE_CODE)"
            echo "Error message => $RESPONSE_ERROR"
            exit 1;
        else
            APP_URL=$(echo "$RESPONSE" | jq -r '.app_url')
            echo "APP_URL => $APP_URL"
            echo "BS_APP_URL=$APP_URL" >> "$GITHUB_OUTPUT"
        fi
    else
        echo
        echo "==> Skipping Upload AUT app to Browserstack, app files failed to generate properly."
        exit 1;
    fi

    exit 0;
}

# Upload Test App
function upload_test_app() {
    BS_USERNAME=${1}
    BS_ACCESS_TOKEN=${2}

    if [ "$FILES_SUCCESSFULLY_CREATED" = true ]; then
        echo
        echo "==> Upload Test app to Browserstack…"

        curl -u "${BS_USERNAME}:${BS_ACCESS_TOKEN}" \
            -X POST "${TEST_SUITE_UPLOAD_URL}" \
            -F "file=${TEST_APP_PATH}" \
            --output curl.output \
            --write-out %{http_code} \
            > http.response.code 2> error.messages

            RESPONSE_CODE=$(cat http.response.code)
            RESPONSE=$(cat curl.output)

        echo "Upload Test app to Browserstack cURL response code => $RESPONSE_CODE"
        echo "Upload Test app to Browserstack cURL response => $RESPONSE"

        if [ "$RESPONSE_CODE" != "200" ]; then
            RESPONSE_ERROR=$(cat error.messsages)
            echo -e "Error making Upload Test app to Browserstack request, http response code: $RESPONSE_CODE)"
            echo "Error message => $RESPONSE_ERROR"
            exit 1;
        else
            TEST_SUITE_URL=$(echo "$RESPONSE" | jq -r '.test_suite_url')
            echo "TEST_SUITE_URL => $TEST_SUITE_URL"
            echo "BS_TEST_SUITE_URL=$TEST_SUITE_URL" >> "$GITHUB_OUTPUT"
        fi
    else
        echo
        echo "==> Skipping Upload Test app to Browserstack, app files failed to generate properly."
        exit 1;
    fi

    exit 0;
}

# Execute test run
function execute_test_run() {
    BS_USERNAME=${1}
    BS_ACCESS_TOKEN=${2}
    APP_URL=${3}
    TEST_SUITE_URL=${4}
    BS_PROJECT_NAME=${5} || "flutter_app_playground-Patrol-2.2.5"
    BS_LOCAL_TESTING=${6} || false

    if [ "$FILES_SUCCESSFULLY_CREATED" = true ]; then
        echo
        echo "==> Execute Browserstack test run..."

        curl -u "${BS_USERNAME}:${BS_ACCESS_TOKEN}" \
            -X POST "${TEST_BUILD_URL}" \
            -d '{
            "app": "'"${APP_URL}"'",
            "testSuite": "'"${TEST_SUITE_URL}"'",
            "devices": ["Google Pixel 8-14.0"],
            "project": "'"${BS_PROJECT_NAME}"'",
            "video": "true",
            "debug": "true",
            "networkLogs": "true",
            "deviceLogs": "true",
            "video": "true",
            "autoGrantPermissions" : "true",
            "local": "'"${BS_LOCAL_TESTING}"'"
            }' \
            -H "Content-Type: application/json" \
            --output curl.output \
            --write-out %{http_code} \
            > http.response.code 2> error.messages

            RESPONSE_CODE=$(cat http.response.code)
            RESPONSE=$(cat curl.output)

        echo "Execute Browserstack test run response code => $RESPONSE_CODE"
        echo "Execute Browserstack test run cURL response => $RESPONSE"

        if [ "$RESPONSE_CODE" != "200" ]; then
            RESPONSE_ERROR=$(cat error.messsages)
            echo -e "Error making Execute Browserstack test run request, http response code: $RESPONSE_CODE)"
            echo "Error message => $RESPONSE_ERROR"
            BUILD_MESSAGE=Fail
            BUIILD_ID=9999
            echo "BROWSERSTACK_BUILD_MESSAGE=failed" >> "$GITHUB_OUTPUT"
            echo "BROWSERSTACK_BUILD_ID=0000000" >> "$GITHUB_OUTPUT"
            exit 1;
            # echo "##[set-output name=BROWSERSTACK_BUILD_MESSAGE]failed"
            # echo "##[set-output name=BROWSERSTACK_BUILD_ID]0000000"
            # echo "BROWSERSTACK_BUILD_ID=0000000" >> testScriptOutput.txt
        else
            BUILD_MESSAGE=$(echo "$RESPONSE" | jq -r '.message')
            BUILD_ID=$(echo "$RESPONSE" | jq -r '.build_id')
            echo "BROWSERSTACK_BUILD_ID=$BUILD_ID" >> "$GITHUB_OUTPUT"
            echo "BROWSERSTACK_BUILD_MESSAGE=$BUILD_MESSAGE" >> "$GITHUB_OUTPUT"
            
            # echo "##[set-output name=BROWSERSTACK_BUILD_MESSAGE]$BUILD_MESSAGE"
            # echo "##[set-output name=BROWSERSTACK_BUILD_ID]$BUIILD_ID"
            # echo "BROWSERSTACK_BUILD_ID=$BUILD_ID" >> testScriptOutput.txt
        fi
     else
        echo
        echo "==> Skipping Execute Browserstack test run step, app files failed to generate properly."
        echo "BROWSERSTACK_BUILD_MESSAGE=failed" >> "$GITHUB_OUTPUT"
        echo "BROWSERSTACK_BUILD_ID=0000000" >> "$GITHUB_OUTPUT"
        exit 1;
        # echo "##[set-output name=BROWSERSTACK_BUILD_MESSAGE]failed"
        # echo "##[set-output name=BROWSERSTACK_BUILD_ID]0000000"
        # echo "BROWSERSTACK_BUILD_ID=0000000" >> testScriptOutput.txt
    fi

    exit 0;
}

function check_build_status() {

    BS_USERNAME=${1}
    BS_ACCESS_TOKEN=${2}
    BUILD_ID=${3}
    BUILD_STATUS=''
    echo "BS_USERNAME =====> ${BS_USERNAME}"
    echo "BS_ACCESS_TOKEN =====> ${BS_ACCESS_TOKEN}"
    echo "BUILD_ID =====> ${BUILD_ID}"
    
    echo
    echo "==> Check Browserstack build status for Build ID ${BUILD_ID}…"
    while [ "$BUILD_STATUS" == "running" ] || [ "$BUILD_STATUS" == "" ]; do
        echo "Running check build status loop..."

        curl -u "${BS_USERNAME}:${BS_ACCESS_TOKEN}" \
            -v \
            -X GET "https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/builds/${BUILD_ID}" \
            --output curl.output \
            --write-out %{http_code} \
            > http.response.code 2> error.messages

        RESPONSE_CODE=$(cat http.response.code)
        RESPONSE=$(cat curl.output)
        BUILD_STATUS=$(echo "$RESPONSE" | jq -r '.status')
        DEVICE_SESSION_STATUS=$(echo "$RESPONSE" | jq -r '.devices[0].sessions[0].status')
        DEVICE_SESSION_ID=$(echo "$RESPONSE" | jq -r '.devices[0].sessions[0].id')
        DEVICE_SESSION_DEVICE_NAME=$(echo "$RESPONSE" | jq -r '.devices[0].device')

        echo "Check Browserstack build status response code => $RESPONSE_CODE"
        echo "Check Browserstack build status cURL response => $RESPONSE"

        if [ "${BUILD_STATUS}" != "running" ] && [ "${BUILD_STATUS}" != "" ] ; then
            echo " ==> BUILD_ID => $BUILD_ID"
            echo " ==> BUILD_STATUS => $BUILD_STATUS"
            echo " ==> DEVICE_SESSION_DEVICE_NAME => $DEVICE_SESSION_DEVICE_NAME"
            echo " ==> DEVICE_SESSION_STATUS => $DEVICE_SESSION_STATUS"
            echo " ==> DEVICE_SESSION_ID => $DEVICE_SESSION_ID"
        fi

        sleep 5
    done

    # shellcheck disable=SC2129
    echo "BUILD_ID=$BUILD_ID" >> "$GITHUB_OUTPUT"
    echo "BROWSERSTACK_BUILD_STATUS=$BUILD_STATUS" >> "$GITHUB_OUTPUT"
    echo "DEVICE_SESSION_DEVICE_NAME=$DEVICE_SESSION_DEVICE_NAME" >> "$GITHUB_OUTPUT"
    echo "DEVICE_SESSION_STATUS=$DEVICE_SESSION_STATUS" >> "$GITHUB_OUTPUT"
    echo "DEVICE_SESSION_ID=$DEVICE_SESSION_ID" >> "$GITHUB_OUTPUT"
}

function generate_test_run_report() {
    BS_USERNAME=${1}
    BS_ACCESS_TOKEN=${2}
    BUIILD_ID=${3}
    SESSION_ID=${4}
    echo "BS_USERNAME =====> ${BS_USERNAME}"
    echo "BS_ACCESS_TOKEN =====> ${BS_ACCESS_TOKEN}"
    echo "BUIILD_ID =====> ${BUIILD_ID}"
    echo "SESSION_ID =====> ${SESSION_ID}"

    # TEST_REPORT_DIR="workspace/integration_test/reports"
    echo "Report directory: $TEST_REPORT_DIR"

    if [ -d "$TEST_REPORT_DIR" ]; then
        echo "Directory exists."
        rm -rf "${TEST_REPORT_DIR:?}/"*
    else
        echo "Directory does not exist."
        mkdir "$TEST_REPORT_DIR"
    fi

    GENERATE_SESSION_TEST_REPORT_URL=https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/builds/$BUIILD_ID/sessions/$SESSION_ID/report

    curl -u "${BS_USERNAME}:${BS_ACCESS_TOKEN}" \
        -v \
        -X GET "$GENERATE_SESSION_TEST_REPORT_URL" \
        --output curl.output \
        --write-out %{http_code} \
        > http.response.code 2> error.messages

        RESPONSE_CODE=$(cat http.response.code)
        RESPONSE=$(cat curl.output)

    echo "Execute Browserstack test run response code => $RESPONSE_CODE"
    echo "Execute Browserstack test run cURL response => $RESPONSE"

    if [ "$RESPONSE_CODE" == "200" ]; then
        echo "Create test report..."
        echo "$RESPONSE" >> "$TEST_REPORT_DIR/session_test_report.xml"



    #     RESPONSE_ERROR=$(cat error.messsages)
    #     echo -e "Error making Execute Browserstack test run request, http response code: $RESPONSE_CODE)"
    #     echo "Error message => $RESPONSE_ERROR"
    #     BUILD_MESSAGE=Fail
    #     BUIILD_ID=9999
    #     # echo "BROWSERSTACK_BUILD_MESSAGE=failed" >> "$GITHUB_OUTPUT"
    #     # echo "BROWSERSTACK_BUILD_ID=0000000" >> "$GITHUB_OUTPUT"

    #     echo "##[set-output name=BROWSERSTACK_BUILD_MESSAGE]failed"
    #     echo "##[set-output name=BROWSERSTACK_BUILD_ID]0000000"

    #     echo "BROWSERSTACK_BUILD_ID=0000000" >> testScriptOutput.txt
    # else
    #     BUILD_MESSAGE=$(echo "$RESPONSE" | jq -r '.message')
    #     BUIILD_ID=$(echo "$RESPONSE" | jq -r '.build_id')
    #     echo "BUILD_MESSAGE => ${BUILD_MESSAGE} || BUIILD_ID => $BUIILD_ID"
        
    #     # echo "BROWSERSTACK_BUILD_MESSAGE=$BUILD_MESSAGE" >> "$GITHUB_OUTPUT"
    #     # echo "BROWSERSTACK_BUILD_ID=$BUIILD_ID" >> "$GITHUB_OUTPUT"
    #     echo "##[set-output name=BROWSERSTACK_BUILD_MESSAGE]$BUILD_MESSAGE"
    #     echo "##[set-output name=BROWSERSTACK_BUILD_ID]$BUIILD_ID"

    #     echo "BROWSERSTACK_BUILD_ID=$BUIILD_ID" >> testScriptOutput.txt
    fi
}

############## CLEAN OUTPUT FILES ##############
function cleanup_files() {
    if [ -f curl.output ]; then
        rm curl.output
    fi

    if [ -f error.messages ]; then
        rm error.messages
    fi

    if [ -f http.response.code ]; then
        rm http.response.code
    fi
}

"$@"

# testing
# # build_apps
# check_build_apps
# upload_aut_app
# upload_test_app
# execute_test_run
# cleanup_files

echo "Done!"
# echo "Hello $1"
# time=$(date)
# # echo "time=$time" >> $GITHUB_OUTPUT
# echo "##[set-output name=time]$time"
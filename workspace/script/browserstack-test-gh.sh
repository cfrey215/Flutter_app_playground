#!/bin/bash -l

AUT_UPLOAD_URL="https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/app"
TEST_SUITE_UPLOAD_URL="https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/test-suite"
BS_EXECUTE_BUILD_URL="https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/build"
GENERATE_SESSION_TEST_REPORT_URL=https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/builds/$BUIILD_ID/sessions/$SESSION_ID/report
BS_BUILD_STATUS_URL="https://api-cloud.browserstack.com/app-automate/flutter-integration-tests/v2/android/builds"
AUT_APP_PATH="@$GITHUB_WORKSPACE/workspace/build/app/outputs/apk/debug/app-debug.apk"
TEST_APP_PATH="@$GITHUB_WORKSPACE/workspace/build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk"
OUTPUT_FILENAMES=("/app/workspace/build/app/outputs/apk/debug/app-debug.apk" "/app/workspace/build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk")
TEST_REPORT_DIR="$GITHUB_WORKSPACE/workspace/integration_test/reports"
FILES_SUCCESSFULLY_CREATED=true
APP_URL=""
TEST_SUITE_URL=""
BS_PROJECT_NAME="flutter_app_playground-Patrol-2.2.5"
BS_LOCAL_TESTING="false"

function validate_credentials() {
    if [[ "${BS_USERNAME}" = "" || "${BS_ACCESS_TOKEN}" = "" ]]; then
        echo
        echo "    ERROR: Missing BS_USERNAME or BS_ACCESS_TOKEN, please supply these values in your .env file."
        echo
        exit 1;
    fi
}

# Build Apps
function build_apps() {
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
            exit 1;
        fi
    done

    echo "==> Finished building AUT and Test Apps…"
    exit 0;
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
    validate_credentials "${BS_USERNAME}" "${BS_ACCESS_TOKEN}"
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

        if [ "$RESPONSE_CODE" != "200" ]; then
            RESPONSE_ERROR=$(cat error.messsages)
            echo -e "Error making Upload AUT app to Browserstack request, http response code: $RESPONSE_CODE)"
            echo "Error message => $RESPONSE_ERROR"
            exit 1;
        else
            APP_URL=$(echo "$RESPONSE" | jq -r '.app_url')
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
    validate_credentials "${BS_USERNAME}" "${BS_ACCESS_TOKEN}"
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

        if [ "$RESPONSE_CODE" != "200" ]; then
            RESPONSE_ERROR=$(cat error.messsages)
            echo -e "Error making Upload Test app to Browserstack request, http response code: $RESPONSE_CODE)"
            echo "Error message => $RESPONSE_ERROR"
            exit 1;
        else
            TEST_SUITE_URL=$(echo "$RESPONSE" | jq -r '.test_suite_url')
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
    BS_PROJECT_NAME=${5}
    BS_LOCAL_TESTING=false # ${6}
    validate_credentials "${BS_USERNAME}" "${BS_ACCESS_TOKEN}"
    # Initialize the output
    # shellcheck disable=SC2129
    echo "BROWSERSTACK_BUILD_MESSAGE=failed" >> "$GITHUB_OUTPUT"
    echo "BROWSERSTACK_BUILD_ID=0000000" >> "$GITHUB_OUTPUT"
    echo "BROWSERSTACK_BUILD_URL=" >> "$GITHUB_OUTPUT"

    if [ "$FILES_SUCCESSFULLY_CREATED" = true ]; then
        echo
        echo "==> Execute Browserstack test run..."

        curl -u "${BS_USERNAME}:${BS_ACCESS_TOKEN}" \
            -X POST "${BS_EXECUTE_BUILD_URL}" \
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
            # shellcheck disable=SC2129
            echo "BROWSERSTACK_BUILD_MESSAGE=failed" >> "$GITHUB_OUTPUT"
            echo "BROWSERSTACK_BUILD_ID=0000000" >> "$GITHUB_OUTPUT"
            echo "BROWSERSTACK_BUILD_URL=" >> "$GITHUB_OUTPUT"
            exit 1;
        else
            BUILD_MESSAGE=$(echo "$RESPONSE" | jq -r '.message')
            BUILD_ID=$(echo "$RESPONSE" | jq -r '.build_id')
            # shellcheck disable=SC2129
            echo "BROWSERSTACK_BUILD_ID=$BUILD_ID" >> "$GITHUB_OUTPUT"
            echo "BROWSERSTACK_BUILD_MESSAGE=$BUILD_MESSAGE" >> "$GITHUB_OUTPUT"
            echo "BROWSERSTACK_BUILD_URL=https://app-automate.browserstack.com/dashboard/v2/builds/$BUILD_ID" >> "$GITHUB_OUTPUT"
        fi
     else
        echo
        echo "==> Skipping Execute Browserstack test run step, app files failed to generate properly."
        # shellcheck disable=SC2129
        echo "BROWSERSTACK_BUILD_MESSAGE=failed" >> "$GITHUB_OUTPUT"
        echo "BROWSERSTACK_BUILD_ID=0000000" >> "$GITHUB_OUTPUT"
        echo "BROWSERSTACK_BUILD_URL=" >> "$GITHUB_OUTPUT"
        exit 1;
    fi
    exit 0;
}

function check_build_status() {
    BS_USERNAME=${1}
    BS_ACCESS_TOKEN=${2}
    BUILD_ID=${3}
    TEST_RUN_TIMEOUT_MINUTES=${4} || 30
    STATUS_CHECK_INTERVAL_SECONDS=${5} || 10
    BUILD_STATUS=''
    
    echo
    echo "==> Check Browserstack build status for Build ID ${BUILD_ID}…"

    validate_credentials "${BS_USERNAME}" "${BS_ACCESS_TOKEN}"
    while [ "$BUILD_STATUS" == "running" ] || [ "$BUILD_STATUS" == "" ]; do
        echo "Running check build status loop..."

        curl -u "${BS_USERNAME}:${BS_ACCESS_TOKEN}" \
            -v \
            -X GET "${BS_BUILD_STATUS_URL}/${BUILD_ID}" \
            --output curl.output \
            --write-out %{http_code} \
            > http.response.code 2> error.messages

        
        RESPONSE_CODE=$(cat http.response.code)
        RESPONSE=$(cat curl.output)
        BUILD_STATUS=$(echo "$RESPONSE" | jq -r '.status')
        DEVICE_SESSION_STATUS=$(echo "$RESPONSE" | jq -r '.devices[0].sessions[0].status')
        DEVICE_SESSION_ID=$(echo "$RESPONSE" | jq -r '.devices[0].sessions[0].id')
        DEVICE_SESSION_DEVICE_NAME=$(echo "$RESPONSE" | jq -r '.devices[0].device')
        DEVICE_SESSION_DEVICE_OS=$(echo "$RESPONSE" | jq -r '.devices[0].os')
        DEVICE_SESSION_DEVICE_OS_VERSION=$(echo "$RESPONSE" | jq -r '.devices[0].os_version')
        if [ "${BUILD_STATUS}" != "running" ] && [ "${BUILD_STATUS}" != "" ] ; then
            BUILD_TESTS_CASES=$(echo "$RESPONSE" | jq -r '.devices[0].sessions[0].testcases.count')
            BUILD_TESTS_PASSED=$(echo "$RESPONSE" | jq -r '.devices[0].sessions[0].testcases.status.passed')
            BUILD_TESTS_FAILED=$(echo "$RESPONSE" | jq -r '.devices[0].sessions[0].testcases.status.failed')
            BUILD_TESTS_SKIPPED=$(echo "$RESPONSE" | jq -r '.devices[0].sessions[0].testcases.status.skipped')
            BUILD_TESTS_TIMEOUT=$(echo "$RESPONSE" | jq -r '.devices[0].sessions[0].testcases.status.timedout')
        fi

        sleep "${STATUS_CHECK_INTERVAL_SECONDS}"
        
        # Manage the timeout
        accrued_time=$((accrued_time + STATUS_CHECK_INTERVAL_SECONDS))
        if [ "$accrued_time" -ge "$((TEST_RUN_TIMEOUT_MINUTES * 60))" ]; then
            echo "Timeout reached, stopping the build status check loop."
            echo "BROWSERSTACK_BUILD_STATUS=timeout" >> "$GITHUB_OUTPUT"
            break
        fi
    done

    # shellcheck disable=SC2129
    echo "BROWSERSTACK_BUILD_ID=$BUILD_ID" >> "$GITHUB_OUTPUT"
    echo "BROWSERSTACK_BUILD_STATUS=$BUILD_STATUS" >> "$GITHUB_OUTPUT"
    echo "DEVICE_SESSION_DEVICE_NAME=$DEVICE_SESSION_DEVICE_NAME" >> "$GITHUB_OUTPUT"
    echo "DEVICE_SESSION_STATUS=$DEVICE_SESSION_STATUS" >> "$GITHUB_OUTPUT"
    echo "DEVICE_SESSION_ID=$DEVICE_SESSION_ID" >> "$GITHUB_OUTPUT"
    echo "DEVICE_SESSION_DEVICE_OS=$DEVICE_SESSION_DEVICE_OS" >> "$GITHUB_OUTPUT"
    echo "DEVICE_SESSION_DEVICE_OS_VERSION=$DEVICE_SESSION_DEVICE_OS_VERSION" >> "$GITHUB_OUTPUT"
    echo "BUILD_TESTS_CASES=$BUILD_TESTS_CASES" >> "$GITHUB_OUTPUT"
    echo "BUILD_TESTS_PASSED=$BUILD_TESTS_PASSED" >> "$GITHUB_OUTPUT"
    echo "BUILD_TESTS_FAILED=$BUILD_TESTS_FAILED" >> "$GITHUB_OUTPUT"
    echo "BUILD_TESTS_SKIPPED=$BUILD_TESTS_SKIPPED" >> "$GITHUB_OUTPUT"
    echo "BUILD_TESTS_TIMEOUT=$BUILD_TESTS_TIMEOUT" >> "$GITHUB_OUTPUT"
    echo "TEST_RUN_STATE=test_run_complete" >> "$GITHUB_ENV"
}

function generate_test_run_report() {
    BS_USERNAME=${1}
    BS_ACCESS_TOKEN=${2}
    BUIILD_ID=${3}
    SESSION_ID=${4}
    validate_credentials "${BS_USERNAME}" "${BS_ACCESS_TOKEN}"
    if [ -d "$TEST_REPORT_DIR" ]; then
        echo "Directory exists."
        rm -rf "${TEST_REPORT_DIR:?}/"*
    else
        echo "Directory does not exist."
        mkdir "$TEST_REPORT_DIR"
    fi
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

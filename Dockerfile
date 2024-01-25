FROM cfrey222/exploratory-things:parent as base

COPY entrypoint.sh /entrypoint.sh
COPY /workspace /app

ENV PATH=$PATH:/root/.pub-cache/bin \
    ANDROID_HOME=/Android \
    FLUTTER_HOME=/flutter \
    APP_PATH=/app

ARG APP_VERSION="1.0.0"

# RUN dart pub global activate patrol_cli 2.2.2 \
# && no "n" | patrol --version

######## Update local.properties ########
RUN touch $APP_PATH/android/local.properties \
&& echo "sdk.dir=$ANDROID_HOME/sdk\n" \
"flutter.sdk=$FLUTTER_HOME\n" \
"flutter.buildMode=debug\n" \
"flutter.versionName=$APP_VERSION\n" \
"flutter.targetSdkVersion=31\n" \
"flutter.compileSdkVersion=33\n" \
>> $APP_PATH/android/local.properties

######## Write gradle.properties file ########
RUN echo "ujetAwsAccessKeyValue= \n" \
"ujetAwsSecretKeyValue= " >> $APP_PATH/android/gradle.properties

# ######## Install gradle wrapper ########
RUN $APP_PATH/android/./gradlew -v

# WORKDIR /app

# Command to execute when the container starts
# ENTRYPOINT [ "/bin/bash", "-c", "exec /godrive/script/browserstack-test-gh.sh \"${@}\"", "--"]

FROM node:16.20 AS node_base

FROM ubuntu:20.04 as base_installation_android

# Install Node.js via copy from node_base image
COPY --from=node_base /usr/local/bin /usr/local/bin

ARG APP_VERSION="1.0.0"

ENV UID=1000 \
    GID=1000 \
    JAVA_VERSION="17" \
    FLUTTER_HOME="/flutter" \
    FLUTTER_CHANNEL="stable" \
    FLUTTER_VERSION="3.13.6" \
    FLUTTER_WEB_PORT="8090" \
    FLUTTER_DEBUG_PORT="42000" \
    FLUTTER_EMULATOR_NAME="flutter_emulator" \
    ANDROID_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-7302050_latest.zip" \
    ANDROID_VERSION="30" \
    ANDROID_BUILD_TOOLS_VERSION="30.0.0" \
    ANDROID_ARCHITECTURE="x86"
    

    # ANDROID_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip" \
    # ANDROID_VERSION="34" \
    # ANDROID_BUILD_TOOLS_VERSION="34.0.0" \
    # ANDROID_ARCHITECTURE="x86_64"
    
ENV ANDROID_HOME="/opt/android/sdk" \
    ANDROID_SDK="/opt/android/sdk" \
    COMMAND_LINE_HOME="/opt/android/sdk/cmdline-tools/latest" \
    SWIFTSHADER_HOME="/opt/swiftshader" \
    FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/$FLUTTER_CHANNEL/linux/flutter_linux_$FLUTTER_VERSION-$FLUTTER_CHANNEL.tar.xz"

ENV PATH="$COMMAND_LINE_HOME/bin:$ANDROID_SDK/emulator:$ANDROID_SDK/platform-tools:$ANDROID_SDK/platforms:$FLUTTER_HOME/bin:$PATH"

# install all dependencies
RUN apt-get update \
&& DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
  openjdk-$JAVA_VERSION-jdk \
  jq \
  curl \
  wget \
  unzip \
  sed \
  git \
  bash \
  xz-utils \
  libglvnd0 \
  ssh \
  xauth \
  x11-xserver-utils \
  libpulse0 \
  libxcomposite1 \
  libgl1-mesa-glx \
  sudo \
  x11vnc \
  xvfb \
  ffmpeg \
  qemu-kvm \
  libvirt-daemon-system \
  libvirt-clients \
  bridge-utils \
  virt-manager \
&& rm -rf /var/lib/{apt,dpkg,cache,log}

# Download and install HAXM
# RUN apt-get update && apt-get install -y \
#     intel-haxm \
#     && apt-get clean

# # Set environment variables (if needed)
# # ENV PATH="/path/to/haxm:${PATH}"

# Download and install SwiftShader
RUN wget https://swift.org/builds/swift-5.3-release/ubuntu2004/swift-5.3-RELEASE/swift-5.3-RELEASE-ubuntu20.04.tar.gz \
  && tar xzf swift-5.3-RELEASE-ubuntu20.04.tar.gz \
  && mv swift-5.3-RELEASE-ubuntu20.04 /usr/share/swift

ENV PATH=/usr/share/swift/usr/bin:$PATH

# Set environment variables for SwiftShader
ENV LD_LIBRARY_PATH=/opt/swiftshader/lib \
  LIBGL_ALWAYS_SOFTWARE=1

# Download the latest command line tools linux version
RUN curl -o sdk-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip \
  && unzip sdk-tools.zip \
  && rm sdk-tools.zip

# Create the destination directory for the cmdline-tools and move them there
RUN mkdir -p $COMMAND_LINE_HOME \
  && mkdir -p .android && touch .android/repositories.cfg \
  && mv ./cmdline-tools/bin $COMMAND_LINE_HOME \
  && mv ./cmdline-tools/lib $COMMAND_LINE_HOME

RUN cd $COMMAND_LINE_HOME/bin \
  && yes | ./sdkmanager --licenses \
  && cd $COMMAND_LINE_HOME/bin \
  && yes "y" | ./sdkmanager "build-tools;$ANDROID_BUILD_TOOLS_VERSION" \
  && yes "y" | ./sdkmanager "platforms;android-$ANDROID_VERSION" \
  && yes "y" | ./sdkmanager "platform-tools" \
  && yes "y" | ./sdkmanager "sources;android-$ANDROID_VERSION" \
  && yes "y" | ./sdkmanager "emulator" \
  && yes "y" | ./sdkmanager --licenses \
  && yes "y" | ./sdkmanager "system-images;android-$ANDROID_VERSION;google_apis_playstore;$ANDROID_ARCHITECTURE"

ENV PATH=$PATH:/root/.pub-cache/bin

FROM base_installation_android as base_installation_flutter

######## Install & Setup Flutter ########
ENV FLUTTER_HOME=/flutter \
    PATH=$PATH:/flutter/bin

RUN git config --global --add safe.directory /flutter

RUN curl -o flutter.tar.xz $FLUTTER_URL \
&& mkdir -p $FLUTTER_HOME \
&& tar xf flutter.tar.xz -C / \
&& rm flutter.tar.xz \
&& flutter config --no-analytics --enable-web  --android-sdk $ANDROID_SDK_ROOT/ \
&& flutter precache \
&& flutter doctor \
&& flutter emulators --create
# && flutter update-packages

# Run basic check to download Dart SDK
RUN flutter doctor

# Create and start Android emulator
RUN echo "no" | avdmanager create avd -n test -k "system-images;android-30;google_apis_playstore;x86" -d "Nexus 5X" && \
    echo "hw.keyboard=yes" >> ~/.android/avd/test.avd/config.ini && \
    echo "hw.gpu.enabled=yes" >> ~/.android/avd/test.avd/config.ini

# Expose ADB and ADB server ports
EXPOSE 5555
EXPOSE 5554

# Set up VNC for screen recording (if needed)
# You may need to install additional VNC server packages and configure them accordingly

# Set up entry point to start the emulator
# CMD ["emulator", "-avd", "test", "-no-window", "-no-audio", "-gpu", "swiftshader_indirect"]



# # Use Ubuntu 20 as the base image
# FROM ubuntu:20.04

# ENV ANDROID_HOME="/opt/android/sdk" \
#     ANDROID_SDK="/opt/android/sdk" \
#     COMMAND_LINE_HOME="/opt/android/sdk/cmdline-tools/latest" \
#     SWIFTSHADER_HOME="/opt/swiftshader"
#     # FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/$FLUTTER_CHANNEL/linux/flutter_linux_$FLUTTER_VERSION-$FLUTTER_CHANNEL.tar.xz"

# ENV PATH="$COMMAND_LINE_HOME/bin:$ANDROID_SDK/emulator:$ANDROID_SDK/platform-tools:$ANDROID_SDK/platforms:$FLUTTER_HOME/bin:$PATH"


# # Install necessary dependencies
# RUN apt-get update && \
#     apt-get install -y \
#     openjdk-11-jdk \
#     curl \
#     wget \
#     unzip \
#     libglu1 \
#     libpulse0 \
#     qemu-kvm \
#     mesa-utils \
#     libvirt-daemon-system \
#     libvirt-clients \
#     bridge-utils \
#     virtinst \
#     cpu-checker \
#     clang \
#     libpython2.7 \
#     libpython2.7-dev \
#     && rm -rf /var/lib/apt/lists/*

# # Download and install SwiftShader
# RUN wget https://swift.org/builds/swift-5.3-release/ubuntu2004/swift-5.3-RELEASE/swift-5.3-RELEASE-ubuntu20.04.tar.gz \
#   && tar xzf swift-5.3-RELEASE-ubuntu20.04.tar.gz \
#   && mv swift-5.3-RELEASE-ubuntu20.04 /usr/share/swift

# ENV PATH=/usr/share/swift/usr/bin:$PATH

# # Set environment variables for SwiftShader
# ENV LD_LIBRARY_PATH /opt/swiftshader/lib
# ENV LIBGL_ALWAYS_SOFTWARE 1

# # Download and install Android SDK
# # Download the latest command line tools linux version
# RUN curl -o sdk-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-7302050_latest.zip \
#   && unzip sdk-tools.zip \
#   && rm sdk-tools.zip

# # Create the destination directory for the cmdline-tools and move them there
# RUN mkdir -p $COMMAND_LINE_HOME \
#   && mkdir -p .android && touch .android/repositories.cfg \
#   && mv ./cmdline-tools/bin $COMMAND_LINE_HOME \
#   && mv ./cmdline-tools/lib $COMMAND_LINE_HOME

# RUN cd $COMMAND_LINE_HOME/bin \
#   && yes | ./sdkmanager --licenses \
#   && cd $COMMAND_LINE_HOME/bin \
#   && yes "y" | ./sdkmanager "platforms;android-30" \
#   && yes "y" | ./sdkmanager "platform-tools" \
#   && yes "y" | ./sdkmanager "sources;android-30" \
#   && yes "y" | ./sdkmanager "emulator" \
#   && yes "y" | ./sdkmanager --licenses \
#   && yes "y" | ./sdkmanager "system-images;android-30;google_apis_playstore;x86"


# # Create and start Android emulator
# RUN echo "no" | avdmanager create avd -n test -k "system-images;android-30;google_apis_playstore;x86" -d "Nexus 5X" && \
#     echo "hw.keyboard=yes" >> ~/.android/avd/test.avd/config.ini && \
#     echo "hw.gpu.enabled=yes" >> ~/.android/avd/test.avd/config.ini

# # Expose ADB and ADB server ports
# EXPOSE 5555
# EXPOSE 5554

# # Set up VNC for screen recording (if needed)
# # You may need to install additional VNC server packages and configure them accordingly

# # Set up entry point to start the emulator
# # CMD ["emulator", "-avd", "test", "-no-window", "-no-audio", "-gpu", "swiftshader_indirect"]

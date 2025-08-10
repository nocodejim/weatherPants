FROM ubuntu:22.04

LABEL maintainer="Audj <audjpodge@buckeye90.com>"
LABEL description="Android build environment for WeatherPants app"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-17-jdk \
    wget \
    unzip \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_COMMAND_LINE_TOOLS_VERSION=11076708
ENV ANDROID_BUILD_TOOLS_VERSION=34.0.0
ENV ANDROID_PLATFORM_VERSION=34

RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_COMMAND_LINE_TOOLS_VERSION}_latest.zip -O /tmp/cmdline-tools.zip && \
    unzip -q /tmp/cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip

ENV PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/build-tools/${ANDROID_BUILD_TOOLS_VERSION}:$PATH

RUN yes | sdkmanager --licenses > /dev/null || true && \
    sdkmanager "platforms;android-${ANDROID_PLATFORM_VERSION}" \
               "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
               "platform-tools"

WORKDIR /app

CMD ["/bin/bash"]

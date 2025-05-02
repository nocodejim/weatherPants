# Dockerfile for WeatherPants Android Build Environment

# Use a base image with Java Development Kit (JDK) pre-installed
# Choose a JDK version compatible with your Android Gradle Plugin (check AGP docs)
# Example: Ubuntu base with OpenJDK 17
FROM ubuntu:22.04

LABEL maintainer="Audj <audjpodge@buckeye90.com>"
LABEL description="Android build environment for WeatherPants app"

# Prevent prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies: Java, wget, unzip, git, etc.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-17-jdk \
    wget \
    unzip \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# --- Android SDK Setup ---
# Define Android SDK versions and paths
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_COMMAND_LINE_TOOLS_VERSION=13114758_latest  
ENV ANDROID_BUILD_TOOLS_VERSION=34.0.0 
ENV ANDROID_PLATFORM_VERSION=34 

# Download and install Android SDK command line tools
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_COMMAND_LINE_TOOLS_VERSION}.zip -O /tmp/cmdline-tools.zip && \
    unzip -q /tmp/cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip

# Set environment variables for Android SDK
ENV PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/build-tools/${ANDROID_BUILD_TOOLS_VERSION}:$PATH

# --- Explanation: sdkmanager ---
# 'sdkmanager' is the command-line tool for managing Android SDK components.
# We use it to install the specific platforms, build-tools, and platform-tools (like adb) needed.
# The 'yes |' part automatically accepts licenses.

# Install required SDK packages using sdkmanager
RUN yes | sdkmanager --licenses > /dev/null || true # Accept licenses
RUN sdkmanager "platforms;android-${ANDROID_PLATFORM_VERSION}" \
               "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
               "platform-tools" \
               # Add other components if needed, e.g., "emulator"
    && echo "SDK installation complete."

# --- Project Setup ---
# Set working directory
WORKDIR /app

# Copy Gradle wrapper files first to leverage Docker layer caching
COPY gradlew .
COPY gradle ./gradle

# Grant execution permission to gradlew script
RUN chmod +x ./gradlew

# --- Explanation: Dependency Caching ---
# Copying dependency files (build.gradle, settings.gradle) and downloading
# dependencies *before* copying the rest of the source code allows Docker
# to cache the dependencies layer. If only source code changes, Docker won't
# re-download dependencies, speeding up builds.
COPY build.gradle .
COPY settings.gradle .
COPY app/build.gradle ./app/
# Pre-download dependencies (optional, but good practice)
# This might fail if local.properties (with SDK path) isn't available yet
# Consider mounting local.properties during build or setting sdk.dir here
# RUN ./gradlew androidDependencies --stacktrace

# Copy the rest of the application code
COPY . .

# --- Explanation: Build Trigger ---
# This Dockerfile primarily sets up the *environment*.
# You would typically build the APK by running a command within a container
# started from this image (see INSTRUCTIONS.md).
# CMD ["./scripts/build_apk.sh"] # Optional: Define a default command

# Expose adb port if you intend to connect devices to the container (advanced)
# EXPOSE 5037

ENTRYPOINT [ "/bin/bash" ] # Keep container running for interactive use or commands
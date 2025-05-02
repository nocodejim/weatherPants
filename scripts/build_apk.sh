#!/bin/bash

# --- scripts/build_apk.sh ---
# Builds the WeatherPants Android application (Debug APK).

echo "Starting WeatherPants build process..."
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$( dirname "$SCRIPT_DIR" )" # Get the parent directory (project root)
LOG_FILE="${PROJECT_ROOT}/build_log_$(date +%Y%m%d_%H%M%S).log"

# Navigate to the project root directory
cd "$PROJECT_ROOT" || exit 1

echo "Project Root: $(pwd)" | tee -a "$LOG_FILE"

# --- Explanation: Gradle Wrapper (gradlew) ---
# The Gradle Wrapper (`gradlew` for Linux/macOS, `gradlew.bat` for Windows) is the
# standard way to execute Gradle tasks for an Android project.
# It ensures that everyone working on the project uses the *exact same* version
# of Gradle, defined in `gradle/wrapper/gradle-wrapper.properties`.
# This provides build consistency across different machines and environments.
# If Gradle isn't installed locally, the wrapper downloads it automatically the first time.
# We MUST make it executable (`chmod +x gradlew`).

GRADLEW_CMD="./gradlew"

# Check if gradlew exists and is executable
if [ ! -f "$GRADLEW_CMD" ]; then
    echo "ERROR: Gradle wrapper (gradlew) not found in project root." | tee -a "$LOG_FILE"
    exit 1
fi
if [ ! -x "$GRADLEW_CMD" ]; then
    echo "INFO: Making gradlew executable..." | tee -a "$LOG_FILE"
    chmod +x "$GRADLEW_CMD"
fi

# --- Explanation: Gradle Tasks ---
# Gradle organizes build logic into 'tasks'. Common Android tasks include:
# - `clean`: Deletes build outputs.
# - `assembleDebug`: Builds a debuggable version of your app (APK). This is unsigned
#   or signed with a default debug key, suitable for testing and development.
# - `assembleRelease`: Builds a release version (APK or AAB), typically minified,
#   optimized, and requires proper signing with your release key for distribution
#   (e.g., on Google Play Store).
# - `installDebug`: Builds and installs the debug APK onto a connected device/emulator.
# - `test`: Runs unit tests.
# - `connectedAndroidTest`: Runs instrumentation tests on a connected device/emulator.

echo "Running Gradle clean..." | tee -a "$LOG_FILE"
"$GRADLEW_CMD" clean | tee -a "$LOG_FILE"
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "ERROR: Gradle clean failed." | tee -a "$LOG_FILE"
    exit 1
fi

echo "Running Gradle assembleDebug..." | tee -a "$LOG_FILE"
# Run the build command and redirect stdout/stderr to log file AND console
"$GRADLEW_CMD" assembleDebug --stacktrace | tee -a "$LOG_FILE"

# Check the exit status of the Gradle command (PIPESTATUS[0] needed because of tee)
BUILD_STATUS=${PIPESTATUS[0]}

if [ $BUILD_STATUS -eq 0 ]; then
    echo "--------------------------------------" | tee -a "$LOG_FILE"
    echo "BUILD SUCCESSFUL!" | tee -a "$LOG_FILE"
    echo "Debug APK generated at:" | tee -a "$LOG_FILE"
    # Default location for debug APK
    APK_PATH="app/build/outputs/apk/debug/app-debug.apk"
    echo "$(pwd)/$APK_PATH" | tee -a "$LOG_FILE"
    echo "Build log saved to: $LOG_FILE" | tee -a "$LOG_FILE"
    echo "--------------------------------------"
    exit 0
else
    echo "--------------------------------------" | tee -a "$LOG_FILE"
    echo "BUILD FAILED!" | tee -a "$LOG_FILE"
    echo "Check the output above and the log file for errors: $LOG_FILE" | tee -a "$LOG_FILE"
    echo "--------------------------------------"
    exit 1
fi
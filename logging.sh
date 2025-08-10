#!/bin/bash

echo "Starting adb logcat for 5 seconds... Ensure your Android device or emulator is connected."

# Start logcat in the background, filtering for WeatherPantsLog and other default tags for context
# Using -T 1 to get recent logs as well, and -s to set default tag to silent for other tags.
adb logcat -T 1 WeatherPantsLog:D *:S > output.txt &

# Get the process ID of the logcat command
LOGCAT_PID=$!

# Wait for 5 seconds
sleep 5

# Stop the logcat process
kill $LOGCAT_PID

echo "Logcat captured to output.txt for WeatherPantsLog tag."
echo "Please run your app to trigger the error while this script is running, or just before."
echo "Then, check output.txt for the 'Requesting URL:' message."
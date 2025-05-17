# WeatherPants Android App - Instructions

This document provides detailed instructions on how to set up, build, run, and understand the WeatherPants Android application. It's designed with novice developers in mind, explaining key concepts along the way.

**Target Environment:** VSCode, WSL (Ubuntu 24.04)

## Table of Contents

1. [Project Overview](#project-overview)
2. [Prerequisites](#prerequisites)
3. [Setup](#setup)
4. [Development Environment](#development-environment)
5. [Building the Application (APK)](#building-the-application-apk)
6. [Running the Application (Sideloading)](#running-the-application-sideloading)
7. [Project Structure Explained](#project-structure-explained)
8. [Code Overview](#code-overview)
9. [Key Concepts Explained](#key-concepts-explained)
10. [GitHub & DevOps Best Practices](#github--devops-best-practices)
11. [Troubleshooting](#troubleshooting)

## 1. Project Overview

WeatherPants is a simple Android application that fetches the current temperature for a predefined location (Lebanon, OH) using the OpenWeatherMap API and advises the user whether they should wear pants based on a temperature threshold (currently < 60°F).

## 2. Prerequisites

* **Git:** For version control. Install on Ubuntu: `sudo apt update && sudo apt install git`
* **Bash:** Standard on WSL/Ubuntu
* **Java Development Kit (JDK):** Required by Android SDK/Gradle. Version 17 is recommended
* **Docker (Optional but Recommended):** For using the containerized build environment
* **OpenWeatherMap API Key:** A free API key is required to fetch weather data
* **Android Device or Chromebook (Optional):** For running the app

## 3. Setup

### Cloning the Repository

```bash
git clone <repository-url>
cd <repository-directory>
```

### Running the Setup Script

```bash
chmod +x setup.sh
./setup.sh
```

### API Key Configuration

1. Locate the `local.properties` file in the root directory
2. Add your API Key:

```properties
# ... other properties ...
WEATHER_API_KEY="YOUR_ACTUAL_SECRET_API_KEY_FROM_OPENWEATHERMAP"
```

## 4. Development Environment

### Option A: Using Docker (Recommended for Consistency)

1. Build the Docker image:
```bash
docker build -t weatherpants-dev-env .
```

### Option B: Local Setup (Manual Android SDK Installation)

1. Install Android Studio
2. Install SDK Components:
   * SDK Platform (Android 14 - API Level 34)
   * Android SDK Build-Tools
   * Android SDK Command-line Tools
   * Android SDK Platform-Tools

## 5. Building the Application (APK)

### Building with Docker

```bash
docker run --rm -v "$(pwd):/app" -w /app weatherpants-dev-env ./scripts/build_apk.sh
```

### Building Locally

```bash
./scripts/build_apk.sh
```

## 6. Running the Application (Sideloading)

### Prerequisites for Sideloading

1. Install ADB
2. Enable Developer Options & USB Debugging on your device:
   * Settings → About phone
   * Tap Build number seven times
   * Enable USB debugging in Developer options

### Installing the App

```bash
adb devices  # Verify connection
adb install app/build/outputs/apk/debug/app-debug.apk
```

## 7. Project Structure Explained

```
.
├── app/                      # Main application module
│   ├── build/               # Build output
│   ├── build.gradle         # App-specific build configuration
│   ├── proguard-rules.pro   # Code shrinking rules
│   └── src/                 # Source code and resources
├── gradle/                   # Gradle wrapper files
├── scripts/                  # Utility scripts
├── .gitignore               # Git ignore rules
├── build.gradle             # Top-level build configuration
├── Dockerfile               # Docker build environment
└── local.properties         # Local config (SDK path, API Key)
```

## 8. Code Overview

### MainActivity.kt

Main screen of the app, handles:
* UI initialization
* Weather API calls
* Temperature processing
* Pants recommendation logic

### activity_main.xml

Defines the UI layout with:
* Temperature display
* Loading indicator
* Recommendation text

### AndroidManifest.xml

Declares:
* App permissions (Internet)
* Activities
* App metadata

## 9. Key Concepts Explained

### Android SDK
Collection of tools for Android development including libraries, build tools, and platform tools.

### Gradle and Gradle Wrapper
Build automation tool used to manage dependencies, compile code, and build APKs. The wrapper ensures consistent builds across different environments.

### APK
Android Package file format used for distributing and installing Android apps.

### View Binding
Feature that provides type-safe access to UI elements, replacing findViewById().

## 10. GitHub & DevOps Best Practices

### Branching Strategy
* Use feature branches
* No direct commits to main
* Pull requests for code review

### Commit Messages
Follow Conventional Commits:
* feat: New feature
* fix: Bug fix
* docs: Documentation changes

### Handling Secrets
* Never commit API keys
* Use local.properties for development
* Use secure environment variables for CI/CD

## 11. Troubleshooting

Common issues and solutions:

### Build Issues
* Missing API Key: Check local.properties
* SDK Location: Verify ANDROID_SDK_ROOT
* Gradle Sync: Try ./gradlew clean

### Runtime Issues
* Internet Permission: Check AndroidManifest.xml
* Network Security: Verify HTTPS usage
* ADB: Ensure platform-tools is in PATH

### API Issues
* Verify API key is active
* Check internet connectivity
* Monitor Logcat for detailed errors
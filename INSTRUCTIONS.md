# WeatherPants Android App - Instructions

This document provides detailed instructions on how to set up, build, run, and understand the WeatherPants Android application. It's designed with novice developers in mind, explaining key concepts along the way.

**Target Environment:** VSCode, WSL (Ubuntu 24.04)

## Table of Contents

1.  [Project Overview](#project-overview)
2.  [Prerequisites](#prerequisites)
3.  [Setup](#setup)
    * [Cloning the Repository](#cloning-the-repository)
    * [Running the Setup Script](#running-the-setup-script)
    * [API Key Configuration](#api-key-configuration)
4.  [Development Environment](#development-environment)
    * [Option A: Using Docker (Recommended for Consistency)](#option-a-using-docker-recommended-for-consistency)
    * [Option B: Local Setup (Manual Android SDK Installation)](#option-b-local-setup-manual-android-sdk-installation)
5.  [Building the Application (APK)](#building-the-application-apk)
    * [Building with Docker](#building-with-docker)
    * [Building Locally](#building-locally)
6.  [Running the Application (Sideloading)](#running-the-application-sideloading)
    * [Prerequisites for Sideloading](#prerequisites-for-sideloading)
    * [Sideloading on an Android Device (Android 15 Example)](#sideloading-on-an-android-device-android-15-example)
    * [Sideloading on a Chromebook](#sideloading-on-a-chromebook)
7.  [Project Structure Explained](#project-structure-explained)
8.  [Code Overview](#code-overview)
    * [MainActivity.kt](#mainactivitykt)
    * [activity_main.xml](#activity_mainxml)
    * [AndroidManifest.xml](#androidmanifestxml)
    * [build.gradle (app & project)](#buildgradle-app--project)
9.  [Key Concepts Explained](#key-concepts-explained)
    * [What is Android SDK?](#what-is-android-sdk)
    * [What is Gradle and the Gradle Wrapper?](#what-is-gradle-and-the-gradle-wrapper)
    * [What is an APK?](#what-is-an-apk)
    * [What is Sideloading?](#what-is-sideloading)
    * [What is ADB?](#what-is-adb)
    * [What is View Binding?](#what-is-view-binding)
    * [Why `.gitignore`?](#why-gitignore)
    * [Why `local.properties` for API Keys?](#why-localproperties-for-api-keys)
10. [GitHub & DevOps Best Practices](#github--devops-best-practices)
    * [Branching Strategy](#branching-strategy)
    * [Commit Messages](#commit-messages)
    * [Pull Requests (PRs)](#pull-requests-prs)
    * [Handling Secrets](#handling-secrets)
    * [Dependencies & Security (Dependabot)](#dependencies--security-dependabot)
    * [Testing (Briefly)](#testing-briefly)
    * [Logging](#logging)
11. [Troubleshooting](#troubleshooting)

---

## 1. Project Overview

WeatherPants is a simple Android application that fetches the current temperature for a predefined location (Lebanon, OH) using the OpenWeatherMap API and advises the user whether they should wear pants based on a temperature threshold (currently < 60°F).

---

## 2. Prerequisites

* **Git:** For version control. Install on Ubuntu: `sudo apt update && sudo apt install git`
* **Bash:** Standard on WSL/Ubuntu.
* **Java Development Kit (JDK):** Required by Android SDK/Gradle. Version 17 is recommended. (Installed automatically if using Docker). Install on Ubuntu: `sudo apt install openjdk-17-jdk`
* **Docker (Optional but Recommended):** For using the containerized build environment. [Install Docker on Ubuntu](https://docs.docker.com/engine/install/ubuntu/). Ensure the Docker daemon is running.
* **OpenWeatherMap API Key:** A free API key is required to fetch weather data.
    * Go to [https://openweathermap.org/appid](https://openweathermap.org/appid)
    * Sign up for a free account.
    * Generate an API key. It might take a few minutes to become active.
* **Android Device or Chromebook (Optional):** For running the app.

---

## 3. Setup

### Cloning the Repository

If you haven't already, clone the repository to your local machine (within your WSL environment):

```bash
git clone <repository-url> # Replace <repository-url> with the actual URL
cd <repository-directory> # Navigate into the cloned project folder
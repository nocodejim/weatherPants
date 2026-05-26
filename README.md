# WeatherPants Android App

WeatherPants is an Android application that helps you decide whether you should wear pants or shorts today based on the current weather. It features:
1. **Phone App (`:app`)** — Displays local weather and recommendations with warm/cool gradient styling.
2. **Android Auto App (`:automotive`)** — Provides a driver-glanceable view of weather recommendations compliant with driver-distraction templates.
3. **Core Library (`:core`)** — Shares data models, pure business logic, and API networking logic between both interfaces.

---

## Configuration

1. Obtain a free API key from [OpenWeatherMap](https://openweathermap.org/).
2. Create/edit `local.properties` in the root of the project:
   ```properties
   WEATHER_API_KEY="YOUR_ACTUAL_API_KEY_HERE"
   ```

---

## How to Build (Primary Containerized Path)

We compile Gradle inside a container to guarantee build environment consistency.

### 1. Build the Development Environment Container
```bash
docker build -t weatherpants-dev-env .
```

### 2. Build the Debug APK
```bash
docker run --rm -v "$(pwd):/app" -w /app weatherpants-dev-env ./gradlew assembleDebug
```
The compiled APK will be located at:
`app/build/outputs/apk/debug/app-debug.apk`

---

## Alternative Local Build Path

If you have Java JDK 17 and Android SDK platforms installed locally, run:
```bash
./gradlew assembleDebug
```

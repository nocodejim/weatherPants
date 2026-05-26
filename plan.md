# Goal
Take the existing WeatherPants Android app from its current "works but messy" state to a clean, modular, tested baseline, then extend it to run on Android Auto via the Car App Library.

The end deliverable is two surfaces sharing one core:
1. **Phone app** — refined version of today's WeatherPants (Lebanon, OH temp → pants/no-pants).
2. **Android Auto app** — same logic, presented through Car App Library templates, compliant with driver-distraction rules.

# Operating Principles
- Plan before code. Produce a phased plan first; do not start editing files until the plan is confirmed.
- Small, reviewable steps. Each phase ends with a buildable, runnable APK.
- Preserve git history. No mass-overwrite scripts. Use targeted edits.
- Every change has a why. If a "best practice" doesn't earn its keep for this app's size, skip it and say so.
- Ask before assuming on ambiguous calls (location strategy, units, Material 2 vs 3, etc.). Don't ask three questions when one will do.

# Phase 1 — Repository Cleanup (no behavior change)
Audit and remove:
- All root-level `fix_*.sh`, `weatherpants-*.sh`, `complete_project_analysis.sh`, `add_weather.sh`, `docker_*.sh`, `weatherpants-minimal-test.sh`, `weatherpants-diagnostic.sh` scripts. They contradict the current source.
- Committed `build_log_*.log` files.
- Tighten `.gitignore`: drop `*.png` and `output.txt` rules (PNGs are legit Android resources). Keep `*.log`, build dirs, `local.properties`, `*.keystore`.
Fix in place:
- Move the debug keystore password out of `app/build.gradle`. Either: (a) use the default debug keystore Android provides, or (b) read release signing config from environment variables / `~/.gradle/gradle.properties` and skip release signing for debug.
- Reconcile location: README, code coordinates, and displayed string all say "Lebanon, OH" — fix the `locationTextView` hardcoded "Cincinnati, OH" and the `location_cincinnati` string key.
- Delete unused drawables (`ic_pants_emoji.xml`, `ic_loading_weather.xml` if unused, etc. — audit before deleting).
- Add a real `README.md` that describes the project as it actually is, with a single "how to build" path (Docker or local — pick one as primary).
End-of-phase check: `./gradlew assembleDebug` succeeds, APK installs and runs identically to today.

# Phase 2 — Architecture refactor (still phone-only)
- Introduce a `:core` Gradle module containing:
  - `WeatherRepository` (interface + OpenWeatherMap implementation)
  - `PantsDecider` (pure function: `Temperature → PantsAdvice`)
  - Data models (`Weather`, `Location`, `PantsAdvice`)
  - Threshold and units as injectable config, not hardcoded constants
- Replace Volley with OkHttp + kotlinx.serialization (or Retrofit if you prefer convention). Use Kotlin coroutines.
- Introduce a `WeatherViewModel` in `:app` that survives rotation and exposes a `StateFlow<UiState>`.
- Convert `MainActivity` to observe the ViewModel. Keep ViewBinding and the existing XML layout for now.
- Add `runtime-ktx`, `lifecycle-viewmodel-ktx`, `lifecycle-runtime-ktx`.
- Cancel/track animations properly in lifecycle callbacks, OR remove the showier animations entirely — discuss tradeoff.
- Decide location strategy: keep hardcoded Lebanon, OH for now, OR add `FusedLocationProviderClient` with a fallback. Recommend the latter for Android Auto readiness but confirm before adding the permission.
- Migrate theme to Material 3 (`Theme.Material3.DayNight.NoActionBar`). Audit color usage.

# Phase 3 — Tests
- Unit tests in `:core` for `PantsDecider` (boundary at 60°F, units conversion) and `WeatherRepository` (with a fake `OkHttpClient`/MockWebServer).
- One instrumentation test in `:app` verifying the ViewModel emits a `Ready` state given a fake repository.
- Wire the existing CI workflow so `./gradlew test` actually exercises tests.

# Phase 4 — Android Auto module
- Add `:automotive` module using `androidx.car.app:app:<latest>`.
- Declare `CarAppService` with the `androidx.car.app.category.WEATHER` category in its manifest.
- Implement a `Session` returning a single `Screen` that builds a `PaneTemplate`:
  - Pane row 1: current temperature + condition.
  - Pane row 2: pants verdict (large, single short string — driver-glanceable).
  - Action: "Refresh" button.
- Pull data through the shared `:core` `WeatherRepository`. No duplicated networking.
- Respect Car App constraints: no animations, content limits per template (e.g., GridTemplate ≤ 6 items), text length caps.
- Use a single location source for both surfaces. On Auto, location should come from the car if available, falling back to last known phone location.
- Provide a DHU (Desktop Head Unit) test plan: how to run, what to verify.

# Phase 5 — Distribution prep (informational, not necessarily executed)
- Document what's needed to actually ship to Android Auto: signed release build, Play Console listing, Car App Library declared use, weather-category review by Google. Make clear this step is gated and can take weeks.

# Constraints to honor throughout
- compileSdk and targetSdk stay at 34 unless there's a concrete reason to bump.
- minSdk 24 is fine; don't raise it without cause.
- No new third-party UI libraries unless they replace something heavier.
- Keep the OpenWeatherMap free-tier endpoint (current-weather, by lat/lon) unless we hit a hard wall.

# What I want from you first (before any code)
1. A one-screen summary of which Phase 1 items you'll do automatically vs. which need my call (e.g., "delete `ic_pants_emoji.xml`? — y/n").
2. A confirmation of the location strategy choice for Phase 2 (hardcoded vs. Fused).
3. A recommendation on Material 2 → 3 migration timing (Phase 1 cleanup, or defer to Phase 2).
4. A clear callout of any assumption in this brief you think is wrong.

Don't touch any files until I respond.
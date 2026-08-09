# Bug / Error Log

> Append a new entry per bug using the template below. Do not delete resolved entries — mark them Resolved and keep for reference.

---

## Entry Template

### # Bug/Error Description
[One-sentence summary of the issue]

**Status:** Open / In Progress / Resolved
**Date Logged:**
**Phase:** [which implementation phase this occurred in]
**Platform:** Mobile / Web / Both

**-- What Happened**
[Describe the steps that led to the error — what action was taken, what was expected, what occurred instead]

**-- Error in Console**
```
[Paste the exact console/log/stack trace output here]
```

**-- Files Involved**
- `[file path 1]`
- `[file path 2]`

**-- Root Cause** *(fill in once identified)*
[Explanation of why this happened]

**-- Fix Applied** *(fill in once resolved)*
[What was changed to resolve it]

---

## Log
(Append entries below this line, most recent first.)

---

### #3 Kotlin incremental-cache error broke Android debug build

**Status:** Resolved
**Date Logged:** 2026-08-09
**Phase:** Phase 1 — Project Initialization
**Platform:** Mobile

**-- What Happened**
`flutter build apk --debug` failed during Kotlin compilation of plugin modules (`url_launcher_android`, `shared_preferences_android` — transitive deps pulled in by `supabase_flutter`). Gradle reports it could not close incremental caches and that storage files were "already registered". App code itself compiled fine; the failure is in stale build cache state for the newly added plugins.

**-- Error in Console**
```
> java.lang.Exception: Could not close incremental caches in
  F:\Internship Projects\Project 2\hotelms\build\url_launcher_android\kotlin\compileDebugKotlin\...
  Suppressed: java.lang.IllegalStateException: Storage for [...class-fq-name-to-source.tab] is already registered
  Suppressed: java.lang.IllegalArgumentException: this and base files have different roots:
    C:\Users\Onetatmen\AppData\Local\Pub\Cache\hosted\pub.dev\url_launcher_android-6.3.32\...
    and F:\Internship Projects\Project 2\hotelms\android.
FAILURE: Build completed with 2 failures.
BUILD FAILED
```

**-- Files Involved**
- `build/` (generated Gradle caches; no source files)
- `android/gradle.properties` (fix)

**-- Root Cause**
The project is on drive **F:** while the pub cache (Flutter plugin sources) is on drive **C:**. Kotlin's incremental compiler (`RelocatableFileToPathConverter`) computes relative paths between source files and the project root and throws `IllegalArgumentException: this and base files have different roots` when the roots differ — a known Kotlin/Gradle bug. `flutter clean` and daemon restarts did NOT fix it because the failure is deterministic on every incremental compile of plugin modules.

**-- Fix Applied**
Added `kotlin.incremental=false` to `android/gradle.properties` (documented workaround for this exact error), which disables Kotlin incremental compilation for the Android build. `flutter build apk --debug` then succeeded (`build\app\outputs\flutter-apk\app-debug.apk`). Cost: slightly slower Kotlin rebuilds. Flagged to project owner as a build-config workaround, not a plan deviation.

---

### #1 Chrome executable not found — `flutter run -d chrome` cannot launch

**Status:** Resolved
**Date Logged:** 2026-08-09
**Phase:** Phase 1 — Project Initialization
**Platform:** Web

**-- What Happened**
Attempted to verify the acceptance criterion "flutter run -d chrome launches the app without errors" from `task_today.md`. `flutter devices` and `flutter doctor -v` show no Chrome device — Chrome is not installed on this machine (only Microsoft Edge, which is Chromium-based). The web target was instead verified launching successfully with `flutter run -d edge`.

**-- Error in Console**
```
[X] Chrome - develop for the web (Cannot find Chrome executable at .\Google\Chrome\Application\chrome.exe)
    ! Cannot find Chrome. Try setting CHROME_EXECUTABLE to a Chrome executable.
```

**-- Files Involved**
- None (environment issue, not a code issue)

**-- Root Cause**
Chrome browser is not installed on the development machine; `flutter run -d chrome` requires the Chrome executable (default install paths, or the `CHROME_EXECUTABLE` environment variable).

**-- Fix Applied**
Set user environment variable `CHROME_EXECUTABLE` to `C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe` (Edge is Chromium-based and fully supported by Flutter as the Chrome device). `flutter run -d chrome` then launched the app successfully (debug service connected, no errors). Note: existing open shells still need the variable set for this session (`$env:CHROME_EXECUTABLE=...`) since they inherited the old environment; new shells pick it up automatically. Reversible via `setx CHROME_EXECUTABLE ""`.

---

### #2 Malformed NDK download blocked Android debug build

**Status:** Resolved
**Date Logged:** 2026-08-09
**Phase:** Phase 1 — Project Initialization
**Platform:** Mobile

**-- What Happened**
The first `flutter build apk --debug` run was interrupted during the NDK download, leaving `android\sdk\ndk\28.2.13676358` with only a `.installer` marker. The retry failed with a CXX1101 error. Deleted the partial NDK folder; Gradle re-downloaded it and the build then succeeded.

**-- Error in Console**
```
> [CXX1101] NDK at C:\Users\Onetatmen\AppData\Local\Android\sdk\ndk\28.2.13676358 did not have a source.properties file
BUILD FAILED in 16s
[!] This is likely due to a malformed download of the NDK.
    This can be fixed by deleting the local NDK copy at:
    C:\Users\Onetatmen\AppData\Local\Android\sdk\ndk\28.2.13676358
```

**-- Files Involved**
- `android/app/build.gradle.kts` (config only — `ndkVersion = flutter.ndkVersion`)

**-- Root Cause**
Interrupted NDK install left a partial directory (only a `.installer` marker, no `source.properties`), caused by the earlier build run being killed mid-download.

**-- Fix Applied**
Deleted `C:\Users\Onetatmen\AppData\Local\Android\sdk\ndk\28.2.13676358`; Android Gradle Plugin re-downloaded NDK 28.2.13676358 (plus SDK Platform 36 and CMake 3.22.1); `flutter build apk --debug` then succeeded (`build\app\outputs\flutter-apk\app-debug.apk`).

# predictive_back_demo

Minimal reproduction for a Flutter framework bug: **the predictive back page
transition animates toward the wrong side** after popping a route that the
route below can't transition to (`canTransitionTo == false`, e.g. a
`fullscreenDialog`, or routes from routing packages such as GetX).

Tracking issue: `[FLUTTER ISSUE URL]`

## Requirements

- A device that delivers progressive back events to apps: e.g. a **Pixel on
  Android 14+** with **gesture navigation** enabled. (On Android 14, enable the
  "Predictive back animations" developer option if nothing animates.)
- OEM systems that don't dispatch progressive back events (e.g. Xiaomi
  HyperOS) can NOT reproduce — the predictive code path never runs there.

## Steps to reproduce

1. Launch the app, tap **Scenario 1** (page B is a plain `MaterialPageRoute`).
2. On page B, tap **Push page C** (page C is a
   `MaterialPageRoute(fullscreenDialog: true)`).
3. Pop page C with a predictive back gesture from the **right** edge and let it
   commit → page C correctly moves **left**, away from the finger.
4. On page B, start another predictive back gesture from the **right** edge.

**Expected:** page B moves left, like page C did.
**Actual:** page B moves **right**, toward the finger. Every following gesture
on page B keeps the inverted direction.

**Scenario 2** shows the same bug without `fullscreenDialog`: page B is pushed
via a route whose `canTransitionTo` returns `false` (what GetX-style routing
packages do) and page C is a plain `MaterialPageRoute`.

## Building

CI (GitHub Actions) builds debug and release APKs on every push to `main` and
via manual dispatch — grab them from the workflow run's artifacts.

Locally:

```
flutter build apk --debug
flutter build apk --release
```

Built with Flutter `3.44.8` (pinned in `pubspec.yaml`, used by CI via
`flutter-version-file`).

Note: this repo intentionally contains no gradle wrapper and no launcher
icons; the Flutter tool regenerates the wrapper on first build, and the app
uses the system default icon.

# predictive_back_demo

Minimal reproduction for a Flutter framework bug: **the predictive back page
transition animates toward the wrong side** after popping a route that the
route below can't transition to (`canTransitionTo == false`, which is what
routes from routing packages such as GetX return).

Tracking issue: `[FLUTTER ISSUE URL]`

## Requirements

- A device that delivers progressive back events to apps: e.g. a **Pixel on
  Android 14+** with **gesture navigation** enabled. (On Android 14, enable the
  "Predictive back animations" developer option if nothing animates.)
- OEM systems that don't dispatch progressive back events (e.g. Xiaomi
  HyperOS) can NOT reproduce — the predictive code path never runs there.

## Steps to reproduce

1. Launch the app, tap **Open page B**. Page B is pushed with a
   `MaterialPageRoute` subclass whose `canTransitionTo` returns `false`
   (mimicking GetX-style routing packages).
2. On page B, tap **Push page C** (a plain `MaterialPageRoute`).
3. Pop page C with a predictive back gesture from the **right** edge and let it
   commit → page C correctly moves **left**, away from the finger.
4. On page B, start another predictive back gesture from the **right** edge.

**Expected:** page B moves left, like page C did.
**Actual:** page B moves **right**, toward the finger. Only the first gesture
after the pop is affected (the gesture itself rebuilds the transition subtree
and clears the stale state) — repeat from step 2 to trigger it again. Gestures
from the left edge look correct because the stale direction coincides with the
left-edge direction.

Note: `MaterialPageRoute(fullscreenDialog: true)` on top also gives the route
below `canTransitionTo == false`, but fullscreen dialogs can't be popped by a
predictive gesture at all (`PageRoute.popGestureEnabled` excludes them), so the
`canTransitionTo` override is the minimal trigger.

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

# Sift

On-device iPhone app for sorting concert and trip photos down to favorites. SwiftUI, PhotoKit, Vision, SwiftData. iOS 18+, iPhone only, portrait.

- Plan: `docs/tickets.md` and GitHub issues (milestones M0–M5)
- Look: `docs/design.md`
- Clickable prototype: `prototype/index.html`

## Layout

```
app/
  sift.xcodeproj
  Info.plist       extra keys merged into the generated plist (UIAppFonts, photo usage string)
  sift/
    App/           app entry point
    Views/         one folder per screen (Moments/, Vault/, ...); RootView owns the tab navigation stacks
    DesignSystem/  fonts, radii, shared components (StatusView, Banner)
    Resources/     bundled files (Fonts/)
    Models/        (planned) plain data types, no PhotoKit or SwiftUI
    Services/      @Observable models for system work: photo library access (PhotoLibraryAccess), later grouping, Vision, geocoding
    Assets.xcassets
  siftTests/       unit tests (Swift Testing)
  siftUITests/     UI tests, e.g. the photo permission flow (not run in CI)
```

Create a folder only when its first real file lands. No placeholder files.

The project uses Xcode's synchronized folders, so any file placed under `app/sift/` is added to the app target automatically. Don't add `.gitkeep` or other stray files there: they get copied into the app bundle and break the build.

## Build and test

```
cd app
xcodebuild -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17' build CODE_SIGNING_ALLOWED=NO
xcodebuild -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:siftTests CODE_SIGNING_ALLOWED=NO
```

UI tests (slower, run when touching the photo permission flow):

```
xcodebuild -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:siftUITests CODE_SIGNING_ALLOWED=NO
```

`xcrun simctl privacy grant photos` doesn't give the read-write access Sift checks, so test permission states through the UI tests instead.

Build before saying a change works. Run the unit tests when touching `Models/` or `Services/`.

## Dev simulator

`scripts/seed-simulator.sh [seed]` sets up a separate "Sift Dev iPhone" simulator with a known photo library. Running it again erases and reseeds, and dates are relative to today, so the library is always the same. It prints what the app should find.

Seeds live in `scripts/seed/seeds/`, one JSON file each (`--list` shows them):

- `everyday` (default): a normal month, with a concert, brunch, beach sunset, 3-day trip, and photos with no location
- `stacks`: few moments with lots of bursts and blurry shots, for stacks and best-guess picks
- `edge-cases`: grouping boundaries (gaps near 90 minutes, moving over 1 km, midnight, travel, missing locations)
- `empty`: nothing in the last 30 days, for the empty state

Add `--bulk 1200` to any seed for scroll testing. To add a variation, copy a seed file and edit its scenarios. `scripts/seed/generate.swift` turns a seed file into photos with real dates and GPS.

Pick "Sift Dev iPhone" as the run destination, or pass `-destination 'platform=iOS Simulator,name=Sift Dev iPhone'`.

## Product rules

- Everything runs on device. No network calls, no accounts, no analytics.
- Never copy or re-save photos. Store only `PHAsset.localIdentifier` plus our own metadata.
- Never delete photos. Photos the user passes on go to the Archive album.
- Grouping and scoring logic lives in pure functions over `Models/` types so it can be unit tested without PhotoKit.

## Code style

- Indent with 2 spaces (set in `.editorconfig` and the Xcode project).
- Types are UpperCamelCase (`SiftApp`, `MomentsView`). One main type per file, file named after it.
- Views only lay out and forward taps. They don't call system APIs (PhotoKit, Settings, ...) or hold logic. App-wide state and the actions on it live in an `@Observable` model in `Services/`, created once in `SiftApp` and read with `@Environment(Model.self)` (e.g. `PhotoLibraryAccess`).
- Use `StatusView` for full-screen states (`.message`, `.loading`, `.failed`) and `Banner` for one-line notices instead of building new ones. Both take an optional `button: (title, action)`.
- Use Apple's types directly (e.g. `PHAuthorizationStatus`) instead of wrapping them in our own.
- Don't add a helper, extension, or shared type until it's needed in more than one place. A one-line check used once stays inline.
- Use the design tokens, never hard-coded values: colors from `Assets.xcassets` (`.ink`, `.canvas`, ...), fonts from `Font` (`.heading`, `.bodyText`, ...), corners from `Radius`. See `docs/design.md`.
- Keep comments short and only where the reason isn't obvious. No Xcode file header comments.

## Workflow

- One branch per ticket, named `<area>/<short-name>` (e.g. `setup/project-structure`).
- PR titles follow Conventional Commits: `<type>: <summary>`, lowercase, no period (e.g. `feat: add moments list`). PRs are squash-merged, so the title becomes the commit message on `main`.
  - `feat`: new feature or screen
  - `fix`: bug fix
  - `chore`: setup, config, cleanup
  - `docs`: README, CLAUDE.md, docs/
  - `refactor`: code change with no behavior change
  - `test`: adding or fixing tests
  - `ci`: GitHub Actions and other pipeline changes
  - `style`: formatting only
- PRs link their issue with `Closes #n` and list how the change was checked.
- Ask before pushing to `main`, force-pushing, or rewriting history.

## Git

- Do not add Claude as a co-author or contributor. No `Co-Authored-By: Claude` trailers in commits, and no "Generated with Claude Code" lines in pull requests or issues.

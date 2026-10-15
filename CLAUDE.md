# Sift

On-device iPhone app for sorting concert and trip photos down to favorites. SwiftUI, PhotoKit, Vision, SwiftData. iOS 18+, iPhone only, portrait.

- Plan: `docs/tickets.md` and GitHub issues (milestones M0–M5)
- Look: `docs/design.md`
- Clickable prototype: `prototype/index.html`

## Layout

```
app/
  sift.xcodeproj
  sift/
    App/           app entry point
    Views/         one folder per screen (Moments/, Vault/, ...)
    Models/        plain data types, no PhotoKit or SwiftUI
    Services/      photo library, grouping, Vision, geocoding
    DesignSystem/  colors, fonts, radii
    Assets.xcassets
  siftTests/       unit tests (Swift Testing)
  siftUITests/
```

The project uses Xcode's synchronized folders, so any file placed under `app/sift/` is added to the app target automatically. Don't add `.gitkeep` or other stray files there: they get copied into the app bundle and break the build.

## Build and test

```
cd app
xcodebuild -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17' build CODE_SIGNING_ALLOWED=NO
xcodebuild -project sift.xcodeproj -scheme sift -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:siftTests CODE_SIGNING_ALLOWED=NO
```

Build before saying a change works. Run the unit tests when touching `Models/` or `Services/`.

## Product rules

- Everything runs on device. No network calls, no accounts, no analytics.
- Never copy or re-save photos. Store only `PHAsset.localIdentifier` plus our own metadata.
- Never delete photos. Photos the user passes on go to the Archive album.
- Grouping and scoring logic lives in pure functions over `Models/` types so it can be unit tested without PhotoKit.

## Code style

- Types are UpperCamelCase (`SiftApp`, `MomentsView`). One main type per file, file named after it.
- Views stay small. Move logic into models or services.
- Pull colors, fonts, and radii from `DesignSystem/`, never hard-coded values (once #2 lands).
- Keep comments short and only where the reason isn't obvious. No Xcode file header comments.

## Workflow

- One branch per ticket, named `<area>/<short-name>` (e.g. `setup/project-structure`).
- PRs link their issue with `Closes #n` and list how the change was checked.
- Ask before pushing to `main`, force-pushing, or rewriting history.

## Git

- Do not add Claude as a co-author or contributor. No `Co-Authored-By: Claude` trailers in commits, and no "Generated with Claude Code" lines in pull requests or issues.

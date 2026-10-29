# Design notes

Current direction: cream stationery, navy ink, one rose accent. Upscale but still cute. Open the prototype (`prototype/index.html`) to see it.

## Color

| Swift (`Color.`) | Light     | Dark      | Use                                   |
|------------------|-----------|-----------|---------------------------------------|
| `canvas`         | `#F5F0E8` | `#0F1328` | App background (cream / deep navy)    |
| `paper`          | `#FFFDF8` | `#192040` | Cards                                 |
| `ink`            | `#1E2643` | `#F2EBE0` | Text, primary buttons                 |
| `highlight`      | `#C2607A` | `#E59BB0` | Progress, hearts, selection, eyebrows |
| `hairline`       | `#E4DBCD` | `#2B3257` | Hairline borders                      |
| `muted`          | `#6F6E7C` | `#A3A4B8` | Secondary text                        |
| `accentColor`    | `#1E2643` | `#E59BB0` | System tint: buttons, links, tab bar  |

Colors live in `Assets.xcassets`. Xcode generates the Swift names, so use `.foregroundStyle(.ink)` or `Color.canvas`.

Navy is the main color and rose is the accent. The palette is still open for iteration (see backlog).

## Type

- **Instrument Serif:** headings, moment titles, numbers. Italics carry the "cute" (captions, stickers).
- **Manrope:** body and buttons.
- **DM Mono:** timestamps, coordinates, counts.

| Swift (`Font.`) | Face                    | Size | Scales like    |
|-----------------|-------------------------|------|----------------|
| `displayLarge`  | Instrument Serif        | 44   | `.largeTitle`  |
| `display`       | Instrument Serif        | 32   | `.title`       |
| `heading`       | Instrument Serif        | 24   | `.title2`      |
| `headingItalic` | Instrument Serif Italic | 20   | `.title3`      |
| `bodyText`      | Manrope Regular         | 15   | `.body`        |
| `bodyEmphasis`  | Manrope SemiBold        | 15   | `.body`        |
| `label`         | Manrope SemiBold        | 13   | `.subheadline` |
| `note`          | Manrope Regular         | 12   | `.footnote`    |
| `mono`          | DM Mono Regular         | 11   | `.caption`     |

Font files and their licenses (SIL Open Font License) are in `app/sift/Resources/Fonts/`. Each file must also be listed under `UIAppFonts` in `app/Info.plist`, or iOS won't load it.

## Shape

- Radii stay small: `Radius.small` 3 (chips, thumbnails), `Radius.medium` 6 (buttons, photos), `Radius.large` 10 (cards).
- Use hairline borders instead of heavy shadows. Real shadows only on stacked photos and polaroids.

## Open questions

- The vault isn't working yet and needs a new direction.
- Quick pick or Compare as the default sorting style.

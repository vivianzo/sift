# Design notes

Current direction: cream stationery, navy ink, one rose accent. Upscale but still cute. Open the prototype (`prototype/index.html`) to see it.

## Color

| Token  | Light     | Dark      | Use                                   |
|--------|-----------|-----------|---------------------------------------|
| bg     | `#F5F0E8` | `#0F1328` | App background (cream / deep navy)    |
| paper  | `#FFFDF8` | `#192040` | Cards                                 |
| ink    | `#1E2643` | `#F2EBE0` | Text, primary buttons                 |
| accent | `#C2607A` | `#E59BB0` | Progress, hearts, selection, eyebrows |
| line   | `#E4DBCD` | `#2B3257` | Hairline borders                      |
| muted  | `#6F6E7C` | `#A3A4B8` | Secondary text                        |

Navy is the main color and rose is the accent. The palette is still open for iteration (see backlog).

## Type

- **Instrument Serif:** headings, moment titles, numbers. Italics carry the "cute" (captions, stickers).
- **Manrope:** body and buttons.
- **DM Mono:** timestamps, coordinates, counts.

## Shape

- Radii stay small: 3 (chips, thumbnails), 6 (buttons, photos), 10 (cards).
- Use hairline borders instead of heavy shadows. Real shadows only on stacked photos and polaroids.

## Open questions

- The vault isn't working yet and needs a new direction.
- Quick pick or Compare as the default sorting style.

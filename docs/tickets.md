# Starter tickets

Small, ordered steps. Each one should leave the app running. Work top to bottom; later milestones depend on earlier ones.

Labels: `setup` `design` `photos` `vision` `ui` `data`

---

## M0 · Setup

### 1. Create the Xcode project `setup`
Create a SwiftUI iOS app named Sift (iOS 18+, iPhone only) inside `app/`.
- [ ] Builds and runs on the simulator
- [ ] Two empty tabs: Moments and Vault
- [ ] Folders: `Models/`, `Services/`, `Views/`, `DesignSystem/`
- [ ] `.gitignore` keeps `xcuserdata` and build output out of git

### 2. Design tokens in Swift `design`
Port the prototype's look (see `docs/design.md`) into `DesignSystem/`.
- [ ] Color assets for cream, navy, rose, with light and dark variants
- [ ] Bundle Instrument Serif, Manrope, DM Mono (all Open Font License)
- [ ] `Radius` constants (3 / 6 / 10) and a type scale
- [ ] One SwiftUI preview that shows every color and text style

## M1 · Reading photos

### 3. Ask for photo library access `photos`
- [ ] Add the `NSPhotoLibraryUsageDescription` string to Info.plist
- [ ] Handle full, limited, and denied access, each with its own screen
- [ ] Denied screen links to Settings

### 4. Load recent photos `photos`
Fetch the last 30 days of photos with `PHAsset` and show them in a plain grid. This grid is temporary and only for checking that loading works.
- [ ] Thumbnails come from `PHCachingImageManager`
- [ ] Scrolling 1,000+ photos stays smooth
- [ ] Map each asset into a small `PhotoMeta` struct (id, date, location)

## M2 · Moments

### 5. Group photos into moments `data`
Pure Swift function: `[PhotoMeta] -> [Moment]`. Start a new moment after a gap of about 90 minutes or a move of about 1 km.
- [ ] No UI or PhotoKit inside the function, so it is easy to test
- [ ] Unit tests with made-up data: one concert, one day trip, photos with no location
- [ ] Thresholds live in one place so they are easy to tune

### 6. Name each moment `data`
Reverse geocode the moment's location with `CLGeocoder` ("TD Garden, Boston").
- [ ] Fallback when there is no location: "Saturday evening"
- [ ] Cache names so the geocoder isn't called again on each launch

### 7. Moments screen `ui`
Build the home list to match the prototype: collage, title, date and place, photo count.
- [ ] Tapping a card opens an empty detail screen for now

## M3 · Stacks

### 8. Find near-duplicate stacks `vision`
Inside a moment, group shots that are close in time and look alike, using `VNGenerateImageFeaturePrintRequest`.
- [ ] Run it on a real concert folder and note what threshold works
- [ ] Photos that match nothing become single-photo stacks
- [ ] Processing runs off the main thread with a progress indicator

### 9. Moment detail screen `ui`
Piles of stacks, the "why these are together" box, and progress.

## M4 · Culling

### 10. Best-guess scoring `vision`
Score each shot and pick a suggested winner per stack.
- [ ] Faces: `VNDetectFaceCaptureQualityRequest` (which also catches closed eyes)
- [ ] Sharpness: a blur estimate with Core Image or Accelerate
- [ ] Each pick comes with 1–2 plain reasons ("sharpest", "eyes open")

### 11. Quick pick screen `ui`
Big suggested shot, filmstrip to swap, "Keep this one".

### 12. Compare screen `ui`
Grid of all shots in a stack, tap hearts to keep several. Toggle between Quick pick and Compare.

## M5 · Saving picks

### 13. Save picks with SwiftData `data`
Store moments, stacks, and picks. Store photos only as `PHAsset.localIdentifier`, never as copies.
- [ ] Picks survive relaunching the app
- [ ] A photo deleted in the Photos app drops out without crashing

### 14. Archive album `photos`
Put photos you passed on into a "Sift Archive" album in Photos. Nothing gets deleted.
- [ ] Needs read-write access, so update the permission screen for it

---

## Backlog (not started)

- **Rethink the vault.** The scrapbook in the prototype is a placeholder. Explore other directions before building it.
- **Palette research.** Test pink and navy against alternatives in the field before locking in colors.
- **Instagram post planner.** Pick 5–10 keepers, preview 4:5 crops, suggest an order.
- **Background processing.** Group new photos with `BGProcessingTask` so moments are ready when you open the app.
- **Trips.** Decide whether a trip is one moment or one per day.

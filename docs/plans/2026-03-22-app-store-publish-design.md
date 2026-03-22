# App Store Publish Readiness — Design Document

**Date:** 2026-03-22
**Status:** Approved
**Scope:** App icon, onboarding flow, AccentColor, publish checklist

---

## 1. Context

Awaitr has completed Sprints 1-6 from the PRD. All core features are implemented:
- 3-tab navigation (Home, Archive, Settings)
- Full CRUD with SwiftData persistence
- Status pipeline with 5 stages
- Notification scheduling
- CSV export
- 70+ unit tests
- Liquid Glass UI throughout

The app needs finishing touches before App Store submission.

---

## 2. App Icon

### Design
- Bold rounded **"A"** letterform (SF Pro Rounded Bold style)
- Background: 4-color diagonal gradient using category colors:
  - Top-left: Violet (`#6C63FF`)
  - Top-right: Coral (`#E24B4A`)
  - Bottom-left: Green (`#3B6D11`)
  - Bottom-right: Amber (`#BA7517`)
- Subtle Liquid Glass highlight: semi-transparent white arc in upper portion
- Rounded corners per Apple's icon mask (auto-applied)

### Variants
| Variant | Description |
|---|---|
| Light | Full gradient background + white "A" |
| Dark | Darker gradient (60% brightness) + white "A" |
| Tinted | Single-color silhouette for iOS tinted icon mode |

### Deliverables
- `AppIcon-Light.png` — 1024x1024
- `AppIcon-Dark.png` — 1024x1024
- `AppIcon-Tinted.png` — 1024x1024
- Updated `Contents.json` in `AppIcon.appiconset`

### Implementation
Since we cannot generate raster images in code, the app icon will be created as a **SwiftUI view rendered to image**, or the user will provide/commission the icon externally. We will:
1. Create a `AppIconPreview.swift` SwiftUI view that renders the icon design
2. This serves as a spec for the designer or for manual screenshot-to-PNG workflow
3. Update `Contents.json` to reference the final PNGs once added

---

## 3. Onboarding Flow

### Architecture
- New file: `OnboardingView.swift` in `Views/Onboarding/`
- Gate: `@AppStorage("hasSeenOnboarding")` boolean, checked in `AwaitrApp.swift`
- Shows full-screen cover on first launch, before main TabView

### Screen Breakdown

#### Screen 1: Welcome
- **Title:** "Welcome to Awaitr"
- **Subtitle:** "Your personal waitlist manager"
- **Visual:** Large app icon (rendered in SwiftUI) centered
- **Action:** "Get Started" button (primary, Violet)
- **Skip:** "Skip" in top-right corner

#### Screen 2: Track Everything
- **Title:** "Track Everything You Wait For"
- **Subtitle:** "Jobs, products, admin docs, and events — all in one place"
- **Visual:** 4 category cards in 2x2 grid, each with emoji + label + color
  - 💼 Jobs & Scholarships (Violet)
  - 📦 Products & Pre-orders (Coral)
  - 📋 Administration (Amber)
  - 🎪 Events & Community (Green)
- **Action:** "Next" button

#### Screen 3: See Your Progress
- **Title:** "See Your Progress"
- **Subtitle:** "Every wait follows a clear pipeline from start to finish"
- **Visual:** Horizontal pipeline visualization showing 5 stages:
  - Submitted → In Review → Awaiting → Accepted/Rejected
  - Animated: dots light up sequentially
- **Action:** "Next" button

#### Screen 4: Add Your First Wait
- **Title:** "Add Your First Wait"
- **Subtitle:** "What are you waiting for right now?"
- **Visual:** Inline mini-form:
  - Title text field (required)
  - Category picker (2x2 grid, same as AddEditItemView)
  - No other fields — keep it minimal
- **Action:** "Create & Start" button
  - Creates WaitItem with defaults (submitted today, medium priority)
  - Sets `hasSeenOnboarding = true`
  - Dismisses onboarding
- **Alt action:** "Skip for Now" link below button
  - Sets `hasSeenOnboarding = true` without creating item

### UI Details
- `TabView` with `.tabViewStyle(.page)` for swipe between screens
- Page indicator dots at bottom
- Liquid Glass cards for content areas
- Spring animations on transitions
- Each screen fades/slides in content with staggered timing

### Files
| File | Location |
|---|---|
| `OnboardingView.swift` | `Views/Onboarding/` |
| `OnboardingPageView.swift` | `Views/Onboarding/` (reusable page template) |

### App Entry Point Change
```swift
// AwaitrApp.swift
@AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

var body: some Scene {
    WindowGroup {
        ContentView()
            .fullScreenCover(isPresented: .constant(!hasSeenOnboarding)) {
                OnboardingView()
            }
    }
}
```

---

## 4. AccentColor

- Set `AccentColor.colorset` to Violet (`#6C63FF`)
- This affects:
  - Launch screen tint
  - Default button tints
  - Navigation bar accent
- Both light and dark appearance use the same Violet

---

## 5. App Store Screenshots (User Responsibility)

### Screens to Capture (6 screenshots)
1. **Dashboard** — "Track everything you're waiting for"
2. **Item Detail + Pipeline** — "See your progress at a glance"
3. **Add Item Form** — "Add a wait in seconds"
4. **Archive + Stats** — "Celebrate your wins"
5. **Notification** — "Never miss a follow-up"
6. **Onboarding Screen 1** — "Your personal waitlist manager"

### Device Sizes
- iPhone 6.7" (iPhone 16 Pro Max) — 1290 x 2796 px
- iPhone 6.1" (iPhone 16 Pro) — 1179 x 2556 px

### Process
1. Run app in Simulator at each device size
2. Populate with sample data (variety of categories, statuses, priorities)
3. Take screenshots via Simulator (Cmd+S)
4. Optionally add framing/captions using tools like Shots.so or RocketSim
5. Upload to App Store Connect

---

## 6. App Store Connect Checklist (User Responsibility)

### Required Before Submission
- [ ] Apple Developer Program enrollment ($99/year)
- [ ] Create app record in App Store Connect
- [ ] App name: "Awaitr"
- [ ] Subtitle: "Your Personal Waitlist Manager"
- [ ] Category: Productivity
- [ ] Privacy policy URL (can be simple GitHub Pages or Notion page)
- [ ] Age rating: 4+ (no objectionable content)
- [ ] Upload screenshots (6 per device size)
- [ ] Write description and keywords
- [ ] Archive build in Xcode → Upload
- [ ] Submit for App Review

### Suggested App Store Description
> Track everything you're waiting for — job applications, scholarship decisions, product pre-orders, government documents, and event waitlists.
>
> Awaitr brings calm to the chaos of waiting with a clear status pipeline, smart follow-up reminders, and outcome analytics. No accounts, no cloud, no tracking — your data stays on your device.
>
> Features:
> - Visual status pipeline: Submitted → In Review → Awaiting → Accepted/Rejected
> - 4 color-coded categories: Jobs, Products, Admin, Events
> - Follow-up reminders with local notifications
> - Archive with win/loss analytics
> - CSV export for your records
> - Beautiful Liquid Glass design for iOS 26

### Suggested Keywords
`waitlist, tracker, job application, waiting, pipeline, status, reminder, follow-up, scholarship, pre-order`

---

## 7. What We Build vs. What User Does

| Task | Owner |
|---|---|
| App icon SwiftUI preview/spec | Code (us) |
| App icon final PNG creation | User (design tool or screenshot) |
| Onboarding flow (4 screens) | Code (us) |
| AccentColor configuration | Code (us) |
| Commit all pending changes | Code (us) |
| App Store Connect setup | User |
| Screenshots | User |
| Privacy policy page | User |
| Build archive + upload | User |
| Submit for review | User |

---

*Design approved by user on 2026-03-22.*

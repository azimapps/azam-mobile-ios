# Awaitr — Product Requirements Document

**Your Personal Waitlist Manager**

| Field | Value |
|---|---|
| Version | 1.0 |
| Date | March 2026 |
| Author | Fiqhro Dedhen Supatmo |
| Platform | iOS 26+ (SwiftUI + Liquid Glass) |
| Status | Pre-development |

---

## 1. Executive Summary

Awaitr is a free, offline-first iOS app that helps users track everything they're waiting for in life. From job applications and scholarship decisions to product pre-orders, administrative documents, and event waitlists — Awaitr brings clarity and calm to the anxious experience of waiting.

The app targets iOS 26 as its minimum deployment version, taking full advantage of Apple's new Liquid Glass UI design language introduced at WWDC 2025. Built entirely with SwiftUI, SwiftData, and native Apple frameworks, Awaitr requires zero third-party dependencies and zero user accounts.

The design philosophy blends Duolingo's playful energy with Things 3's refined task management, creating an interface that feels both joyful and trustworthy.

---

## 2. Problem Statement

### 2.1 The Waiting Problem

Modern life involves constant waiting. People submit job applications, apply for scholarships, pre-order products, file government paperwork, and join event waitlists — often juggling dozens of these simultaneously.

Currently, most people track these items through a patchwork of email searches, notes apps, spreadsheets, and mental bookmarks. This creates three core problems:

- **Anxiety amplification:** Without clear visibility into status and timelines, uncertainty compounds into stress.
- **Missed follow-ups:** Critical deadlines for checking status, sending follow-up emails, or providing additional documents slip through the cracks.
- **No outcome reflection:** Users never build a picture of their overall success rates, patterns, or progress over time.

### 2.2 Why Existing Tools Fall Short

General-purpose tools (Reminders, Notes, Trello, spreadsheets) lack the domain-specific workflow that waiting requires: a status pipeline with meaningful stages, timeline-aware follow-up reminders, and outcome tracking with win/loss analytics.

---

## 3. Target Audience

### 3.1 Primary Personas

**Persona A: The Active Job Seeker**
Age 22–35, currently applying to 10–50 jobs simultaneously. Needs to track which companies are in which stage, when to follow up, and overall conversion rates. Frustrated by losing track of applications across multiple job boards.

**Persona B: The University Student**
Age 18–28, managing scholarship applications, program admissions, dormitory waitlists, and course registration outcomes. Juggles academic deadlines alongside these waiting periods.

**Persona C: The Organized Adult**
Age 28–45, tracking a mix of product pre-orders, government document processing (passports, permits, tax refunds), and community event registrations. Values having one place for all pending life items.

### 3.2 User Characteristics

- iPhone users running iOS 26 or later
- Comfortable with simple app interactions (no onboarding needed)
- Privacy-conscious: prefer offline-first apps with no mandatory accounts
- Appreciate visual, playful design that reduces the stress of waiting

---

## 4. Product Vision & Principles

### 4.1 Vision Statement

> *Awaitr transforms the anxiety of waiting into a sense of organized progress — giving users calm confidence that nothing will slip through the cracks.*

### 4.2 Design Principles

1. **Offline-first, always:** All data lives on-device. No accounts, no servers, no sync complexity.
2. **Calm, not clinical:** Playful colors and Liquid Glass surfaces create warmth; status pipelines create order.
3. **Zero friction:** Adding a new wait item should take under 15 seconds. No mandatory fields beyond title and category.
4. **Progress over perfection:** The status pipeline gives visual momentum even when users are powerless to speed things up.
5. **Celebrate outcomes:** Both acceptances and rejections are acknowledged — wins are celebrated, losses are honored.

---

## 5. Feature Specification

### 5.1 Categories

Four color-coded life categories organize every wait item:

| Emoji | Category | Color | Hex |
|---|---|---|---|
| 💼 | Job & Scholarship | Violet | `#6C63FF` |
| 📦 | Products & Pre-order | Coral | `#E24B4A` |
| 📋 | Administration | Amber | `#BA7517` |
| 🎪 | Events & Community | Green | `#3B6D11` |

Each category has a dedicated emoji identifier and color that persists across all UI surfaces including cards, charts, and filter tabs.

### 5.2 Status Pipeline

Every wait item progresses through a linear pipeline:

| Status | Label | Description |
|---|---|---|
| `submitted` | Waiting to hear back | Initial submission is complete. The ball is in their court. |
| `inReview` | Being evaluated | Confirmation received that the submission is actively being reviewed. |
| `awaiting` | Decision pending | Review is complete; a decision is expected soon. |
| `accepted` | Positive outcome | Terminal state. The wait ended with a positive result. |
| `rejected` | Negative outcome | Terminal state. The wait ended with a negative result. |

Status transitions are manual (user-driven). Each transition is logged in the `statusHistory` array with a timestamp for the timeline view.

### 5.3 Core Data Model: WaitItem

The central entity stored via SwiftData:

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | `UUID` | Yes | Auto-generated primary key |
| `title` | `String` | Yes | Max 80 characters |
| `category` | `WaitCategory` | Yes | Enum: `job`, `product`, `admin`, `event` |
| `status` | `WaitStatus` | Yes | Enum: `submitted`, `inReview`, `awaiting`, `accepted`, `rejected` |
| `submittedAt` | `Date` | Yes | When the item was originally submitted |
| `expectedAt` | `Date?` | No | Optional expected resolution date |
| `followUpAt` | `Date?` | No | Triggers local push notification |
| `notificationId` | `String?` | No | `UNUserNotificationCenter` identifier for cancellation |
| `priority` | `WaitPriority` | Yes | Enum: `low`, `medium`, `high` (default: `medium`) |
| `notes` | `String` | No | Max 500 characters, free-text notes |
| `attachmentUrl` | `String?` | No | Optional file reference (future use) |
| `statusHistory` | `[StatusEntry]` | Yes | Array of `{status, timestamp}` for timeline log |
| `createdAt` | `Date` | Yes | Record creation timestamp |
| `updatedAt` | `Date` | Yes | Last modification timestamp |
| `isArchived` | `Bool` | Yes | Whether item is in the archive (default: `false`) |

#### StatusEntry (Embedded Model)

| Field | Type | Notes |
|---|---|---|
| `id` | `UUID` | Auto-generated |
| `status` | `WaitStatus` | The status at this point in time |
| `timestamp` | `Date` | When this status was set |

### 5.4 Enums

```swift
enum WaitCategory: String, Codable, CaseIterable {
    case job        // 💼 #6C63FF
    case product    // 📦 #E24B4A
    case admin      // 📋 #BA7517
    case event      // 🎪 #3B6D11
}

enum WaitStatus: String, Codable, CaseIterable {
    case submitted
    case inReview
    case awaiting
    case accepted
    case rejected
}

enum WaitPriority: String, Codable, CaseIterable {
    case low
    case medium
    case high
}
```

---

## 6. Screen Specifications

### 6.1 Home Dashboard

**SwiftUI View:** `DashboardView`

**Purpose:** The primary screen users see on launch. Provides at-a-glance status of all active wait items with filtering and quick actions.

**Layout:**

- **Summary Stats Bar:** Four Liquid Glass cards showing count per category, with color-coded accents. Tapping a card filters the list below.
- **Category Filter Tabs:** Horizontal scrollable tabs (All, Job, Product, Admin, Event) using Liquid Glass pill style.
- **Active Items List:** Sorted by priority (high first), then by `submittedAt` (oldest first). Each card shows title, category badge, status indicator, days waiting, and priority dot.
- **Empty State:** Friendly illustration with "Nothing to wait for!" message and a prominent "+ Add Item" button.
- **FAB (Floating Action Button):** Bottom-right "+" button with Liquid Glass material, spring animation on tap, navigates to Add Item screen.

**Components:**
- `SummaryStatsView` — 2×2 grid of category stat cards
- `CategoryFilterBar` — horizontal scrollable pill tabs
- `WaitItemCard` — card with category badge, title, status badge, mini pipeline, priority dot
- `EmptyStateView` — illustration + CTA

### 6.2 Item Detail

**SwiftUI View:** `ItemDetailView`

**Purpose:** Deep-dive into a single wait item. Shows full status pipeline visualization, timeline history, and all metadata.

**Layout:**

- **Pipeline Progress Bar:** Horizontal Liquid Glass stepped indicator showing all five statuses with the current one highlighted in category color. Animated transitions when status changes.
- **Info Card:** Liquid Glass surface showing submitted date, expected date, days waiting (live counter), priority badge, and follow-up date.
- **Timeline Log:** Vertical timeline showing each status change with date, relative time (e.g., "12 days ago"), and connecting line in category color.
- **Notes Section:** Expandable text area for user notes. Editable inline.
- **Action Buttons:** "Advance Status" (primary), "Edit", "Archive", "Delete" with confirmation dialog.

**Components:**
- `PipelineProgressView` — horizontal stepped indicator with `matchedGeometryEffect`
- `DetailInfoCard` — 2×2 grid of date/counter cells
- `TimelineView` — vertical timeline with dots and connecting lines
- `NotesCard` — expandable text area
- `ActionButtonBar` — HStack of styled buttons

### 6.3 Add/Edit Item

**SwiftUI View:** `AddEditItemView`

**Purpose:** Form for creating new wait items or editing existing ones.

**Form Fields:**

1. **Title** (required) — text field, max 80 characters, live character counter
2. **Category** (required) — horizontal segmented picker with emoji + label + color (2×2 grid)
3. **Submitted Date** (required) — date picker, defaults to today
4. **Expected Date** (optional) — date picker for expected resolution
5. **Follow-up Reminder** (optional) — date + time picker, schedules a local push notification
6. **Priority** — three-option selector (Low, Medium, High) with color indicators
7. **Notes** (optional) — multiline text area, max 500 characters

**Behavior:**
- "Save" button disabled until title and category are set
- Edit mode pre-fills all fields from existing `WaitItem`
- Cancellation triggers discard confirmation if changes were made

### 6.4 Archive

**SwiftUI View:** `ArchiveView`

**Purpose:** Repository of resolved wait items (accepted or rejected), providing historical context and outcome analytics.

**Layout:**

- **Win/Loss Summary:** Top section showing total accepted vs rejected with percentage breakdown (donut chart), overall and per-category.
- **Monthly Grouping:** Items grouped by resolution month (e.g., "March 2026") in reverse chronological order.
- **Item Cards:** Compact version of the home card with accepted/rejected badge (green check / red X). Tapping opens a read-only detail view.
- **Unarchive Action:** Swipe action to move an item back to active status.

**Components:**
- `ArchiveStatsView` — donut chart + legend
- `MonthSection` — grouped list with month header
- `ArchiveItemCard` — compact card with outcome indicator

### 6.5 Settings

**SwiftUI View:** `SettingsView`

**Features:**

1. **Notification Preferences:** Toggle for enabling/disabling follow-up reminders. Default reminder time selector.
2. **Export to CSV:** Export all items (active + archived) as a `.csv` file via the iOS share sheet.
3. **Clear All Data:** Destructive action with double-confirmation dialog. Deletes all items and resets the app.
4. **App Icon Picker:** Choice of 4 alternate app icons matching the category colors.
5. **About:** App version, credits, privacy policy link, and feedback email.

---

## 7. Technical Architecture

### 7.1 Tech Stack

| Layer | Technology |
|---|---|
| UI Framework | SwiftUI (iOS 26+) with Liquid Glass design language |
| Persistence | SwiftData with `@Model` macro |
| Notifications | UserNotifications framework (`UNUserNotificationCenter`) |
| Architecture | MVVM with `@Observable` ViewModels |
| Navigation | `NavigationStack` with typed destinations |
| Animations | SwiftUI spring animations + matched geometry effects |
| Dependencies | Zero third-party — pure Apple frameworks only |
| Min Deployment | iOS 26.0 |

### 7.2 Project Structure

```
Awaitr/
├── App/
│   ├── AwaitrApp.swift              # @main entry point, SwiftData container
│   └── ContentView.swift            # TabView with Liquid Glass tab bar
├── Models/
│   ├── WaitItem.swift               # @Model SwiftData entity
│   ├── StatusEntry.swift            # Codable embedded model
│   ├── WaitCategory.swift           # Category enum + colors + labels
│   ├── WaitStatus.swift             # Status enum + pipeline logic
│   └── WaitPriority.swift           # Priority enum + colors
├── ViewModels/
│   ├── DashboardViewModel.swift     # Home screen state + filtering
│   ├── ItemDetailViewModel.swift    # Detail screen + status transitions
│   ├── AddEditViewModel.swift       # Form validation + CRUD
│   ├── ArchiveViewModel.swift       # Archive grouping + stats
│   └── SettingsViewModel.swift      # Export + clear data + notifications
├── Views/
│   ├── Home/
│   │   ├── DashboardView.swift      # Main home screen
│   │   ├── SummaryStatsView.swift   # 2×2 category stat cards
│   │   ├── CategoryFilterBar.swift  # Horizontal pill tabs
│   │   ├── WaitItemCard.swift       # Item card with mini pipeline
│   │   └── EmptyStateView.swift     # No items illustration
│   ├── Detail/
│   │   ├── ItemDetailView.swift     # Full item detail
│   │   ├── PipelineProgressView.swift # Horizontal status stepper
│   │   ├── TimelineView.swift       # Vertical status history
│   │   └── NotesCard.swift          # Expandable notes
│   ├── AddEdit/
│   │   ├── AddEditItemView.swift    # Form screen
│   │   └── CategoryPickerView.swift # 2×2 category grid
│   ├── Archive/
│   │   ├── ArchiveView.swift        # Archive list
│   │   ├── ArchiveStatsView.swift   # Donut chart + legend
│   │   └── ArchiveItemCard.swift    # Compact outcome card
│   ├── Settings/
│   │   └── SettingsView.swift       # Settings screen
│   └── Components/
│       ├── GlassCard.swift          # Reusable glass surface
│       ├── PriorityDot.swift        # Colored priority indicator
│       ├── StatusBadge.swift        # Pill-shaped status label
│       └── FABButton.swift          # Floating action button
├── Extensions/
│   ├── Color+Category.swift         # Color(category:) initializer
│   ├── Date+Relative.swift          # "12 days ago" formatting
│   └── View+Glass.swift             # .glassCard() modifier
├── Services/
│   ├── NotificationService.swift    # Schedule/cancel notifications
│   └── ExportService.swift          # CSV generation + share sheet
└── Resources/
    ├── Assets.xcassets/             # Colors, app icons, images
    └── Preview Content/             # SwiftUI preview data
```

### 7.3 SwiftData Schema

The `WaitItem` model uses the `@Model` macro for automatic SwiftData integration. `StatusEntry` is an embedded `Codable` struct stored as a JSON array within `WaitItem`. The schema supports lightweight migration for future field additions.

```swift
@Model
final class WaitItem {
    var id: UUID
    var title: String
    var category: WaitCategory
    var status: WaitStatus
    var submittedAt: Date
    var expectedAt: Date?
    var followUpAt: Date?
    var notificationId: String?
    var priority: WaitPriority
    var notes: String
    var attachmentUrl: String?
    var statusHistory: [StatusEntry]
    var createdAt: Date
    var updatedAt: Date
    var isArchived: Bool

    init(
        title: String,
        category: WaitCategory,
        submittedAt: Date = .now,
        priority: WaitPriority = .medium
    ) {
        self.id = UUID()
        self.title = title
        self.category = category
        self.status = .submitted
        self.submittedAt = submittedAt
        self.priority = priority
        self.notes = ""
        self.statusHistory = [StatusEntry(status: .submitted, timestamp: .now)]
        self.createdAt = .now
        self.updatedAt = .now
        self.isArchived = false
    }
}
```

### 7.4 Notification Architecture

Follow-up reminders use `UNUserNotificationCenter` with the following flow:

1. When a user sets a `followUpAt` date, schedule a `UNNotificationRequest` with a `UNCalendarNotificationTrigger`.
2. Store the notification identifier in the `notificationId` field for later cancellation.
3. When `followUpAt` is modified or cleared, cancel the existing notification and optionally schedule a new one.
4. When an item is archived or deleted, cancel any pending notification.

---

## 8. Design System

### 8.1 Liquid Glass Integration

iOS 26 introduces the Liquid Glass design language. Awaitr leverages the following APIs:

| API / Modifier | Usage in Awaitr |
|---|---|
| `.glassEffect()` | Applied to all card surfaces, tab bars, and modal sheets |
| `.meshGradient` | Dashboard background with subtle animated gradient using category colors |
| Liquid Glass `TabView` | Bottom navigation with translucent glass material |
| Glass `NavigationBar` | Frosted glass navigation bar with blur effect |
| Fluid transitions | Matched geometry effects for status pipeline animations |

### 8.2 Typography

| Role | Font | Size / Weight |
|---|---|---|
| Page Titles | SF Pro Rounded | 34pt Bold |
| Section Headers | SF Pro Rounded | 22pt Semibold |
| Card Titles | SF Pro Rounded | 17pt Medium |
| Body Text | SF Pro | 15pt Regular |
| Captions & Badges | SF Pro | 13pt Medium |
| Numeric Counters | SF Pro Rounded | 28pt Bold (tabular figures) |

### 8.3 Color Palette

| Color Name | Hex | Usage |
|---|---|---|
| Violet | `#6C63FF` | Job & Scholarship category, primary brand accent |
| Coral | `#E24B4A` | Products & Pre-order category, rejection indicators |
| Amber | `#BA7517` | Administration category, warning states |
| Green | `#3B6D11` | Events & Community category, acceptance indicators |
| Dark Navy | `#1A1A2E` | Primary text color |
| Medium | `#3D3D5C` | Secondary text |
| Soft Gray | `#666680` | Captions, labels |

### 8.4 Glass Surface Parameters

```
Background:  rgba(255, 255, 255, 0.65)
Blur:        16px saturate(160%)
Border:      0.5px solid rgba(255, 255, 255, 0.8)
Radius:      16px

Tab Bar:
  Background:  rgba(255, 255, 255, 0.72)
  Blur:        24px saturate(180%)
```

### 8.5 Animation Standards

All interactive animations use SwiftUI spring parameters:

| Interaction | Animation | Parameters |
|---|---|---|
| Card press | Scale + opacity | `spring(response: 0.3, dampingFraction: 0.7)` |
| Status advance | Slide + fade | `spring(response: 0.5, dampingFraction: 0.8)` |
| FAB tap | Scale bounce | `spring(response: 0.4, dampingFraction: 0.6)` |
| Tab switch | Matched geometry | `spring(response: 0.35, dampingFraction: 0.85)` |
| Archive swipe | Offset + opacity | `easeInOut(duration: 0.3)` |

### 8.6 Priority Indicators

| Priority | Color | Hex | Dot Size |
|---|---|---|---|
| High | Red | `#E24B4A` | 8px circle |
| Medium | Orange | `#EF9F27` | 8px circle |
| Low | Green | `#97C459` | 8px circle |

---

## 9. Development Roadmap

### Sprint 0: Foundation (1 day)

- Xcode project structure
- SwiftData schema (`WaitItem` + `StatusEntry`)
- App entry point (`AwaitrApp.swift`)
- Liquid Glass tab navigation (`ContentView.swift`)
- Color + enum extensions

### Sprint 1: Home Dashboard (2–3 days)

- `DashboardView` with summary stats bar
- `CategoryFilterBar` with horizontal pills
- `WaitItemCard` with mini pipeline
- `EmptyStateView`
- `FABButton` with spring animation

### Sprint 2: Add/Edit Item (2 days)

- `AddEditItemView` form
- `CategoryPickerView` (2×2 grid)
- Date pickers and priority selector
- Form validation
- SwiftData CRUD operations (create, update)

### Sprint 3: Item Detail (2–3 days)

- `ItemDetailView` layout
- `PipelineProgressView` with matched geometry
- `TimelineView` with vertical timeline
- `NotesCard` inline editing
- Status transition logic with `statusHistory` logging
- Action buttons (advance, edit, archive, delete)

### Sprint 4: Notifications (1–2 days)

- `NotificationService` — schedule, cancel, reschedule
- Permission request flow (`UNUserNotificationCenter.requestAuthorization`)
- Notification content with category and item title
- Auto-cancel on archive/delete

### Sprint 5: Archive (2 days)

- `ArchiveView` with monthly grouping
- `ArchiveStatsView` donut chart (accepted vs rejected)
- `ArchiveItemCard` with outcome indicator
- Swipe-to-unarchive
- Auto-archive on terminal status (accepted/rejected)

### Sprint 6: Settings & Polish (2–3 days)

- `SettingsView` with all options
- `ExportService` — CSV generation via share sheet
- Clear all data with double-confirmation
- App icon picker (4 variants)
- Final animation polish
- Accessibility audit (Dynamic Type, VoiceOver, color contrast)

**Total estimated: 12–16 days**

---

## 10. Non-Functional Requirements

### 10.1 Performance

| Metric | Target |
|---|---|
| App launch to interactive | < 1 second |
| List scroll (100 items) | 60 fps, no frame drops |
| Add item form submission | < 200ms save to SwiftData |
| CSV export (500 items) | < 3 seconds |
| App binary size | < 15 MB |

### 10.2 Accessibility

- All interactive elements support Dynamic Type
- VoiceOver labels on all buttons, cards, and status indicators
- Sufficient color contrast ratios (WCAG AA minimum)
- Status pipeline uses both color and shape indicators for colorblind accessibility
- Minimum touch target: 44×44pt

### 10.3 Privacy

- Zero user data collection
- No analytics, no crash reporting, no network requests
- All data stored locally via SwiftData, never leaves the device
- App functions identically in Airplane Mode
- No App Tracking Transparency prompt needed

### 10.4 Localization

- v1.0 ships in English only
- Codebase uses `LocalizedStringKey` throughout
- Date formatting via `Date.FormatStyle` (locale-aware)
- All user-facing strings in `Localizable.strings` ready for future translation

---

## 11. Success Metrics

As a free, offline-first app with no analytics, success is measured through proxy signals:

| Metric | Target (6 months post-launch) |
|---|---|
| App Store rating | ≥ 4.5 stars |
| Reviews mentioning ease of use | ≥ 60% of reviews |
| Organic downloads (no paid acquisition) | ≥ 5,000 |
| Feature on App Store (Liquid Glass showcase) | 1 feature in first 3 months |

---

## 12. Future Considerations (v2.0+)

These features are explicitly out of scope for v1.0:

| Feature | Notes |
|---|---|
| iCloud Sync | Cross-device sync via CloudKit. Requires schema migration planning. |
| Widgets | Home screen and Lock Screen widgets showing active count and next follow-up. |
| Apple Watch | Complication showing active count + glanceable next follow-up. |
| Siri Shortcuts | Voice-add items and query status via Siri. |
| Share Extension | Add items from other apps (e.g., share a job listing URL). |
| Custom Categories | User-defined categories beyond the four defaults. |
| Attachments | Photo/file attachments stored in app sandbox. |
| Haptic Feedback | Custom haptic patterns for status changes and celebrations. |
| iPad Support | Multi-column layout with sidebar navigation. |
| Mac Catalyst | Desktop version with keyboard shortcuts. |

---

## 13. Appendix

### 13.1 Glossary

| Term | Definition |
|---|---|
| Wait Item | A single entry representing something the user is waiting for |
| Pipeline | The five-stage status progression from Submitted to Accepted/Rejected |
| Terminal Status | Accepted or Rejected — statuses that end the pipeline |
| Liquid Glass | Apple's iOS 26 design language featuring translucent, glassy UI surfaces |
| SwiftData | Apple's modern persistence framework replacing Core Data |
| Archive | Collection of items that have reached a terminal status |
| FAB | Floating Action Button — the "+" button for quick item creation |

### 13.2 References

- Apple Human Interface Guidelines — iOS 26 Liquid Glass Design Language
- SwiftData documentation — developer.apple.com
- UserNotifications framework — developer.apple.com
- WCAG 2.1 Level AA — w3.org/WAI/WCAG21

### 13.3 Wireframe Reference

Interactive HTML wireframe available at: `Awaitr-Wireframe-Mockup.html`
Covers all 5 screens with working navigation, Liquid Glass surfaces, and design system documentation.

---

*— End of Document —*

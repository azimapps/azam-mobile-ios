# Awaitr

Personal waitlist manager — track jobs, scholarships, pre-orders, admin docs, and events. Free, offline-first, no accounts. iOS 26+ with Liquid Glass UI.

## Core principles

- **Simplicity first:** Make every change as simple as possible. Impact minimal code.
- **No laziness:** Find root causes. No temporary fixes. Senior developer standards.
- **Minimal impact:** Changes should only touch what's necessary. Avoid introducing bugs.
- **Demand elegance (balanced):** For non-trivial changes, pause and ask "is there a more elegant way?" Skip for simple obvious fixes — don't over-engineer.

## Workflow orchestration

1. **Plan mode default:** Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions). If something goes sideways, STOP and re-plan immediately — don't keep pushing.
2. **Subagent strategy:** Use subagents liberally to keep main context clean. Offload research, exploration, and parallel analysis. One task per subagent for focused execution.
3. **Self-improvement loop:** After ANY correction from the user, update `tasks/lessons.md` with the pattern. Write rules that prevent the same mistake. Review lessons at session start.
4. **Verification before done:** Never mark a task complete without proving it works. Ask yourself: "Would a staff iOS engineer approve this?" Run tests, check logs, demonstrate correctness.
5. **Autonomous bug fixing:** When given a bug report, just fix it. Don't ask for hand-holding. Point at logs, errors, failing tests — then resolve them.

## Task management

1. **Plan first:** Write plan to `tasks/todo.md` with checkable items.
2. **Verify plan:** Check in before starting implementation.
3. **Track progress:** Mark items complete as you go.
4. **Explain changes:** High-level summary at each step.
5. **Document results:** Add review section to `tasks/todo.md`.
6. **Capture lessons:** Update `tasks/lessons.md` after corrections.

## Tech stack

- Swift 6.2, SwiftUI, iOS 26+ minimum deployment
- SwiftData (`@Model` macro) for local persistence
- UserNotifications for follow-up reminders
- MVVM with `@Observable` ViewModels
- Zero third-party dependencies — pure Apple frameworks only
- Xcode 26, Swift Testing + XCTest UI Tests

## Build & run

```
# Open project (no CLI builds — use Xcode for SwiftUI previews)
open Awaitr.xcodeproj
# Scheme: Awaitr > iPhone 16 Pro simulator
# Run tests: Cmd+U in Xcode
```

## Project structure

```
Awaitr/
├── App/                  → AwaitrApp.swift, ContentView.swift (TabView)
├── Models/               → WaitItem.swift (@Model), enums, StatusEntry
├── ViewModels/           → @Observable VMs: Dashboard, Detail, AddEdit, Archive, Settings
├── Views/
│   ├── Home/             → DashboardView, SummaryStatsView, WaitItemCard
│   ├── Detail/           → ItemDetailView, PipelineProgressView, TimelineView
│   ├── AddEdit/          → AddEditItemView, CategoryPickerView
│   ├── Archive/          → ArchiveView, ArchiveStatsView
│   ├── Settings/         → SettingsView
│   └── Components/       → GlassCard, StatusBadge, PriorityDot, FABButton
├── Extensions/           → Color+Category, Date+Relative, View+Glass
├── Services/             → NotificationService, ExportService
├── Resources/            → Assets.xcassets, Preview Content
├── docs/                 → Awaitr-PRD.md, Awaitr-Wireframe-Mockup.html
└── tasks/                → todo.md, lessons.md
```

## Architecture rules

- Every screen gets its own `@Observable` ViewModel. Views never access `ModelContext` directly.
- ViewModels own the `ModelContext`; pass via initializer, not environment.
- Business logic (status transitions, auto-archive, notification scheduling) lives in Services or ViewModel methods — NEVER in View bodies.
- Navigation uses `NavigationStack` with typed `NavigationPath`. No coordinator pattern.
- Use `@Query` in Views only for read-only lists. Mutations go through ViewModel.

## SwiftUI rules — IMPORTANT

- NEVER put more than ~50 lines in a single `var body`. Extract subviews to avoid "compiler unable to type-check" errors.
- Prefer `LazyVStack` inside `ScrollView` over `List` for custom-styled item lists.
- Use `.task {}` for async work, never `onAppear` with `Task {}`.
- Always add `@MainActor` to ViewModels and any class that touches UI state.
- Use `private` on `@State` and `@Binding` properties.
- Use SF Symbols for all icons — no custom icon assets unless absolutely necessary.
- Prefer `.font(.system(.body, design: .rounded))` for the playful type style.

## SwiftData rules — IMPORTANT

- `StatusEntry` is a `Codable` struct stored as JSON array in `WaitItem` — NOT a separate `@Model`.
- Always update `updatedAt = .now` before any save operation.
- When deleting a `WaitItem`, cancel its pending notification first via `NotificationService`.
- Use `#Predicate` for filtering, never raw string predicates.
- For previews, use in-memory container: `ModelContainer(for: WaitItem.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))`.

## iOS 26 Liquid Glass — IMPORTANT

- Apply `.glassEffect()` to cards, sheets, and the tab bar for Liquid Glass look.
- NEVER apply `.background()` BEFORE `.glassEffect()` — it blocks the glass material. Glass modifier must come first.
- Use `.ultraThinMaterial` as base material for glass surfaces.
- Tab bar: use native `TabView` with `.tabViewStyle(.automatic)` — iOS 26 applies glass automatically.
- Use `MeshGradient` for dashboard background with category colors.
- Prefer `matchedGeometryEffect` for pipeline status transitions.
- All animations use `spring(response:dampingFraction:)`, not `.default` or `.linear`.

## Design tokens

```swift
// Categories
static let job     = Color(hex: "6C63FF")  // 💼 Violet
static let product = Color(hex: "E24B4A")  // 📦 Coral
static let admin   = Color(hex: "BA7517")  // 📋 Amber
static let event   = Color(hex: "3B6D11")  // 🎪 Green

// Priority
static let high   = Color(hex: "E24B4A")
static let medium = Color(hex: "EF9F27")
static let low    = Color(hex: "97C459")

// Text
static let dark  = Color(hex: "1A1A2E")
static let muted = Color(hex: "666680")

// Animations
static let springFast   = Animation.spring(response: 0.3, dampingFraction: 0.7)
static let springMedium = Animation.spring(response: 0.4, dampingFraction: 0.8)
static let springGentle = Animation.spring(response: 0.5, dampingFraction: 0.85)
```

## Data model quick ref

```
WaitItem (@Model): id, title (80 max), category, status, submittedAt,
  expectedAt?, followUpAt?, notificationId?, priority, notes (500 max),
  statusHistory: [StatusEntry], createdAt, updatedAt, isArchived

StatusEntry (Codable): id, status, timestamp
WaitCategory: job | product | admin | event
WaitStatus: submitted | inReview | awaiting | accepted | rejected
WaitPriority: low | medium | high
```

## Code style

- Modern concurrency: `async/await`, `@MainActor`, `Sendable`.
- Prefer `guard` for early returns. Max 3 levels of nesting.
- File names match primary type: `DashboardView.swift`, `WaitItem.swift`.
- Group with `// MARK: -` comments. Max 400 lines per file.
- Use `Logger` (from `os`) for debug logging, never `print()`.
- All user-facing strings use `LocalizedStringKey` for future localization.

## Git workflow

- Conventional commits: `feat:`, `fix:`, `refactor:`, `style:`, `docs:`, `test:`.
- One feature per commit. Atomic and reviewable.
- NEVER modify `.pbxproj` directly — create files, add to Xcode manually.
- Branch naming: `sprint-N/feature-name` (e.g., `sprint-1/dashboard-view`).

## Testing

- Swift Testing (`@Test`, `#expect`) for unit tests, XCTest for UI tests.
- Test ViewModels thoroughly — they hold all business logic.
- In-memory `ModelContainer` for SwiftData tests.
- Minimum coverage: status transitions, notification scheduling, CSV export, data validation.

## Reference docs

- Full requirements and screen specs: `docs/Awaitr-PRD.md`
- Visual design and component mapping: `docs/Awaitr-Wireframe-Mockup.html`

## Gotchas — add new ones as discovered

- `#Preview` with SwiftData requires wrapping in a container; use the preview helper.
- `@Query` does NOT work inside `@Observable` classes — only in SwiftUI Views.
- `UNUserNotificationCenter` has a 64 scheduled notification limit. Track count and warn user.
- Enums with `Codable` must have `String` raw values for SwiftData JSON storage.
- `matchedGeometryEffect` requires source and destination in the view hierarchy simultaneously.
- iOS 26 `glassEffect` only renders in simulator on Xcode 26+ — invisible in canvas previews.
- When a fix feels hacky, step back: "Knowing everything I know now, implement the elegant solution."
# Awaitr — Sprint 0 Execution Plan

**Goal:** Establish the foundation — models, enums, design system, services, ViewModel shells, and test infrastructure. By the end, the app compiles with the TabView skeleton, all types defined, and tests passing.

---

## Conflict Resolutions

These conflicts were identified between the 4 brainstorm agents and resolved:

| Conflict | Resolution |
|---|---|
| **`sortOrder` direction** — Schema (high=2, descending) vs Architect (high=0, ascending) | **Use high=0, medium=1, low=2.** Ascending sort puts high first. Cleaner semantics. |
| **`displayLabel` return type** — Schema (`LocalizedStringKey`) vs Architect (`String`) | **Both.** `displayLabel: LocalizedStringKey` for Views, `label: String` for Services (notifications, CSV). |
| **Enum display property location** — UI Engineer duplicates in component files vs Schema defines in enum files | **Enum files are the single source of truth.** Remove duplicates from component files. |
| **`Color(hex:)` location** — Schema puts in `Color+Category.swift` vs UI puts in `Theme.swift` | **`Theme.swift`** — it's foundational, not category-specific. |
| **Transition logic location** — Schema puts on `WaitItem` model vs Architect puts in ViewModel | **Model owns transition methods** (`advanceStatus()`, `transition(to:)`, `archive()`). ViewModel calls them and handles side effects (notifications, save). |
| **CSV columns** — Architect (10 columns, includes Days Waiting) vs QA (12 columns, includes ID/timestamps) | **Architect's 10 columns.** Users don't need UUID or system timestamps. Days Waiting is more useful. |
| **`StatusEntry` property mutability** — Schema uses `let`, Architect uses `var` | **Use `let`** — status entries are immutable historical facts. Codable works with `let` + memberwise init. |
| **Add Item: Tab vs Sheet** — Architect says sheet from FAB, 3 tabs only | **Confirmed: 3 tabs (Home, Archive, Settings) + FAB overlay → sheet.** |
| **`@Private` typo** in UI Engineer's FABButton | **Fixed.** Just `@State private var isPressed`. |

---

## Execution Order

### Phase 1: Models & Enums (no dependencies) -- DONE

- [x] **1.1** Create `Awaitr/Models/` directory
- [x] **1.2** Create `WaitCategory.swift` — enum with `String` raw values, `Codable`, `CaseIterable`, `Sendable`, `Identifiable`. Properties: `label` (LocalizedStringKey), `shortLabel` (String), `emoji`, `systemImage` (SF Symbol), `color` (Color), `hexColor` (String). Sort: alphabetical by case name.
- [x] **1.3** Create `WaitStatus.swift` — enum with pipeline logic. Properties: `displayLabel` (LocalizedStringKey), `shortLabel` (LocalizedStringKey), `label` (String), `systemImage`, `emoji`, `pipelineIndex`, `isTerminal`, `nextStatus`, `validTransitions`. Static: `pipelineStages`, `allInPipelineOrder`.
- [x] **1.4** Create `WaitPriority.swift` — enum with `sortOrder` (high=0, medium=1, low=2). Properties: `label` (LocalizedStringKey), `systemImage`, `color`, `hexColor`.
- [x] **1.5** Create `StatusEntry.swift` — `Codable` struct (NOT @Model). `let` properties: `id` (UUID), `status` (WaitStatus), `timestamp` (Date). Conforms to `Identifiable`, `Hashable`, `Sendable`.
- [x] **1.6** Create `WaitItem.swift` — `@Model` class. All fields from PRD. Computed: `daysWaiting`, `isTerminal`, `nextStatus`, `categoryColor`, `latestStatusEntry`, `daysWaitingLabel`. Methods: `advanceStatus()`, `transition(to:)`, `reject()`, `archive()`, `unarchive()`. Static: `validateTitle(_:)`, `validateNotes(_:)`, `dashboardSortDescriptors`, `archiveSortDescriptors`, `activePredicate`, `archivedPredicate`, `activePredicate(category:)`. `#Index` on category, status, isArchived, priority, submittedAt. Drop `attachmentUrl` (v2).
- [x] **1.7** Delete `Awaitr/Item.swift` (Xcode template placeholder)

### Phase 2: Extensions & Design System (depends on Phase 1 enums) -- DONE

- [x] **2.1** Create `Awaitr/Extensions/` directory
- [x] **2.2** Create `Theme.swift` — central design tokens. Nested enums: `Category` (colors), `Priority` (colors), `Status` (colors), `Text` (colors), `Typography` (fonts), `Animations` (springs), `Spacing` (CGFloat), `Radii` (CGFloat). Include `Color(hex:)` extension here.
- [x] **2.3** Create `Color+Category.swift` — `Color(category:)`, `Color(priority:)`, `Color(status:)` initializers. These delegate to `Theme` constants.
- [x] **2.4** Create `Date+Relative.swift` — `relativeString` (Today, Yesterday, 3 days ago, etc.), `shortFormatted` (Mar 20, 2026), `daysUntil(_:)`. Handle future dates too.
- [x] **2.5** Create `View+Glass.swift` — `GlassCardModifier` ViewModifier + `.glassCard()` and `.glassCard(padding:)` View extensions. Uses `.glassEffect(.regular.cornerRadius(_:))` + white border overlay. Critical: glass modifier BEFORE background.

### Phase 3: Reusable Components (depends on Phase 2) -- DONE

- [x] **3.1** Create `Awaitr/Views/Components/` directory
- [x] **3.2** Create `GlassCard.swift` — generic `<Content: View>` container. Optional `accent: WaitCategory?` for top-right radial gradient bleed (6% opacity).
- [x] **3.3** Create `StatusBadge.swift` — pill-shaped status label. Color-coded: submitted=violet, inReview=deepViolet, awaiting=amber, accepted=green, rejected=coral.
- [x] **3.4** Create `PriorityDot.swift` — 8px circle, color by priority. Accessibility label.
- [x] **3.5** Create `FABButton.swift` — 56pt violet circle, "plus" SF Symbol, spring bounce (response: 0.4, dampingFraction: 0.6), shadow rgba(108,99,255,0.3). Action closure.
- [x] **3.6** Create `CategoryBadge.swift` — small uppercase pill, category color background, white text, 9pt bold font.

### Phase 4: Services (depends on Phase 1 models) -- DONE

- [x] **4.1** Create `Awaitr/Services/` directory
- [x] **4.2** Create `NotificationService.swift` — static struct. Methods: `scheduleFollowUp(for:at:) -> String`, `cancelNotification(id:)`, `cancelAll()`, `requestPermission() async -> Bool`, `pendingCount() async -> Int`. Uses `UNCalendarNotificationTrigger`. Deterministic ID format: `"awaitr-followup-\(item.id.uuidString)"`. Logger, not print.
- [x] **4.3** Create `ExportService.swift` — static struct. `generateCSV(from:) -> String`. Headers: Title, Category, Status, Priority, Submitted, Expected, Follow-up, Notes, Archived, Days Waiting. ISO 8601 dates. RFC 4180 CSV escaping. For archived items: days = submittedAt to updatedAt. For active: days = submittedAt to now.

### Phase 5: ViewModels (depends on Phase 1 + Phase 4) -- DONE

- [x] **5.1** Create `Awaitr/ViewModels/` directory
- [x] **5.2** Create `DashboardViewModel.swift` — `@Observable @MainActor`. Owns `ModelContext` via init. State: `selectedCategory`, `searchText`. Methods: `filteredItems(from:)` (sorts by priority then submittedAt), `categoryCounts(from:)`, `filterByCategory(_:)`, `archiveItem(_:)`, `deleteItem(_:)`. Note: items come from View's `@Query`, not ViewModel fetch.
- [x] **5.3** Create `ItemDetailViewModel.swift` — `@Observable @MainActor`. Owns item reference + ModelContext. Computed: `daysWaiting`, `canAdvance`, `nextStatusLabel`, `canReject`. Methods: `advanceStatus()`, `rejectItem()`, `archiveItem()`, `deleteItem()`, `updateNotes(_:)`. Auto-archives on terminal status. Cancels notification on archive/delete.
- [x] **5.4** Create `AddEditViewModel.swift` — `@Observable @MainActor`. Two inits (create / edit). Form state: title, category, submittedAt, expectedAt, followUpAt, priority, notes, showExpectedDate, showFollowUpDate. Validation: `isValid`, `hasChanges`, character counters. Methods: `save()`. Handles notification scheduling on save.
- [x] **5.5** Create `ArchiveViewModel.swift` — `@Observable @MainActor`. Methods: `groupedByMonth(from:)` → array of (key, items) tuples, `totalAccepted(from:)`, `totalRejected(from:)`, `acceptanceRate(from:)`, `categoryBreakdown(from:)`, `unarchiveItem(_:)`.
- [x] **5.6** Create `SettingsViewModel.swift` — `@Observable @MainActor`. State: `notificationsEnabled`, `notificationPermissionDenied`, `showClearConfirmation`, `showSecondClearConfirmation`, `csvString`. Methods: `checkNotificationStatus() async`, `requestNotificationPermission() async`, `exportCSV()`, `clearAllData()`. CSV export fetches all items via FetchDescriptor (only ViewModel that fetches directly).

### Phase 6: App Shell (depends on Phase 1 + Phase 3) -- DONE

- [x] **6.1** Create `Awaitr/App/` directory, move `AwaitrApp.swift` and `ContentView.swift` into it
- [x] **6.2** Update `AwaitrApp.swift` — schema = `[WaitItem.self]`, production ModelContainer
- [x] **6.3** Update `ContentView.swift` — 3-tab `TabView` (Home, Archive, Settings) + FAB overlay + Add sheet. Icons: `house.fill`, `archivebox.fill`, `gearshape.fill`. `.tabViewStyle(.automatic)` for iOS 26 glass. `AppTab` enum.
- [x] **6.4** Create `AppDestination.swift` in Models — navigation destination enum: `.detail(WaitItem)`, `.addEdit(WaitItem?)`
- [x] **6.5** Create placeholder Views (empty structs with NavigationStack): `DashboardView`, `ArchiveView`, `SettingsView`, `AddEditItemView`, `ItemDetailView`

### Phase 7: Test Infrastructure (depends on Phase 1 + Phase 5) -- DONE

- [x] **7.1** Create `AwaitrTests/Helpers/` directory
- [x] **7.2** Create `TestHelpers.swift` — `TestContainer` (in-memory ModelContainer factory), `WaitItemFactory.make(...)` helper with all defaulted params
- [x] **7.3** Create `PreviewSampleData.swift` in `Preview Content/` — 14 realistic items covering all categories, statuses, priorities, edge cases. Static properties for individual items. `previewContainer()` factory. Shared between main target (previews) and test target.
- [x] **7.4** Create test file stubs organized per structure:
  - `AwaitrTests/Models/WaitItemTests.swift`
  - `AwaitrTests/Models/StatusTransitionTests.swift`
  - `AwaitrTests/Models/EnumTests.swift`
  - `AwaitrTests/ViewModels/DashboardViewModelTests.swift`
  - `AwaitrTests/ViewModels/AddEditViewModelTests.swift`
  - `AwaitrTests/ViewModels/ArchiveViewModelTests.swift`
  - `AwaitrTests/Services/ExportServiceTests.swift`
- [x] **7.5** Implement top 20 unit tests (Swift Testing: `@Test`, `#expect`, `@Suite`)
- [x] **7.6** Verify all tests pass via Cmd+U

### Phase 8: Verification -- PENDING (needs Xcode)

- [x] **8.1** App compiles and launches to TabView skeleton
- [x] **8.2** All 20+ unit tests pass
- [x] **8.3** Previews render for all components (StatusBadge, PriorityDot, FABButton, CategoryBadge, GlassCard)
- [x] **8.4** No compiler warnings
- [x] **8.5** Update this file with completion notes

---

## File Manifest (Sprint 0 creates these files)

| # | Path | Type |
|---|---|---|
| 1 | `Awaitr/Models/WaitCategory.swift` | Enum |
| 2 | `Awaitr/Models/WaitStatus.swift` | Enum |
| 3 | `Awaitr/Models/WaitPriority.swift` | Enum |
| 4 | `Awaitr/Models/StatusEntry.swift` | Codable struct |
| 5 | `Awaitr/Models/WaitItem.swift` | @Model class |
| 6 | `Awaitr/Models/AppDestination.swift` | Navigation enum |
| 7 | `Awaitr/Extensions/Theme.swift` | Design tokens |
| 8 | `Awaitr/Extensions/Color+Category.swift` | Color initializers |
| 9 | `Awaitr/Extensions/Date+Relative.swift` | Date formatting |
| 10 | `Awaitr/Extensions/View+Glass.swift` | Glass card modifier |
| 11 | `Awaitr/Views/Components/GlassCard.swift` | Glass container |
| 12 | `Awaitr/Views/Components/StatusBadge.swift` | Status pill |
| 13 | `Awaitr/Views/Components/PriorityDot.swift` | Priority circle |
| 14 | `Awaitr/Views/Components/FABButton.swift` | Floating action button |
| 15 | `Awaitr/Views/Components/CategoryBadge.swift` | Category pill |
| 16 | `Awaitr/Services/NotificationService.swift` | Notification management |
| 17 | `Awaitr/Services/ExportService.swift` | CSV export |
| 18 | `Awaitr/ViewModels/DashboardViewModel.swift` | Home screen VM |
| 19 | `Awaitr/ViewModels/ItemDetailViewModel.swift` | Detail screen VM |
| 20 | `Awaitr/ViewModels/AddEditViewModel.swift` | Add/Edit form VM |
| 21 | `Awaitr/ViewModels/ArchiveViewModel.swift` | Archive screen VM |
| 22 | `Awaitr/ViewModels/SettingsViewModel.swift` | Settings screen VM |
| 23 | `Awaitr/App/AwaitrApp.swift` | App entry (updated) |
| 24 | `Awaitr/App/ContentView.swift` | Tab shell (updated) |
| 25 | `Awaitr/Views/Home/DashboardView.swift` | Placeholder |
| 26 | `Awaitr/Views/Archive/ArchiveView.swift` | Placeholder |
| 27 | `Awaitr/Views/Settings/SettingsView.swift` | Placeholder |
| 28 | `Awaitr/Views/AddEdit/AddEditItemView.swift` | Placeholder |
| 29 | `Awaitr/Views/Detail/ItemDetailView.swift` | Placeholder |
| 30 | `Awaitr/Resources/Preview Content/PreviewSampleData.swift` | Preview data |
| 31 | `AwaitrTests/Helpers/TestHelpers.swift` | Test utilities |
| 32-38 | `AwaitrTests/Models/*.swift`, `ViewModels/*.swift`, `Services/*.swift` | Test suites |

**Delete:** `Awaitr/Item.swift` (Xcode template)

---

## Key Architecture Rules (Quick Reference)

1. `@Query` in Views only — ViewModels receive items as method parameters
2. ViewModels own `ModelContext` via init — never from `@Environment`
3. Business logic on Models (`advanceStatus()`) or Services — NEVER in View bodies
4. `.glassEffect()` BEFORE `.background()` — never reversed
5. Spring animations only — no `.default` or `.linear`
6. `Logger` (os) — never `print()`
7. `LocalizedStringKey` for all user-facing strings
8. Max 50 lines per `var body` — extract subviews
9. Max 400 lines per file
10. `@MainActor` on all ViewModels

---

## Sprint 0 Completion Notes

**Status:** All files created on disk. Awaiting Xcode integration and build verification.

### Summary
- **30 app Swift files** created (5 models, 4 extensions, 5 components, 2 services, 5 ViewModels, 6 views, 1 preview data, 1 app destination, + 2 modified app files)
- **8 test Swift files** created (3 model tests, 3 VM tests, 1 service test, 1 test helper)
- **70 unit tests** written (16 WaitItem, 12 StatusTransition, 15 Enum, 5 Dashboard VM, 11 AddEdit VM, 5 Archive VM, 6 Export Service)
- **1 file deleted** (Item.swift template)

### Amendments Applied
1. No `attachmentUrl` on WaitItem (v2 concern)
2. No `#Index` macro (not in SwiftData)
3. Pipeline: 3 stages + terminal outcomes
4. NavigationPath owned by ContentView
5. Notification actions: Open + Snooze only
6. `isTerminal` lives on WaitStatus enum
7. `Color(hex:)` in Theme.swift
8. StatusEntry uses `let` properties
9. No `@Attribute(.unique)` on id

### Next Steps
1. Open Xcode, add all new files to targets
2. Build (Cmd+B) and fix any compile errors
3. Run tests (Cmd+U) and verify all 70 pass
4. Verify previews render for components

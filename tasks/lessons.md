# Awaitr — Lessons Learned

Track patterns and corrections to prevent repeated mistakes.

---

## Patterns

### SwiftData
- `@Query` only works in SwiftUI Views, NOT in `@Observable` classes — pass query results to ViewModel methods as parameters
- `StatusEntry` must be a `Codable` struct, NOT a `@Model` — stored as JSON array in WaitItem
- `SortDescriptor` sorts enums by raw `String` value alphabetically — sort by `sortOrder` in-memory in ViewModel instead
- `#Predicate` with enums: compare `.rawValue` strings, not enum values directly
- Always update `updatedAt = .now` before saves

### iOS 26 Liquid Glass
- `.glassEffect()` must come BEFORE `.background()` — reversed order blocks glass material
- `.glassEffect()` only renders in Simulator with Xcode 26+ — invisible in canvas previews
- TabView with `.tabViewStyle(.automatic)` gets glass automatically — no manual glass needed
- `matchedGeometryEffect` requires source AND destination in view hierarchy simultaneously

### SwiftUI
- Max 50 lines per `var body` — extract subviews to avoid "compiler unable to type-check" errors
- `@State` properties must be `private`
- Use `.task {}` for async, never `onAppear` with `Task {}`
- Spring animations only (never `.default` or `.linear`)

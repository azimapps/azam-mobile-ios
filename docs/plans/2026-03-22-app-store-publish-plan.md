# App Store Publish Readiness — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add app icon preview, 4-screen interactive onboarding, and AccentColor to make Awaitr App Store ready.

**Architecture:** Onboarding is a full-screen cover gated by `@AppStorage("hasSeenOnboarding")` in `AwaitrApp.swift`. It uses a paged `TabView` with 4 screens. The last screen embeds a mini-form that creates a real `WaitItem` via `ModelContext`. App icon is a SwiftUI view for design reference/screenshot.

**Tech Stack:** SwiftUI, SwiftData, `@AppStorage`, `TabView(.page)`, existing `Theme` tokens, `GlassCard`, `CategoryPickerView`.

---

## Task 1: Configure AccentColor

**Files:**
- Modify: `Awaitr/Assets.xcassets/AccentColor.colorset/Contents.json`

**Step 1: Update AccentColor.colorset to Violet (#6C63FF)**

Replace `Awaitr/Assets.xcassets/AccentColor.colorset/Contents.json` with:

```json
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "red" : "0.424",
          "green" : "0.388",
          "blue" : "1.000",
          "alpha" : "1.000"
        }
      },
      "idiom" : "universal"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "dark"
        }
      ],
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "red" : "0.424",
          "green" : "0.388",
          "blue" : "1.000",
          "alpha" : "1.000"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

**Step 2: Commit**

```bash
git add Awaitr/Assets.xcassets/AccentColor.colorset/Contents.json
git commit -m "style: set AccentColor to Violet (#6C63FF) for branded launch screen"
```

---

## Task 2: Create App Icon Preview View

**Files:**
- Create: `Awaitr/Views/Components/AppIconView.swift`

**Step 1: Create the SwiftUI icon preview**

Create `Awaitr/Views/Components/AppIconView.swift`:

```swift
//
//  AppIconView.swift
//  Awaitr
//

import SwiftUI

struct AppIconView: View {
    var size: CGFloat = 200

    var body: some View {
        ZStack {
            background
            letterA
            glassHighlight
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
    }

    // MARK: - Background Gradient

    private var background: some View {
        LinearGradient(
            colors: [
                Theme.CategoryColors.job,
                Theme.CategoryColors.product,
                Theme.CategoryColors.event,
                Theme.CategoryColors.admin
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Letter A

    private var letterA: some View {
        Text("A")
            .font(.system(size: size * 0.55, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.2), radius: size * 0.02, y: size * 0.01)
    }

    // MARK: - Glass Highlight

    private var glassHighlight: some View {
        Ellipse()
            .fill(
                LinearGradient(
                    colors: [.white.opacity(0.35), .white.opacity(0)],
                    startPoint: .top,
                    endPoint: .center
                )
            )
            .frame(width: size * 0.9, height: size * 0.5)
            .offset(y: -size * 0.2)
    }
}

#Preview {
    VStack(spacing: 24) {
        AppIconView(size: 256)
        AppIconView(size: 60)
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
```

**Step 2: Build and verify preview renders**

Open Xcode, navigate to `AppIconView.swift`, confirm the preview shows a rounded-"A" icon with gradient background.

**Step 3: Commit**

```bash
git add Awaitr/Views/Components/AppIconView.swift
git commit -m "feat: add AppIconView SwiftUI preview for app icon design"
```

---

## Task 3: Create OnboardingPageView (Reusable Template)

**Files:**
- Create: `Awaitr/Views/Onboarding/OnboardingPageView.swift`

**Step 1: Create the reusable page template**

Create directory `Awaitr/Views/Onboarding/` then create `OnboardingPageView.swift`:

```swift
//
//  OnboardingPageView.swift
//  Awaitr
//

import SwiftUI

struct OnboardingPageView<Content: View>: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
            contentArea
            textArea
            Spacer()
            Spacer()
        }
        .padding(.horizontal, Theme.Spacing.xl)
    }

    // MARK: - Content Area

    private var contentArea: some View {
        content()
    }

    // MARK: - Text Area

    private var textArea: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Text(title)
                .font(Theme.Typography.pageTitle)
                .foregroundStyle(Theme.TextColors.dark)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.TextColors.muted)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    OnboardingPageView(
        title: "Welcome to Awaitr",
        subtitle: "Your personal waitlist manager"
    ) {
        Image(systemName: "hourglass")
            .font(.system(size: 80))
            .foregroundStyle(Theme.CategoryColors.job)
    }
}
```

**Step 2: Build to verify no errors**

**Step 3: Commit**

```bash
git add Awaitr/Views/Onboarding/OnboardingPageView.swift
git commit -m "feat: add OnboardingPageView reusable template"
```

---

## Task 4: Create OnboardingView (Main 4-Screen Flow)

**Files:**
- Create: `Awaitr/Views/Onboarding/OnboardingView.swift`

This is the main onboarding container with all 4 screens. It uses `TabView` with page style.

**Step 1: Create OnboardingView**

Create `Awaitr/Views/Onboarding/OnboardingView.swift`:

```swift
//
//  OnboardingView.swift
//  Awaitr
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @Environment(\.modelContext) private var modelContext
    @State private var currentPage = 0
    @State private var itemTitle = ""
    @State private var selectedCategory: WaitCategory = .job

    var body: some View {
        ZStack {
            backgroundGradient
            VStack(spacing: 0) {
                skipButton
                pageContent
                bottomSection
            }
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Theme.CategoryColors.job.opacity(0.08),
                Theme.CategoryColors.product.opacity(0.05),
                .white
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // MARK: - Skip Button

    private var skipButton: some View {
        HStack {
            Spacer()
            Button("Skip") {
                completeOnboarding()
            }
            .font(.system(.body, design: .rounded).weight(.medium))
            .foregroundStyle(Theme.TextColors.muted)
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.top, Theme.Spacing.sm)
        }
    }

    // MARK: - Page Content

    private var pageContent: some View {
        TabView(selection: $currentPage) {
            welcomePage.tag(0)
            categoriesPage.tag(1)
            pipelinePage.tag(2)
            createItemPage.tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .animation(Theme.Animations.springMedium, value: currentPage)
    }

    // MARK: - Bottom Section

    private var bottomSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            if currentPage < 3 {
                nextButton
            } else {
                createButton
                skipCreateLink
            }
        }
        .padding(.horizontal, Theme.Spacing.xl)
        .padding(.bottom, Theme.Spacing.xxl)
    }

    // MARK: - Buttons

    private var nextButton: some View {
        Button {
            withAnimation(Theme.Animations.springMedium) {
                currentPage += 1
            }
        } label: {
            Text(currentPage == 0 ? "Get Started" : "Next")
                .font(.system(.body, design: .rounded).weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Theme.CategoryColors.job, in: RoundedRectangle(cornerRadius: Theme.Radii.md))
        }
    }

    private var createButton: some View {
        Button {
            createFirstItem()
        } label: {
            Text("Create & Start")
                .font(.system(.body, design: .rounded).weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    isCreateValid ? Theme.CategoryColors.job : Theme.TextColors.muted,
                    in: RoundedRectangle(cornerRadius: Theme.Radii.md)
                )
        }
        .disabled(!isCreateValid)
    }

    private var skipCreateLink: some View {
        Button("Skip for Now") {
            completeOnboarding()
        }
        .font(.system(.footnote, design: .rounded).weight(.medium))
        .foregroundStyle(Theme.TextColors.muted)
    }

    // MARK: - Validation

    private var isCreateValid: Bool {
        WaitItem.validateTitle(itemTitle)
    }
}

// MARK: - Pages

extension OnboardingView {

    private var welcomePage: some View {
        OnboardingPageView(
            title: "Welcome to Awaitr",
            subtitle: "Your personal waitlist manager"
        ) {
            AppIconView(size: 140)
                .shadow(color: Theme.CategoryColors.job.opacity(0.3), radius: 20, y: 10)
        }
    }

    private var categoriesPage: some View {
        OnboardingPageView(
            title: "Track Everything",
            subtitle: "Jobs, products, admin docs, and events — all in one place"
        ) {
            categoriesGrid
        }
    }

    private var categoriesGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
            spacing: 12
        ) {
            ForEach(WaitCategory.allCases) { category in
                GlassCard(category: category) {
                    VStack(spacing: 6) {
                        Text(category.emoji)
                            .font(.system(size: 28))
                        Text(category.label)
                            .font(.system(.caption, design: .rounded).weight(.semibold))
                            .foregroundStyle(Theme.TextColors.dark)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.sm)
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
    }

    private var pipelinePage: some View {
        OnboardingPageView(
            title: "See Your Progress",
            subtitle: "Every wait follows a clear pipeline from start to finish"
        ) {
            pipelineDemo
        }
    }

    private var pipelineDemo: some View {
        GlassCard {
            VStack(spacing: Theme.Spacing.lg) {
                HStack(spacing: 0) {
                    ForEach(Array(WaitStatus.allCases.enumerated()), id: \.element) { index, status in
                        pipelineDot(status: status, index: index)
                        if index < WaitStatus.allCases.count - 1 {
                            pipelineConnector(filled: index < 2)
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.sm)

                HStack {
                    ForEach(WaitStatus.allCases) { status in
                        Text(status.shortLabel)
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.TextColors.muted)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
    }

    private func pipelineDot(status: WaitStatus, index: Int) -> some View {
        Circle()
            .fill(index <= 2 ? Theme.CategoryColors.job : Theme.TextColors.muted.opacity(0.3))
            .frame(width: 14, height: 14)
            .overlay {
                if index <= 2 {
                    Circle()
                        .fill(.white)
                        .frame(width: 6, height: 6)
                }
            }
    }

    private func pipelineConnector(filled: Bool) -> some View {
        Rectangle()
            .fill(filled ? Theme.CategoryColors.job : Theme.TextColors.muted.opacity(0.3))
            .frame(height: 3)
            .frame(maxWidth: .infinity)
    }

    private var createItemPage: some View {
        OnboardingPageView(
            title: "Add Your First Wait",
            subtitle: "What are you waiting for right now?"
        ) {
            createForm
        }
    }

    private var createForm: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Title")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.TextColors.muted)
                    TextField("e.g. Google internship application", text: $itemTitle)
                        .font(Theme.Typography.body)
                        .textFieldStyle(.plain)
                        .padding(Theme.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.Radii.sm)
                                .fill(.white.opacity(0.5))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Radii.sm)
                                .stroke(Color.black.opacity(0.06), lineWidth: 1)
                        )
                        .onChange(of: itemTitle) { _, newValue in
                            if newValue.count > 80 {
                                itemTitle = String(newValue.prefix(80))
                            }
                        }
                }

                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text("Category")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.TextColors.muted)
                    CategoryPickerView(selectedCategory: $selectedCategory)
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
    }
}

// MARK: - Actions

extension OnboardingView {

    private func createFirstItem() {
        guard isCreateValid else { return }
        let trimmedTitle = itemTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let item = WaitItem(
            title: trimmedTitle,
            category: selectedCategory
        )
        modelContext.insert(item)
        completeOnboarding()
    }

    private func completeOnboarding() {
        withAnimation(Theme.Animations.springMedium) {
            hasSeenOnboarding = true
        }
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: WaitItem.self, inMemory: true)
}
```

**Step 2: Build and verify all 4 pages render in preview**

**Step 3: Commit**

```bash
git add Awaitr/Views/Onboarding/OnboardingView.swift
git commit -m "feat: add 4-screen interactive onboarding flow"
```

---

## Task 5: Wire Onboarding into AwaitrApp

**Files:**
- Modify: `Awaitr/AwaitrApp.swift:13-40`

**Step 1: Add `@AppStorage` and `.fullScreenCover` to AwaitrApp**

In `Awaitr/AwaitrApp.swift`, modify the `AwaitrApp` struct to add onboarding gate:

```swift
@main
struct AwaitrApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            WaitItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    private let notificationDelegate = NotificationDelegate()

    init() {
        NotificationService.registerCategories()
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .fullScreenCover(isPresented: .constant(!hasSeenOnboarding)) {
                    OnboardingView()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
```

Changes:
- Add `@AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false` after struct declaration
- Add `.fullScreenCover(isPresented: .constant(!hasSeenOnboarding))` to `ContentView()`

**Step 2: Build and run in simulator**

- First launch should show onboarding
- Complete onboarding → should show main TabView
- Kill and relaunch → should go directly to TabView (skips onboarding)

**Step 3: Commit**

```bash
git add Awaitr/AwaitrApp.swift
git commit -m "feat: wire onboarding flow into app entry point"
```

---

## Task 6: Add WaitStatus.shortLabel (if missing)

**Files:**
- Check: `Awaitr/Models/WaitStatus.swift`

**Step 1: Check if `shortLabel` exists on WaitStatus**

Read `Awaitr/Models/WaitStatus.swift` and check for a `shortLabel` property. The pipeline demo in onboarding references `status.shortLabel`.

If it exists, skip this task entirely.

If it does NOT exist, add:

```swift
var shortLabel: String {
    switch self {
    case .submitted: "Sent"
    case .inReview: "Review"
    case .awaiting: "Pending"
    case .accepted: "Won"
    case .rejected: "Lost"
    }
}
```

**Step 2: Build to verify no errors**

**Step 3: Commit (only if change was needed)**

```bash
git add Awaitr/Models/WaitStatus.swift
git commit -m "feat: add shortLabel to WaitStatus for pipeline display"
```

---

## Task 7: Final Verification & Cleanup

**Step 1: Build the full project**

Verify zero errors, zero warnings.

**Step 2: Test onboarding flow end-to-end**

1. Reset `hasSeenOnboarding` by deleting app from simulator
2. Launch → see Welcome page
3. Swipe through all 4 pages
4. On page 4, type a title and pick a category
5. Tap "Create & Start"
6. Verify item appears on Dashboard
7. Kill and relaunch → verify onboarding does NOT appear again

**Step 3: Test skip flows**

1. Reset app again
2. Launch → tap "Skip" button → verify goes to Dashboard with no items
3. Reset again → swipe to page 4 → tap "Skip for Now" → verify same

**Step 4: Verify AccentColor**

Check that the launch screen uses Violet tint.

**Step 5: Commit any fixes**

```bash
git commit -m "fix: address onboarding verification issues"
```

---

## Summary of Files

| Action | File |
|---|---|
| Modify | `Awaitr/Assets.xcassets/AccentColor.colorset/Contents.json` |
| Create | `Awaitr/Views/Components/AppIconView.swift` |
| Create | `Awaitr/Views/Onboarding/OnboardingPageView.swift` |
| Create | `Awaitr/Views/Onboarding/OnboardingView.swift` |
| Modify | `Awaitr/AwaitrApp.swift` |
| Maybe modify | `Awaitr/Models/WaitStatus.swift` (add `shortLabel` if missing) |

## Commit Sequence

1. `style: set AccentColor to Violet (#6C63FF) for branded launch screen`
2. `feat: add AppIconView SwiftUI preview for app icon design`
3. `feat: add OnboardingPageView reusable template`
4. `feat: add 4-screen interactive onboarding flow`
5. `feat: wire onboarding flow into app entry point`
6. `feat: add shortLabel to WaitStatus for pipeline display` (if needed)
7. `fix: address onboarding verification issues` (if needed)

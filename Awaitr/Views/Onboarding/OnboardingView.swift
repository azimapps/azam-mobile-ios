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
    @State private var animatePipeline = false

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
        .onAppear {
            animatePipeline = false
            withAnimation(Theme.Animations.springGentle.delay(0.3)) {
                animatePipeline = true
            }
        }
    }

    private var pipelineDemo: some View {
        GlassCard {
            VStack(spacing: Theme.Spacing.lg) {
                HStack(spacing: 0) {
                    ForEach(Array(WaitStatus.allCases.enumerated()), id: \.element) { index, status in
                        pipelineDot(index: index)
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

    private func pipelineDot(index: Int) -> some View {
        let isActive = animatePipeline && index <= 2
        return Circle()
            .fill(isActive ? Theme.CategoryColors.job : Theme.TextColors.muted.opacity(0.3))
            .frame(width: 14, height: 14)
            .overlay {
                if isActive {
                    Circle()
                        .fill(.white)
                        .frame(width: 6, height: 6)
                }
            }
            .scaleEffect(isActive ? 1.0 : 0.6)
            .animation(Theme.Animations.springMedium.delay(Double(index) * 0.15), value: animatePipeline)
    }

    private func pipelineConnector(filled: Bool) -> some View {
        let isActive = animatePipeline && filled
        return Rectangle()
            .fill(isActive ? Theme.CategoryColors.job : Theme.TextColors.muted.opacity(0.3))
            .frame(height: 3)
            .frame(maxWidth: .infinity)
            .animation(Theme.Animations.springMedium.delay(0.2), value: animatePipeline)
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

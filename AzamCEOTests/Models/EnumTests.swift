//
//  EnumTests.swift
//  AzamCEOTests
//

import Testing
@testable import AzamCEO

struct EnumTests {

    // MARK: - WaitCategory

    @Test func categoryHasFourCases() {
        #expect(WaitCategory.allCases.count == 4)
    }

    @Test func categoryShortLabels() {
        #expect(WaitCategory.job.shortLabel == "Job")
        #expect(WaitCategory.product.shortLabel == "Product")
        #expect(WaitCategory.admin.shortLabel == "Admin")
        #expect(WaitCategory.event.shortLabel == "Event")
    }

    @Test func categoryHasEmoji() {
        for cat in WaitCategory.allCases {
            #expect(!cat.emoji.isEmpty)
        }
    }

    @Test func categoryHasSystemImage() {
        for cat in WaitCategory.allCases {
            #expect(!cat.systemImage.isEmpty)
        }
    }

    @Test func categoryHasHexColor() {
        #expect(WaitCategory.job.hexColor == "6C63FF")
        #expect(WaitCategory.product.hexColor == "E24B4A")
        #expect(WaitCategory.admin.hexColor == "BA7517")
        #expect(WaitCategory.event.hexColor == "3B6D11")
    }

    // MARK: - WaitStatus

    @Test func statusHasFiveCases() {
        #expect(WaitStatus.allCases.count == 5)
    }

    @Test func statusTerminalDetection() {
        #expect(!WaitStatus.pending.isTerminal)
        #expect(!WaitStatus.active.isTerminal)
        #expect(!WaitStatus.finalReview.isTerminal)
        #expect(WaitStatus.positive.isTerminal)
        #expect(WaitStatus.negative.isTerminal)
    }

    @Test func statusPositiveNegative() {
        #expect(WaitStatus.positive.isPositive)
        #expect(!WaitStatus.positive.isNegative)
        #expect(WaitStatus.negative.isNegative)
        #expect(!WaitStatus.negative.isPositive)
    }

    // MARK: - PipelineTemplate

    @Test func templateHasEightCases() {
        #expect(PipelineTemplate.allCases.count == 8)
    }

    @Test func templateCategoryMapping() {
        #expect(PipelineTemplate.jobApplication.category == .job)
        #expect(PipelineTemplate.scholarship.category == .job)
        #expect(PipelineTemplate.preOrder.category == .product)
        #expect(PipelineTemplate.productWaitlist.category == .product)
        #expect(PipelineTemplate.document.category == .admin)
        #expect(PipelineTemplate.permit.category == .admin)
        #expect(PipelineTemplate.eventRegistration.category == .event)
        #expect(PipelineTemplate.eventWaitlist.category == .event)
    }

    @Test func templateStageCount() {
        #expect(PipelineTemplate.jobApplication.stages.count == 3)
        #expect(PipelineTemplate.scholarship.stages.count == 2)
        #expect(PipelineTemplate.preOrder.stages.count == 3)
        #expect(PipelineTemplate.productWaitlist.stages.count == 2)
        #expect(PipelineTemplate.document.stages.count == 2)
        #expect(PipelineTemplate.permit.stages.count == 3)
        #expect(PipelineTemplate.eventRegistration.stages.count == 1)
        #expect(PipelineTemplate.eventWaitlist.stages.count == 2)
    }

    @Test func templateNextStatus() {
        let job = PipelineTemplate.jobApplication
        #expect(job.nextStatus(after: .pending) == .active)
        #expect(job.nextStatus(after: .active) == .finalReview)
        #expect(job.nextStatus(after: .finalReview) == nil)

        let doc = PipelineTemplate.document
        #expect(doc.nextStatus(after: .pending) == .active)
        #expect(doc.nextStatus(after: .active) == nil)

        let reg = PipelineTemplate.eventRegistration
        #expect(reg.nextStatus(after: .pending) == nil)
    }

    @Test func templateValidTransitions() {
        let job = PipelineTemplate.jobApplication
        #expect(job.validTransitions(from: .pending) == [.active, .positive, .negative])
        #expect(job.validTransitions(from: .active) == [.finalReview, .positive, .negative])
        #expect(job.validTransitions(from: .finalReview) == [.positive, .negative])
        #expect(job.validTransitions(from: .positive).isEmpty)
        #expect(job.validTransitions(from: .negative).isEmpty)

        let reg = PipelineTemplate.eventRegistration
        #expect(reg.validTransitions(from: .pending) == [.positive, .negative])
    }

    @Test func templatePipelineIndex() {
        let job = PipelineTemplate.jobApplication
        #expect(job.pipelineIndex(of: .pending) == 0)
        #expect(job.pipelineIndex(of: .active) == 1)
        #expect(job.pipelineIndex(of: .finalReview) == 2)
        #expect(job.pipelineIndex(of: .positive) == nil)
        #expect(job.pipelineIndex(of: .negative) == nil)
    }

    @Test func templateLabelsNotEmpty() {
        for tmpl in PipelineTemplate.allCases {
            for status in WaitStatus.allCases {
                #expect(!tmpl.label(for: status).isEmpty)
                #expect(!tmpl.shortLabel(for: status).isEmpty)
                #expect(!tmpl.systemImage(for: status).isEmpty)
            }
        }
    }

    @Test func templateFactoryReturnsCorrectTemplates() {
        #expect(PipelineTemplate.templates(for: .job) == [.jobApplication, .scholarship])
        #expect(PipelineTemplate.templates(for: .product) == [.preOrder, .productWaitlist])
        #expect(PipelineTemplate.templates(for: .admin) == [.document, .permit])
        #expect(PipelineTemplate.templates(for: .event) == [.eventRegistration, .eventWaitlist])
    }

    @Test func templateDefaultIsFirstForCategory() {
        #expect(PipelineTemplate.defaultTemplate(for: .job) == .jobApplication)
        #expect(PipelineTemplate.defaultTemplate(for: .product) == .preOrder)
        #expect(PipelineTemplate.defaultTemplate(for: .admin) == .document)
        #expect(PipelineTemplate.defaultTemplate(for: .event) == .eventRegistration)
    }

    // MARK: - WaitPriority

    @Test func priorityHasThreeCases() {
        #expect(WaitPriority.allCases.count == 3)
    }

    @Test func prioritySortOrder() {
        #expect(WaitPriority.high.sortOrder == 0)
        #expect(WaitPriority.medium.sortOrder == 1)
        #expect(WaitPriority.low.sortOrder == 2)
    }

    @Test func priorityHexColors() {
        #expect(WaitPriority.high.hexColor == "E24B4A")
        #expect(WaitPriority.medium.hexColor == "EF9F27")
        #expect(WaitPriority.low.hexColor == "97C459")
    }
}

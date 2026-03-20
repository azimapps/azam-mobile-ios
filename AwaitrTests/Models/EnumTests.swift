//
//  EnumTests.swift
//  AwaitrTests
//

import Testing
@testable import Awaitr

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

    @Test func statusPipelineStages() {
        #expect(WaitStatus.pipelineStages.count == 3)
        #expect(WaitStatus.pipelineStages == [.submitted, .inReview, .awaiting])
    }

    @Test func statusTerminalDetection() {
        #expect(!WaitStatus.submitted.isTerminal)
        #expect(!WaitStatus.inReview.isTerminal)
        #expect(!WaitStatus.awaiting.isTerminal)
        #expect(WaitStatus.accepted.isTerminal)
        #expect(WaitStatus.rejected.isTerminal)
    }

    @Test func statusPipelineIndex() {
        #expect(WaitStatus.submitted.pipelineIndex == 0)
        #expect(WaitStatus.inReview.pipelineIndex == 1)
        #expect(WaitStatus.awaiting.pipelineIndex == 2)
        #expect(WaitStatus.accepted.pipelineIndex == nil)
        #expect(WaitStatus.rejected.pipelineIndex == nil)
    }

    @Test func statusNextStatus() {
        #expect(WaitStatus.submitted.nextStatus == .inReview)
        #expect(WaitStatus.inReview.nextStatus == .awaiting)
        #expect(WaitStatus.awaiting.nextStatus == nil)
        #expect(WaitStatus.accepted.nextStatus == nil)
        #expect(WaitStatus.rejected.nextStatus == nil)
    }

    @Test func statusValidTransitions() {
        #expect(WaitStatus.submitted.validTransitions == [.inReview, .accepted, .rejected])
        #expect(WaitStatus.inReview.validTransitions == [.awaiting, .accepted, .rejected])
        #expect(WaitStatus.awaiting.validTransitions == [.accepted, .rejected])
        #expect(WaitStatus.accepted.validTransitions.isEmpty)
        #expect(WaitStatus.rejected.validTransitions.isEmpty)
    }

    @Test func statusLabelsNotEmpty() {
        for status in WaitStatus.allCases {
            #expect(!status.label.isEmpty)
            #expect(!status.shortLabel.isEmpty)
            #expect(!status.systemImage.isEmpty)
        }
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

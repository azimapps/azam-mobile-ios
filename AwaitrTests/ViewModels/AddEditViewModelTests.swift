//
//  AddEditViewModelTests.swift
//  AwaitrTests
//

import Testing
import Foundation
import SwiftData
@testable import Awaitr

@MainActor
struct AddEditViewModelTests {

    private func makeCreateVM() throws -> AddEditViewModel {
        let container = try TestContainer.make()
        return AddEditViewModel(modelContext: container.mainContext)
    }

    private func makeEditVM(item: WaitItem) throws -> AddEditViewModel {
        let container = try TestContainer.make()
        return AddEditViewModel(item: item, modelContext: container.mainContext)
    }

    // MARK: - Create Mode

    @Test func createModeNotEditing() throws {
        let vm = try makeCreateVM()
        #expect(!vm.isEditing)
    }

    @Test func createModeInvalidWhenEmpty() throws {
        let vm = try makeCreateVM()
        #expect(!vm.isValid)
    }

    @Test func createModeValidWithTitle() throws {
        let vm = try makeCreateVM()
        vm.title = "Valid Title"
        #expect(vm.isValid)
    }

    @Test func createModeInvalidWithLongTitle() throws {
        let vm = try makeCreateVM()
        vm.title = String(repeating: "a", count: 81)
        #expect(!vm.isValid)
    }

    @Test func createModeInvalidWithLongNotes() throws {
        let vm = try makeCreateVM()
        vm.title = "Valid"
        vm.notes = String(repeating: "a", count: 501)
        #expect(!vm.isValid)
    }

    @Test func createModeAlwaysHasChanges() throws {
        let vm = try makeCreateVM()
        #expect(vm.hasChanges)
    }

    // MARK: - Edit Mode

    @Test func editModeIsEditing() throws {
        let item = WaitItemFactory.make(title: "Original")
        let vm = try makeEditVM(item: item)
        #expect(vm.isEditing)
    }

    @Test func editModePreFillsFields() throws {
        let item = WaitItemFactory.make(
            title: "Test Item",
            category: .admin,
            priority: .high,
            notes: "Some notes"
        )
        let vm = try makeEditVM(item: item)
        #expect(vm.title == "Test Item")
        #expect(vm.category == .admin)
        #expect(vm.priority == .high)
        #expect(vm.notes == "Some notes")
    }

    @Test func editModeNoChangesInitially() throws {
        let item = WaitItemFactory.make(title: "Test")
        let vm = try makeEditVM(item: item)
        #expect(!vm.hasChanges)
    }

    @Test func editModeDetectsChanges() throws {
        let item = WaitItemFactory.make(title: "Test")
        let vm = try makeEditVM(item: item)
        vm.title = "Modified"
        #expect(vm.hasChanges)
    }

    // MARK: - Character Counts

    @Test func characterCounts() throws {
        let vm = try makeCreateVM()
        vm.title = "Hello"
        vm.notes = "World!"
        #expect(vm.titleCharacterCount == 5)
        #expect(vm.notesCharacterCount == 6)
    }
}

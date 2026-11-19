import XCTest
@testable import BeeKeeper

@MainActor
final class GameStoreTests: XCTestCase {
    func testGameManagerBindsLoadedAccountChanges() throws {
        let manager = GameManager.shared
        let originalAccount = manager.account
        let originalHandler = manager.onChange
        defer {
            try? manager.changeAccount(to: originalAccount)
            manager.onChange = originalHandler
        }

        let account = Account()
        try manager.changeAccount(to: account)
        var signals = 0
        manager.onChange = { signals += 1 }
        account.name = "Bound Account"
        XCTAssertEqual(signals, 1)
        account.apiaries[0].bees[0].setNickname("Bound Bee")
        XCTAssertEqual(signals, 2)
    }

    func testRemovingActiveAndLastApiaryKeepsRuntimeSavable() async throws {
        let manager = GameManager.shared
        let originalAccount = manager.account
        let originalHandler = manager.onChange
        defer {
            try? manager.changeAccount(to: originalAccount)
            manager.onChange = originalHandler
        }

        let account = Account()
        let second = Apiary()
        account.apiaries.append(second)
        try manager.changeAccount(to: account)
        try manager.changeApiary(second)
        let service = MockGameSaveService()
        let store = GameStore(saveService: service, runtime: LegacyGameRuntime(), debounce: .milliseconds(10))
        try store.start()

        account.apiaries.removeAll { $0 === second }
        let first = account.apiaries[0]
        XCTAssertTrue(manager.apiary === first)
        try await waitForSavedState(service) {
            $0.activeApiaryID == first.id && $0.account.apiaries.count == 1
        }

        account.apiaries.removeAll()
        let replacement = account.apiaries[0]
        XCTAssertTrue(manager.apiary === replacement)
        try await waitForSavedState(service) {
            $0.activeApiaryID == replacement.id && $0.account.apiaries.count == 1
        }
    }

    func testForeignApiarySelectionAndBeeAssignmentAreRejected() throws {
        let manager = GameManager.shared
        let originalAccount = manager.account
        let originalHandler = manager.onChange
        defer {
            try? manager.changeAccount(to: originalAccount)
            manager.onChange = originalHandler
        }

        let account = Account()
        try manager.changeAccount(to: account)
        let foreign = Apiary()
        let selected = manager.apiary
        XCTAssertThrowsError(try manager.changeApiary(foreign)) { error in
            guard case GameManagerError.unknownApiary = error else {
                return XCTFail("Expected unknown apiary")
            }
        }
        XCTAssertTrue(manager.apiary === selected)

        let bee = try XCTUnwrap(selected.bees.first)
        let foreignHive = try XCTUnwrap(foreign.structures.compactMap { $0 as? Hive }.first)
        let originalAssignment = bee.producerAssignmentId
        XCTAssertThrowsError(try bee.assign(to: foreignHive)) { error in
            guard case ApiaryError.foreignAssignment = error else {
                return XCTFail("Expected foreign assignment")
            }
        }
        XCTAssertEqual(bee.producerAssignmentId, originalAssignment)
        XCTAssertNoThrow(try LegacyStateAdapter.snapshot(
            account: account,
            activeApiaryID: selected.id,
            isTutorialComplete: true
        ))
    }

    func testInvalidAssignmentCannotReplaceReadableSave() async throws {
        let id = UUID().uuidString
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(id, isDirectory: true)
        let defaults = UserDefaults(suiteName: "BeeKeeper.InvalidAssignment.\(id)")!
        defer {
            try? FileManager.default.removeItem(at: directory)
            defaults.removePersistentDomain(forName: "BeeKeeper.InvalidAssignment.\(id)")
        }
        let account = Account()
        let apiary = try XCTUnwrap(account.apiaries.first)
        let service = LocalGameSaveService(directoryURL: directory, defaults: defaults)
        let valid = try LegacyStateAdapter.snapshot(account: account, activeApiaryID: apiary.id, isTutorialComplete: true)
        try await service.saveSnapshot(valid, account: account)

        let bee = try XCTUnwrap(apiary.bees.first)
        bee.producerAssignmentId = UUID()
        XCTAssertThrowsError(try LegacyStateAdapter.snapshot(
            account: account,
            activeApiaryID: apiary.id,
            isTutorialComplete: true
        )) { error in
            guard case LegacyStateAdapterError.invalidBeeAssignment = error else {
                return XCTFail("Expected invalid bee assignment")
            }
        }
        do {
            try await service.saveSnapshot(valid, account: account)
            XCTFail("Expected invalid assignment to block the write")
        } catch LegacyStateAdapterError.invalidBeeAssignment {
        }
        let reopened = try await service.loadAccount()
        XCTAssertEqual(reopened.apiaries.first?.bees.first?.producerAssignmentId, valid.activeApiary?.bees.first?.assignedStructureID)
        let savedAfterInvalidID = try await service.loadSnapshot()
        XCTAssertEqual(savedAfterInvalidID, valid)

        bee.producerAssignmentId = valid.activeApiary?.bees.first?.assignedStructureID
        let flower = try XCTUnwrap(apiary.structures.compactMap { $0 as? Flower }.first)
        flower.maximumAssignedBees = 0
        XCTAssertThrowsError(try LegacyStateAdapter.snapshot(
            account: account,
            activeApiaryID: apiary.id,
            isTutorialComplete: true
        )) { error in
            guard case LegacyStateAdapterError.assignmentCapacityExceeded = error else {
                return XCTFail("Expected assignment capacity error")
            }
        }
        do {
            try await service.saveSnapshot(valid, account: account)
            XCTFail("Expected invalid capacity to block the write")
        } catch LegacyStateAdapterError.assignmentCapacityExceeded {
        }
        let stillReadable = try await service.loadAccount()
        XCTAssertEqual(stillReadable.apiaries.first?.bees.first?.producerAssignmentId, valid.activeApiary?.bees.first?.assignedStructureID)
        let savedAfterInvalidCapacity = try await service.loadSnapshot()
        XCTAssertEqual(savedAfterInvalidCapacity, valid)
    }

    func testRemovingBeeByNicknameSavesAndUnassigns() async throws {
        let runtime = MockGameRuntime()
        let service = MockGameSaveService()
        let store = GameStore(saveService: service, runtime: runtime, debounce: .milliseconds(10))
        try store.start()

        let bee = try XCTUnwrap(runtime.apiary.bees.first)
        let name = bee.nickname
        XCTAssertTrue(runtime.apiary.removeBee(withName: name) === bee)
        XCTAssertNil(bee.producerAssignmentId)
        try await waitForSavedState(service) { state in
            state.activeApiary?.bees.contains(where: { $0.nickname == name }) == false
        }
    }

    func testCorruptLegacyAssignmentDecodesAsError() throws {
        let apiary = Apiary()
        apiary.bees[0].producerAssignmentId = UUID()
        let data = try JSONEncoder().encode(apiary)
        XCTAssertThrowsError(try JSONDecoder().decode(Apiary.self, from: data)) { error in
            guard case DecodingError.dataCorrupted = error else {
                return XCTFail("Expected data corruption error")
            }
        }
    }

    func testUnknownLegacyWrapperDecodesAsError() throws {
        let data = Data(#"{"type":"unknown","value":{}}"#.utf8)
        XCTAssertThrowsError(try JSONDecoder().decode(Wrapper.self, from: data)) { error in
            guard case DecodingError.dataCorrupted = error else {
                return XCTFail("Expected data corruption error")
            }
        }
    }

    func testFlushWritesMatchingStateAndAccount() async throws {
        let runtime = MockGameRuntime()
        let service = MockGameSaveService()
        let store = GameStore(saveService: service, runtime: runtime)
        try store.start()

        runtime.account.name = "Test Apiary"
        try await store.flush()

        XCTAssertEqual(store.state?.account.name, "Test Apiary")
        XCTAssertEqual(service.savedState?.account.name, "Test Apiary")
        XCTAssertEqual(service.savedAccountName, "Test Apiary")
        XCTAssertEqual(service.savedState?.activeApiaryID, runtime.apiary.id)
    }

    func testAccountMutationWritesWithoutManualSignal() async throws {
        let runtime = MockGameRuntime()
        let service = MockGameSaveService()
        let store = GameStore(saveService: service, runtime: runtime, debounce: .milliseconds(10))
        try store.start()

        runtime.account.name = "Changed Apiary"
        try await waitForSavedState(service) { $0.account.name == "Changed Apiary" }

        XCTAssertEqual(service.savedState?.account.name, "Changed Apiary")
        XCTAssertEqual(service.savedAccountName, "Changed Apiary")
    }

    func testNestedMutationsSaveMatchingSnapshots() async throws {
        let runtime = MockGameRuntime()
        let service = MockGameSaveService()
        let store = GameStore(saveService: service, runtime: runtime, debounce: .milliseconds(10))
        try store.start()

        runtime.account.activeResearch = TimedReward(duration: 60, reward: .furI)
        try await waitForSavedState(service) { $0.account.activeResearch?.reward == GeneID(rawValue: Gene.furI.rawValue) }
        XCTAssertEqual(service.savedState?.account.activeResearch?.reward, GeneID(rawValue: Gene.furI.rawValue))

        let second = Apiary()
        runtime.account.apiaries.append(second)
        try await waitForSavedState(service) { $0.account.apiaries.count == 2 }
        XCTAssertEqual(service.savedState?.account.apiaries.count, 2)

        let bee = second.bees[0]
        bee.setNickname("Nested Bee")
        try await waitForSavedState(service) { $0.account.apiaries[1].bees[0].nickname == "Nested Bee" }
        XCTAssertEqual(service.savedState?.account.apiaries[1].bees[0].nickname, "Nested Bee")

        let hive = second.structures.compactMap { $0 as? Hive }.first!
        try bee.assign(to: hive)
        try await waitForSavedState(service) { $0.account.apiaries[1].bees[0].assignedStructureID == hive.id }
        XCTAssertEqual(service.savedState?.account.apiaries[1].bees[0].assignedStructureID, hive.id)

        hive.area.x += 1
        try await waitForSavedState(service) { state in
            state.account.apiaries[1].structures.first { $0.id == hive.id }?.area.x == hive.area.x
        }
        XCTAssertEqual(service.savedState?.account.apiaries[1].structures.first { $0.id == hive.id }?.area.x, hive.area.x)

        let storage = second.structures.compactMap { $0 as? HoneyStorage }.first!
        storage.containing = Resources(honey: 24)
        try await waitForSavedState(service) { state in
            state.account.apiaries[1].structures.first { $0.id == storage.id }?.contents
                == .storage(StorageState(containing: ResourceState(honey: 24), maximum: ResourceState(honey: 7000)))
        }
        XCTAssertEqual(service.savedState?.account.apiaries[1].structures.first { $0.id == storage.id }?.contents,
            .storage(StorageState(containing: ResourceState(honey: 24), maximum: ResourceState(honey: 7000))))

        second.tickWildBees(1)
        try await waitForSavedState(service) { $0.account.apiaries[1].wildBeeCount == second.wildBees }
        XCTAssertEqual(service.savedState?.account.apiaries[1].wildBeeCount, second.wildBees)
    }

    func testForceCompleteResearchSchedulesSave() async throws {
        #if !RELEASE
        let runtime = MockGameRuntime()
        let service = MockGameSaveService()
        let store = GameStore(saveService: service, runtime: runtime, debounce: .milliseconds(10))
        try store.start()
        runtime.account.activeResearch = TimedReward(duration: 60, reward: .furI)
        try await waitForSavedState(service) { $0.account.activeResearch?.reward == GeneID(rawValue: Gene.furI.rawValue) }

        runtime.account.activeResearch?.forceComplete()
        try await waitForSavedState(service) { ($0.account.activeResearch?.endDate ?? .distantFuture) <= .now }
        XCTAssertTrue((service.savedState?.account.activeResearch?.endDate ?? .distantFuture) <= .now)
        #endif
    }

    func testPendingIncubationBeeRenameSchedulesSave() async throws {
        let runtime = MockGameRuntime()
        let service = MockGameSaveService()
        let store = GameStore(saveService: service, runtime: runtime, debounce: .milliseconds(10))
        try store.start()

        let incubator = try makeIncubatorWithPendingBee()
        incubator.area = DiscreteRect(x: 20, y: 20, width: 4, height: 4)
        try runtime.apiary.addStructure(incubator)
        try await waitForSavedState(service) { $0.activeApiary?.structures.contains { $0.id == incubator.id } == true }

        incubator.currentIncubation?.reward.setNickname("Pending Bee")
        try await waitForSavedState(service) { state in
            guard let structure = state.activeApiary?.structures.first(where: { $0.id == incubator.id }),
                  case .incubator(let job) = structure.contents else { return false }
            return job?.reward.nickname == "Pending Bee"
        }
        let saved = service.savedState?.activeApiary?.structures.first { $0.id == incubator.id }
        guard case .incubator(let job) = saved?.contents else {
            return XCTFail("Expected saved incubation")
        }
        XCTAssertEqual(job?.reward.nickname, "Pending Bee")

        #if !RELEASE
        incubator.currentIncubation?.forceComplete()
        try await waitForSavedState(service) { state in
            guard let structure = state.activeApiary?.structures.first(where: { $0.id == incubator.id }),
                  case .incubator(let job) = structure.contents else { return false }
            return (job?.endDate ?? .distantFuture) <= .now
        }
        let completed = service.savedState?.activeApiary?.structures.first { $0.id == incubator.id }
        guard case .incubator(let completedJob) = completed?.contents else {
            return XCTFail("Expected completed incubation")
        }
        XCTAssertTrue((completedJob?.endDate ?? .distantFuture) <= .now)
        #endif
    }

    func testPendingHoneycombAndTimedJobChangesSave() async throws {
        let runtime = MockGameRuntime()
        let service = MockGameSaveService()
        let store = GameStore(saveService: service, runtime: runtime, debounce: .milliseconds(10))
        try store.start()

        let hive = try makeHiveWithPendingHoneycomb()
        hive.area = DiscreteRect(x: 10, y: 10, width: 2, height: 2)
        try runtime.apiary.addStructure(hive)
        try await waitForSavedState(service) { $0.activeApiary?.structures.contains { $0.id == hive.id } == true }

        hive.currentConstruction?.reward.containing = Resources(honey: 8)
        try await waitForSavedState(service) { state in
            guard let structure = state.activeApiary?.structures.first(where: { $0.id == hive.id }),
                  case .hive(let hiveState) = structure.contents else { return false }
            return hiveState.currentConstruction?.reward.storage.containing.honey == 8
        }
        let saved = service.savedState?.activeApiary?.structures.first { $0.id == hive.id }
        guard case .hive(let hiveState) = saved?.contents else {
            return XCTFail("Expected saved hive")
        }
        XCTAssertEqual(hiveState.currentConstruction?.reward.storage.containing.honey, 8)

        #if !RELEASE
        hive.currentConstruction?.forceComplete()
        try await waitForSavedState(service) { state in
            guard let structure = state.activeApiary?.structures.first(where: { $0.id == hive.id }),
                  case .hive(let hiveState) = structure.contents else { return false }
            return (hiveState.currentConstruction?.endDate ?? .distantFuture) <= .now
        }
        let completed = service.savedState?.activeApiary?.structures.first { $0.id == hive.id }
        guard case .hive(let completedHive) = completed?.contents else {
            return XCTFail("Expected completed hive construction")
        }
        XCTAssertTrue((completedHive.currentConstruction?.endDate ?? .distantFuture) <= .now)
        #endif
    }

    func testModelChangePersistsToDiskAndReloads() async throws {
        let id = UUID().uuidString
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(id, isDirectory: true)
        let defaults = UserDefaults(suiteName: "BeeKeeper.GameStoreTests.\(id)")!
        defer {
            try? FileManager.default.removeItem(at: directory)
            defaults.removePersistentDomain(forName: "BeeKeeper.GameStoreTests.\(id)")
        }

        let runtime = MockGameRuntime()
        let service = LocalGameSaveService(directoryURL: directory, defaults: defaults)
        let store = GameStore(saveService: service, runtime: runtime, debounce: .milliseconds(10))
        try store.start()
        runtime.account.activeResearch = TimedReward(duration: 60, reward: .furI)
        runtime.apiary.bees[0].setNickname("Disk Bee")

        var loaded: GameState?
        for _ in 0..<100 {
            loaded = try await service.loadSnapshot()
            if loaded?.activeApiary?.bees[0].nickname == "Disk Bee" { break }
            try await Task.sleep(for: .milliseconds(10))
        }
        let reopened = LocalGameSaveService(directoryURL: directory, defaults: defaults)
        let account = try await reopened.loadAccount()
        XCTAssertEqual(account.apiaries[0].bees[0].nickname, "Disk Bee")
        XCTAssertEqual(account.activeResearch?.reward, .furI)
        XCTAssertEqual(loaded?.account.activeResearch?.reward, GeneID(rawValue: Gene.furI.rawValue))
        XCTAssertEqual(loaded?.account.id, account.id)

        let flower = runtime.apiary.structures.compactMap { $0 as? Flower }.first!
        runtime.apiary.removeStructure(flower)
        for _ in 0..<100 {
            loaded = try await service.loadSnapshot()
            if loaded?.activeApiary?.structures.contains(where: { $0.id == flower.id }) == false,
               loaded?.activeApiary?.bees[0].assignedStructureID == nil { break }
            try await Task.sleep(for: .milliseconds(10))
        }
        let afterRemoval = try await reopened.loadAccount()
        XCTAssertFalse(afterRemoval.apiaries[0].structures.contains { $0.id == flower.id })
        XCTAssertNil(afterRemoval.apiaries[0].bees[0].producerAssignmentId)
    }

    func testContinuousChangesStillSave() async throws {
        let runtime = MockGameRuntime()
        let service = MockGameSaveService()
        let store = GameStore(
            saveService: service,
            runtime: runtime,
            debounce: .seconds(5),
            maximumDelay: .milliseconds(40)
        )
        try store.start()

        let producer = Task { @MainActor in
            var index = 0
            while !Task.isCancelled {
                runtime.account.name = "Change \(index)"
                index += 1
                try? await Task.sleep(for: .milliseconds(10))
            }
        }
        try await waitForSaves(service, count: 1, timeout: .seconds(2))
        producer.cancel()
        await producer.value
        let latestName = runtime.account.name
        try await store.flush()
        XCTAssertEqual(service.savedState?.account.name, latestName)
    }

    func testFailedSaveRetriesLatestState() async throws {
        let runtime = MockGameRuntime()
        let service = MockGameSaveService()
        service.failuresRemaining = 1
        let store = GameStore(saveService: service, runtime: runtime, debounce: .milliseconds(10))
        try store.start()

        runtime.account.name = "Recovered Apiary"
        try await waitForSaves(service, count: 1, timeout: .seconds(3))
        XCTAssertEqual(service.savedState?.account.name, "Recovered Apiary")
        XCTAssertNil(store.lastSaveError)
    }

    func testFlushReportsFailureAndRetriesInBackground() async throws {
        let runtime = MockGameRuntime()
        runtime.account.name = "Retry After Flush"
        let service = MockGameSaveService()
        service.failuresRemaining = 1
        let store = GameStore(saveService: service, runtime: runtime, debounce: .milliseconds(10))
        try store.start()

        do {
            try await store.flush()
            XCTFail("Expected the first save to fail")
        } catch GameSaveError.missingSave {
            XCTAssertNotNil(store.lastSaveError)
        }

        try await waitForSaves(service, count: 1, timeout: .seconds(3))
        XCTAssertEqual(service.savedState?.account.name, "Retry After Flush")
        XCTAssertNil(store.lastSaveError)
    }

    private func waitForSaves(
        _ service: MockGameSaveService,
        count: Int,
        timeout: Duration = .seconds(1)
    ) async throws {
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: timeout)
        while service.saveCount < count && clock.now < deadline {
            try await Task.sleep(for: .milliseconds(10))
        }
        XCTAssertGreaterThanOrEqual(service.saveCount, count)
    }

    private func waitForSavedState(
        _ service: MockGameSaveService,
        timeout: Duration = .seconds(1),
        where matches: (GameState) -> Bool
    ) async throws {
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: timeout)
        while clock.now < deadline {
            if let state = service.savedState, matches(state) { return }
            try await Task.sleep(for: .milliseconds(10))
        }
        XCTFail("Expected matching saved state")
    }

    private func makeIncubatorWithPendingBee() throws -> Incubator {
        var json = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(Incubator())) as? [String: Any])
        let pending = TimedReward(duration: 60, reward: Bee())
        json["currentPeriod"] = try JSONSerialization.jsonObject(with: JSONEncoder().encode(pending))
        return try JSONDecoder().decode(Incubator.self, from: JSONSerialization.data(withJSONObject: json))
    }

    private func makeHiveWithPendingHoneycomb() throws -> Hive {
        var json = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(Hive())) as? [String: Any])
        let pending = TimedReward(duration: 60, reward: Honeycomb(hive: nil))
        json["currentConstruction"] = try JSONSerialization.jsonObject(with: JSONEncoder().encode(pending))
        return try JSONDecoder().decode(Hive.self, from: JSONSerialization.data(withJSONObject: json))
    }
}

@MainActor
private final class MockGameRuntime: GameRuntime {
    let account = Account()
    var apiary: Apiary { account.apiaries[0] }
    var isTutorialComplete = true
    var onChange: (() -> Void)?

    init() {
        account.onChange = { [weak self] in self?.onChange?() }
    }

    func markSaved(at date: Date) {
        apiary.lastOnline = date
    }
}

@MainActor
private final class MockGameSaveService: GameSaveServicing {
    private(set) var savedState: GameState?
    private(set) var savedAccountName: String?
    private(set) var saveCount = 0
    var failuresRemaining = 0

    func hasSave() async -> Bool { false }
    func loadAccount() async throws -> Account { throw GameSaveError.missingSave }
    func loadSnapshot() async throws -> GameState? { nil }
    func saveAccount(_ account: Account) async throws {}

    func saveSnapshot(_ snapshot: GameState, account: Account) async throws {
        if failuresRemaining > 0 {
            failuresRemaining -= 1
            throw GameSaveError.missingSave
        }
        savedState = snapshot
        savedAccountName = account.name
        saveCount += 1
    }
}

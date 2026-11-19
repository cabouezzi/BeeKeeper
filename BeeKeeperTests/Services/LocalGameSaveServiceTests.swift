import XCTest
@testable import BeeKeeper

final class LocalGameSaveServiceTests: XCTestCase {
    @MainActor
    func testSaveAndLoadAccount() async throws {
        let (directory, defaults) = makeStorage()
        defer { removeStorage(directory, defaults) }

        let service = LocalGameSaveService(directoryURL: directory, defaults: defaults)
        let account = Account()
        account.name = "Saved Apiary"

        try await service.saveAccount(account)

        let hasSave = await service.hasSave()
        XCTAssertTrue(hasSave)
        let loaded = try await service.loadAccount()
        let snapshot = try await service.loadSnapshot()
        XCTAssertEqual(loaded.name, "Saved Apiary")
        XCTAssertEqual(snapshot?.account.name, loaded.name)
        XCTAssertEqual(snapshot?.activeApiaryID, loaded.apiaries.first?.id)
        XCTAssertEqual(snapshot?.account.isTutorialComplete, false)
        XCTAssertTrue(FileManager.default.fileExists(atPath: directory.appendingPathComponent("GameSave.json").path))
    }

    @MainActor
    func testAccountSaveKeepsSnapshotInSync() async throws {
        let (directory, defaults) = makeStorage()
        defer { removeStorage(directory, defaults) }

        let service = LocalGameSaveService(directoryURL: directory, defaults: defaults)
        let account = Account()
        let secondApiary = Apiary()
        account.apiaries.append(secondApiary)
        let snapshot = try LegacyStateAdapter.snapshot(
            account: account,
            activeApiaryID: secondApiary.id,
            isTutorialComplete: true
        )

        try await service.saveSnapshot(snapshot, account: account)
        let savedSnapshot = try await service.loadSnapshot()
        XCTAssertEqual(savedSnapshot, snapshot)

        account.name = "Updated Account"
        try await service.saveAccount(account)

        let loadedSnapshot = try await service.loadSnapshot()
        let loadedAccount = try await service.loadAccount()
        XCTAssertEqual(loadedSnapshot?.account.name, "Updated Account")
        XCTAssertEqual(loadedSnapshot?.account.id, loadedAccount.id)
        XCTAssertEqual(loadedSnapshot?.activeApiaryID, secondApiary.id)
        XCTAssertEqual(loadedSnapshot?.account.apiaries.count, loadedAccount.apiaries.count)
        XCTAssertEqual(loadedSnapshot?.account.isTutorialComplete, true)
        XCTAssertEqual(loadedAccount.name, "Updated Account")
    }

    @MainActor
    func testMismatchedSnapshotIsRejected() async throws {
        let (directory, defaults) = makeStorage()
        defer { removeStorage(directory, defaults) }

        let service = LocalGameSaveService(directoryURL: directory, defaults: defaults)
        let account = Account()
        var snapshot = try LegacyStateAdapter.snapshot(account: account, isTutorialComplete: false)
        snapshot.account.name = "Stale Name"

        do {
            try await service.saveSnapshot(snapshot, account: account)
            XCTFail("Expected an inconsistent snapshot error")
        } catch GameSaveError.inconsistentSnapshot {
            let hasSave = await service.hasSave()
            XCTAssertFalse(hasSave)
        }
    }

    @MainActor
    func testVersionOneEnvelopeRemainsReadable() async throws {
        let (directory, defaults) = makeStorage()
        defer { removeStorage(directory, defaults) }

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let account = Account()
        account.name = "Version One"
        let payload = try JSONEncoder().encode(account).base64EncodedString()
        let data = try JSONSerialization.data(withJSONObject: ["version": 1, "account": payload])
        try data.write(to: directory.appendingPathComponent("GameSave.json"))

        let service = LocalGameSaveService(directoryURL: directory, defaults: defaults)
        let loadedAccount = try await service.loadAccount()
        let loadedSnapshot = try await service.loadSnapshot()

        XCTAssertEqual(loadedAccount.name, "Version One")
        XCTAssertNil(loadedSnapshot)
    }

    @MainActor
    func testLegacyAccountMigratesAfterLoad() async throws {
        let (directory, defaults) = makeStorage()
        defer { removeStorage(directory, defaults) }

        let account = Account()
        account.name = "Legacy Apiary"
        defaults.set(try JSONEncoder().encode(account), forKey: "account")
        let service = LocalGameSaveService(directoryURL: directory, defaults: defaults)

        let hasSave = await service.hasSave()
        XCTAssertTrue(hasSave)
        let loaded = try await service.loadAccount()

        XCTAssertEqual(loaded.id, account.id)
        XCTAssertEqual(loaded.name, "Legacy Apiary")
        XCTAssertNil(defaults.data(forKey: "account"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: directory.appendingPathComponent("GameSave.json").path))

        let reopened = LocalGameSaveService(directoryURL: directory, defaults: defaults)
        let reloaded = try await reopened.loadAccount()
        XCTAssertEqual(reloaded.id, loaded.id)
        XCTAssertEqual(reloaded.name, loaded.name)
    }

    @MainActor
    func testUnsupportedSaveVersionIsNotReplacedByLegacyData() async throws {
        let (directory, defaults) = makeStorage()
        defer { removeStorage(directory, defaults) }

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let fileURL = directory.appendingPathComponent("GameSave.json")
        try Data(#"{"version":3,"account":""}"#.utf8).write(to: fileURL)
        defaults.set(try JSONEncoder().encode(Account()), forKey: "account")

        let service = LocalGameSaveService(directoryURL: directory, defaults: defaults)
        do {
            _ = try await service.loadAccount()
            XCTFail("Expected an unsupported save version")
        } catch GameSaveError.unsupportedVersion(let version) {
            XCTAssertEqual(version, 3)
        }

        XCTAssertNotNil(defaults.data(forKey: "account"))
    }

    private func makeStorage() -> (URL, UserDefaults) {
        let id = UUID().uuidString
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(id, isDirectory: true)
        let defaults = UserDefaults(suiteName: "BeeKeeper.SaveTests.\(id)")!
        return (directory, defaults)
    }

    private func removeStorage(_ directory: URL, _ defaults: UserDefaults) {
        try? FileManager.default.removeItem(at: directory)
        defaults.removePersistentDomain(forName: "BeeKeeper.SaveTests.\(directory.lastPathComponent)")
    }
}

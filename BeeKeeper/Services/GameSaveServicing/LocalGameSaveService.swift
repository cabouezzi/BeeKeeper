import Foundation

@MainActor
final class LocalGameSaveService: GameSaveServicing {
    static let shared = LocalGameSaveService()

    private let store: GameSaveFileStore
    private let defaults: UserDefaults
    private let legacyKey = "account"

    init(directoryURL: URL? = nil, defaults: UserDefaults = .standard) {
        let directory = directoryURL ?? FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("BeeKeeper", isDirectory: true)

        store = GameSaveFileStore(url: directory.appendingPathComponent("GameSave.json"))
        self.defaults = defaults
    }

    func hasSave() async -> Bool {
        let fileExists = await store.exists()
        return fileExists || defaults.data(forKey: legacyKey) != nil
    }

    func loadAccount() async throws -> Account {
        if let data = try await store.read() {
            return try decodeAccount(from: data)
        }

        guard let legacyData = defaults.data(forKey: legacyKey) else {
            throw GameSaveError.missingSave
        }

        let account = try JSONDecoder().decode(Account.self, from: legacyData)
        let fileData = try encodeAccount(account)
        let savedData = try await store.migrateIfNeeded(fileData)
        let savedAccount = try decodeAccount(from: savedData)
        defaults.removeObject(forKey: legacyKey)
        return savedAccount
    }

    func loadSnapshot() async throws -> GameState? {
        guard let data = try await store.read() else { return nil }
        let envelope = try decodeEnvelope(from: data)
        guard let snapshot = envelope.snapshot else { return nil }
        return try JSONDecoder().decode(GameState.self, from: snapshot)
    }

    func saveAccount(_ account: Account) async throws {
        let previous = try await loadSnapshot()
        let sameAccount = previous?.account.id == account.id
        let selectedID = sameAccount && account.apiaries.contains { $0.id == previous?.activeApiaryID }
            ? previous?.activeApiaryID : nil
        let updated = try LegacyStateAdapter.snapshot(
            account: account,
            activeApiaryID: selectedID,
            isTutorialComplete: sameAccount ? previous?.account.isTutorialComplete ?? false : false
        )
        try await saveSnapshot(updated, account: account)
    }

    func saveSnapshot(_ snapshot: GameState, account: Account) async throws {
        let expected = try LegacyStateAdapter.snapshot(
            account: account,
            activeApiaryID: snapshot.activeApiaryID,
            isTutorialComplete: snapshot.account.isTutorialComplete
        )
        guard snapshot == expected else { throw GameSaveError.inconsistentSnapshot }
        let accountData = try JSONEncoder().encode(account)
        let snapshotData = try JSONEncoder().encode(snapshot)
        let envelope = GameSaveEnvelope(account: accountData, snapshot: snapshotData)
        try await store.write(JSONEncoder().encode(envelope))
        defaults.removeObject(forKey: legacyKey)
    }

    private func encodeAccount(_ account: Account) throws -> Data {
        let accountData = try JSONEncoder().encode(account)
        return try JSONEncoder().encode(GameSaveEnvelope(account: accountData))
    }

    private func decodeAccount(from data: Data) throws -> Account {
        let envelope = try decodeEnvelope(from: data)
        return try JSONDecoder().decode(Account.self, from: envelope.account)
    }

    private func decodeEnvelope(from data: Data) throws -> GameSaveEnvelope {
        let envelope = try JSONDecoder().decode(GameSaveEnvelope.self, from: data)
        guard (1...GameSaveEnvelope.currentVersion).contains(envelope.version) else {
            throw GameSaveError.unsupportedVersion(envelope.version)
        }
        return envelope
    }
}

private actor GameSaveFileStore {
    private let url: URL

    init(url: URL) {
        self.url = url
    }

    func exists() -> Bool {
        FileManager.default.fileExists(atPath: url.path)
    }

    func read() throws -> Data? {
        guard exists() else { return nil }
        return try Data(contentsOf: url)
    }

    func migrateIfNeeded(_ data: Data) throws -> Data {
        if let current = try read() { return current }
        try write(data)
        return data
    }

    func write(_ data: Data) throws {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: url, options: .atomic)
    }
}

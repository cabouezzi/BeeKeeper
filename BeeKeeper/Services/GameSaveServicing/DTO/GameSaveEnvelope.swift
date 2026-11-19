import Foundation

struct GameSaveEnvelope: Codable {
    static let currentVersion = 2

    let version: Int
    let account: Data
    let snapshot: Data?

    init(account: Data, snapshot: Data? = nil) {
        version = Self.currentVersion
        self.account = account
        self.snapshot = snapshot
    }
}

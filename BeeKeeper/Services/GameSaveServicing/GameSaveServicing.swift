import Foundation

@MainActor
protocol GameSaveServicing {
    func hasSave() async -> Bool
    func loadAccount() async throws -> Account
    func loadSnapshot() async throws -> GameState?
    func saveAccount(_ account: Account) async throws
    func saveSnapshot(_ snapshot: GameState, account: Account) async throws
}

enum GameSaveError: LocalizedError {
    case missingSave
    case unsupportedVersion(Int)
    case inconsistentSnapshot

    var errorDescription: String? {
        switch self {
        case .missingSave:
            return "No saved account exists."
        case .unsupportedVersion(let version):
            return "Save version \(version) is not supported."
        case .inconsistentSnapshot:
            return "Game state does not match its account."
        }
    }
}

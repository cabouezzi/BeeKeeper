//
//  DatabaseService.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/25/24.
//

import Foundation

enum DatabaseServiceError: LocalizedError {
    case accountNonexistant
}

class Wrapper: Codable, ModelVisitor {
    enum ModelKind: String, Codable {
        case unknown, bee, hive, incubator, honeyStorage, pollenStorage
        case daisy = "flower", lavender, rose
    }
    
    private(set) var kind: ModelKind
    let value: Model
    
    init(_ value: some Model) {
        self.value = value
        self.kind = .unknown
        kind = value.accept(self)
    }
    
    private enum CodingKeys: CodingKey {
        case type, value
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        kind = try container.decode(ModelKind.self, forKey: .type)
        switch kind {
        case .unknown:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown saved model kind."
            )
        case .bee: value = try container.decode(Bee.self, forKey: .value)
        case .hive: value = try container.decode(Hive.self, forKey: .value)
        case .incubator: value = try container.decode(Incubator.self, forKey: .value)
        case .honeyStorage: value = try container.decode(HoneyStorage.self, forKey: .value)
        case .pollenStorage: value = try container.decode(PollenStorage.self, forKey: .value)
            
        case .daisy: value = try container.decode(Daisy.self, forKey: .value)
        case .lavender: value = try container.decode(Lavender.self, forKey: .value)
        case .rose: value = try container.decode(Rose.self, forKey: .value)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(kind, forKey: .type)
        try container.encode(value, forKey: .value)
    }
    
    func visitBee(_ model: Bee) -> ModelKind {
        return .bee
    }
    
    func visitHive(_ model: Hive) -> ModelKind {
        return .hive
    }
    
    func visitFlower(_ model: Flower) -> ModelKind {
        switch model {
        case is Daisy: return .daisy
        case is Lavender: return .lavender
        case is Rose: return .rose
        default: fatalError()
        }
    }
    
    func visitIncubator(_ model: Incubator) -> ModelKind {
        return .incubator
    }
    
    func visitHoneyStorage(_ model: HoneyStorage) -> ModelKind {
        return .honeyStorage
    }
    
    func visitPollenStorage(_ model: PollenStorage) -> ModelKind {
        return .pollenStorage
    }
}

final class DatabaseService {
    static let shared = DatabaseService()

    private init() {}

    func hasAccount() async -> Bool {
        await LocalGameSaveService.shared.hasSave()
    }

    func createAccount() async throws {
        let account = await MainActor.run { Account() }
        try await LocalGameSaveService.shared.saveAccount(account)
    }

    func fetchAccount() async throws -> Account {
        do {
            return try await LocalGameSaveService.shared.loadAccount()
        } catch GameSaveError.missingSave {
            throw DatabaseServiceError.accountNonexistant
        }
    }

    func saveAccount(_ account: Account) async throws {
        try await LocalGameSaveService.shared.saveAccount(account)
    }
}

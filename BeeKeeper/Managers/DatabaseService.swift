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
    enum ModelKind: Codable {
        case unknown, bee, hive, flower, incubator, honeyStorage, pollenStorage
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
        case .unknown: fatalError()
        case .bee: value = try container.decode(Bee.self, forKey: .value)
        case .hive: value = try container.decode(Hive.self, forKey: .value)
        case .flower: value = try container.decode(Flower.self, forKey: .value)
        case .incubator: value = try container.decode(Incubator.self, forKey: .value)
        case .honeyStorage: value = try container.decode(HoneyStorage.self, forKey: .value)
        case .pollenStorage: value = try container.decode(PollenStorage.self, forKey: .value)
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
        return .flower
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
    
    private let _KEY = "account"
    
    private init() {
        
    }
    
    func hasAccount() async -> Bool {
        return UserDefaults.standard.object(forKey: _KEY) != nil
    }
    
    func createAccount() async throws {
        let account = Account()
        try await saveAccount(account)
    }
    
    func fetchAccount() async throws -> Account {
        guard let data = UserDefaults.standard.object(forKey: _KEY) as? Data else { throw DatabaseServiceError.accountNonexistant }
        let decoder = JSONDecoder()
        print(try JSONSerialization.jsonObject(with: data))
        let account = try decoder.decode(Account.self, from: data)
        return account
    }
    
    func saveAccount(_ account: Account) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(account)
        print(try JSONSerialization.jsonObject(with: data))
        UserDefaults.standard.set(data, forKey: _KEY)
    }
}

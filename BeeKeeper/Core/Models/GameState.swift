import Foundation

struct GameState: Codable, Equatable, Sendable {
    var account: AccountState
    var activeApiaryID: UUID

    var activeApiary: ApiaryState? {
        account.apiaries.first { $0.id == activeApiaryID }
    }
}

struct AccountState: Codable, Equatable, Sendable {
    var id: UUID
    var name: String
    var apiaries: [ApiaryState]
    var unlockedGenes: Set<GeneID>
    var activeResearch: TimedJobState<GeneID>?
    var isTutorialComplete: Bool
}

private extension AccountState {
    enum CodingKeys: CodingKey {
        case id, name, apiaries, unlockedGenes, activeResearch, research, isTutorialComplete
    }
}

extension AccountState {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        apiaries = try container.decode([ApiaryState].self, forKey: .apiaries)
        unlockedGenes = try container.decode(Set<GeneID>.self, forKey: .unlockedGenes)
        activeResearch = try container.decodeIfPresent(TimedJobState<GeneID>.self, forKey: .activeResearch)
            ?? container.decodeIfPresent(TimedJobState<GeneID>.self, forKey: .research)
        isTutorialComplete = try container.decode(Bool.self, forKey: .isTutorialComplete)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(apiaries, forKey: .apiaries)
        try container.encode(unlockedGenes, forKey: .unlockedGenes)
        try container.encodeIfPresent(activeResearch, forKey: .activeResearch)
        try container.encode(isTutorialComplete, forKey: .isTutorialComplete)
    }
}

struct ApiaryState: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var lastSimulatedAt: Date
    var wildBeeCount: Float
    var wildGenePool: [GeneID: Float]
    var bees: [BeeState]
    var structures: [StructureState]
}

struct BeeState: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var nickname: String
    var genes: Set<GeneID>
    var assignedStructureID: UUID?
}

struct GeneID: RawRepresentable, Codable, Hashable, Sendable {
    var rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    init(from decoder: Decoder) throws {
        rawValue = try decoder.singleValueContainer().decode(String.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

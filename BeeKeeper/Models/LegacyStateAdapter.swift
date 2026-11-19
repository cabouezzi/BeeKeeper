import Foundation

enum LegacyStateAdapterError: Error {
    case noApiaries
    case unknownApiary(UUID)
    case unsupportedStructure(String)
    case invalidBeeAssignment(UUID, UUID)
    case assignmentCapacityExceeded(UUID)
}

enum LegacyStateAdapter {
    static func snapshot(
        account: Account,
        activeApiaryID: UUID? = nil,
        isTutorialComplete: Bool
    ) throws -> GameState {
        let apiaries = try account.apiaries.map(apiaryState)
        guard let firstApiary = apiaries.first else {
            throw LegacyStateAdapterError.noApiaries
        }
        let selectedID = activeApiaryID ?? firstApiary.id
        guard apiaries.contains(where: { $0.id == selectedID }) else {
            throw LegacyStateAdapterError.unknownApiary(selectedID)
        }

        let research = account.activeResearch.map { job($0, reward: GeneID(rawValue: $0.reward.rawValue)) }
        let state = AccountState(
            id: account.id,
            name: account.name,
            apiaries: apiaries,
            unlockedGenes: Set(account.unlockedGenes.map { GeneID(rawValue: $0.rawValue) }),
            activeResearch: research,
            isTutorialComplete: isTutorialComplete
        )
        return GameState(account: state, activeApiaryID: selectedID)
    }

    private static func apiaryState(_ apiary: Apiary) throws -> ApiaryState {
        let structureIDs = Set(apiary.structures.map(\.id))
        var assignmentCounts: [UUID: Int] = [:]
        for bee in apiary.bees {
            guard let id = bee.producerAssignmentId else { continue }
            guard structureIDs.contains(id) else {
                throw LegacyStateAdapterError.invalidBeeAssignment(bee.id, id)
            }
            assignmentCounts[id, default: 0] += 1
        }
        for structure in apiary.structures {
            if assignmentCounts[structure.id, default: 0] > structure.maximumAssignedBees {
                throw LegacyStateAdapterError.assignmentCapacityExceeded(structure.id)
            }
        }
        let genePool = Dictionary(uniqueKeysWithValues: apiary.wildGenePool.map {
            (GeneID(rawValue: $0.key.rawValue), $0.value)
        })
        return ApiaryState(
            id: apiary.id,
            lastSimulatedAt: apiary.lastOnline,
            wildBeeCount: apiary.wildBees,
            wildGenePool: genePool,
            bees: apiary.bees.map(beeState),
            structures: try apiary.structures.map(structureState)
        )
    }

    private static func beeState(_ bee: Bee) -> BeeState {
        BeeState(
            id: bee.id,
            nickname: bee.nickname,
            genes: Set(bee.genetics.map { GeneID(rawValue: $0.rawValue) }),
            assignedStructureID: bee.producerAssignmentId
        )
    }

    private static func structureState(_ structure: Structure) throws -> StructureState {
        let kind: StructureKind
        let contents: StructureContents

        switch structure {
        case let hive as Hive:
            kind = .hive
            let construction = hive.currentConstruction.map { job($0, reward: honeycombState($0.reward)) }
            contents = .hive(HiveState(honeycombs: hive.honeycombs.map(honeycombState), currentConstruction: construction))
        case let incubator as Incubator:
            kind = .incubator
            contents = .incubator(incubator.currentIncubation.map { job($0, reward: beeState($0.reward)) })
        case let storage as HoneyStorage:
            kind = .honeyStorage
            contents = .storage(StorageState(storage))
        case let storage as PollenStorage:
            kind = .pollenStorage
            contents = .storage(StorageState(storage))
        case let flower as Daisy:
            kind = .daisy
            contents = .flower(FlowerState(flower))
        case let flower as Lavender:
            kind = .lavender
            contents = .flower(FlowerState(flower))
        case let flower as Rose:
            kind = .rose
            contents = .flower(FlowerState(flower))
        default:
            throw LegacyStateAdapterError.unsupportedStructure(String(describing: type(of: structure)))
        }

        return StructureState(
            id: structure.id,
            kind: kind,
            level: structure.level,
            area: GridRect(structure.area),
            maximumAssignedBees: structure.maximumAssignedBees,
            contents: contents
        )
    }

    private static func honeycombState(_ honeycomb: Honeycomb) -> HoneycombState {
        HoneycombState(
            id: honeycomb.id,
            kind: honeycomb is Pollencomb ? .pollen : .honey,
            storage: StorageState(containing: ResourceState(honeycomb.containing), maximum: ResourceState(honeycomb.maximum))
        )
    }

    private static func job<Legacy: Codable, Reward: Codable & Equatable & Sendable>(
        _ legacy: TimedReward<Legacy>,
        reward: Reward
    ) -> TimedJobState<Reward> {
        TimedJobState(
            startDate: legacy.startDate,
            duration: legacy.duration,
            endDate: legacy.endDate,
            reward: reward
        )
    }
}

private extension ResourceState {
    init(_ resources: Resources) {
        self.init(money: resources.money, honey: resources.honey, pollen: resources.pollen, beeBread: resources.beeBread)
    }
}

private extension GridRect {
    init(_ area: DiscreteRect) {
        self.init(x: area.x, y: area.y, width: area.width, height: area.height)
    }
}

private extension StorageState {
    init(_ container: Container) {
        self.init(containing: ResourceState(container.containing), maximum: ResourceState(container.maximum))
    }
}

private extension FlowerState {
    init(_ flower: Flower) {
        self.init(storage: StorageState(flower), datePlanted: flower.datePlanted, lifespan: flower.lifespan)
    }
}

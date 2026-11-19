import Foundation

struct StructureState: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var kind: StructureKind
    var level: UInt
    var area: GridRect
    var maximumAssignedBees: Int
    var contents: StructureContents
}

enum StructureKind: String, Codable, Sendable {
    case hive
    case incubator
    case honeyStorage
    case pollenStorage
    case daisy
    case lavender
    case rose
}

enum StructureContents: Codable, Equatable, Sendable {
    case hive(HiveState)
    case incubator(TimedJobState<BeeState>?)
    case storage(StorageState)
    case flower(FlowerState)
}

struct GridRect: Codable, Equatable, Sendable {
    var x: Int
    var y: Int
    var width: Int
    var height: Int
}

struct StorageState: Codable, Equatable, Sendable {
    var containing: ResourceState
    var maximum: ResourceState
}

struct HiveState: Codable, Equatable, Sendable {
    var honeycombs: [HoneycombState]
    var currentConstruction: TimedJobState<HoneycombState>?
}

struct HoneycombState: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var kind: HoneycombKind
    var storage: StorageState
}

enum HoneycombKind: String, Codable, Sendable {
    case honey
    case pollen
}

struct FlowerState: Codable, Equatable, Sendable {
    var storage: StorageState
    var datePlanted: Date
    var lifespan: TimeInterval
}

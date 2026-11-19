import Foundation

struct ResourceState: Codable, Equatable, Sendable {
    var money: Float = 0
    var honey: Float = 0
    var pollen: Float = 0
    var beeBread: Float = 0
}

import Foundation

struct TimedJobState<Reward: Codable & Equatable & Sendable>: Codable, Equatable, Sendable {
    var startDate: Date
    var duration: TimeInterval
    var endDate: Date
    var reward: Reward

    func isComplete(at date: Date) -> Bool {
        date >= endDate
    }
}

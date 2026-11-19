import Foundation
import XCTest
@testable import BeeKeeper

final class GameStateTests: XCTestCase {
    func testRoundTripKeepsIdentityAndTimedWork() throws {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let apiaryID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let beeID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
        let hiveID = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
        let bee = BeeState(id: beeID, nickname: "Ada", genes: [GeneID(rawValue: "stripesI")], assignedStructureID: hiveID)
        let comb = HoneycombState(id: UUID(), kind: .honey, storage: StorageState(containing: ResourceState(honey: 12), maximum: ResourceState(honey: 1_000)))
        let job = TimedJobState(startDate: start, duration: 60, endDate: start.addingTimeInterval(60), reward: comb)
        let hive = StructureState(id: hiveID, kind: .hive, level: 1, area: GridRect(x: 0, y: 0, width: 2, height: 2), maximumAssignedBees: 1, contents: .hive(HiveState(honeycombs: [], currentConstruction: job)))
        let apiary = ApiaryState(id: apiaryID, lastSimulatedAt: start, wildBeeCount: 1_000, wildGenePool: [:], bees: [bee], structures: [hive])
        let account = AccountState(id: UUID(), name: "The Apiary", apiaries: [apiary], unlockedGenes: [GeneID(rawValue: "stripesI")], activeResearch: nil, isTutorialComplete: true)
        let state = GameState(account: account, activeApiaryID: apiaryID)

        let data = try JSONEncoder().encode(state)
        let restored = try JSONDecoder().decode(GameState.self, from: data)

        XCTAssertEqual(restored, state)
        XCTAssertEqual(restored.activeApiary?.bees.first?.id, beeID)
        XCTAssertTrue(job.isComplete(at: start.addingTimeInterval(60)))
        XCTAssertFalse(job.isComplete(at: start.addingTimeInterval(59)))
    }

    func testLegacyResearchKeyDecodesAndNewKeyRoundTrips() throws {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let gene = GeneID(rawValue: Gene.furI.rawValue)
        let job = TimedJobState(startDate: start, duration: 60, endDate: start.addingTimeInterval(60), reward: gene)
        let apiary = ApiaryState(id: UUID(), lastSimulatedAt: start, wildBeeCount: 100, wildGenePool: [:], bees: [], structures: [])
        let account = AccountState(id: UUID(), name: "Legacy", apiaries: [apiary], unlockedGenes: [], activeResearch: job, isTutorialComplete: true)
        let state = GameState(account: account, activeApiaryID: apiary.id)
        var json = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(state)) as? [String: Any])
        var savedAccount = try XCTUnwrap(json["account"] as? [String: Any])
        savedAccount["research"] = savedAccount.removeValue(forKey: "activeResearch")
        json["account"] = savedAccount

        let restored = try JSONDecoder().decode(GameState.self, from: JSONSerialization.data(withJSONObject: json))
        XCTAssertEqual(restored.account.activeResearch, job)

        let encoded = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(restored)) as? [String: Any])
        let encodedAccount = try XCTUnwrap(encoded["account"] as? [String: Any])
        XCTAssertNotNil(encodedAccount["activeResearch"])
        XCTAssertNil(encodedAccount["research"])
    }

    func testLegacyAccountResearchKeyDecodes() throws {
        let account = Account()
        account.activeResearch = TimedReward(duration: 60, reward: .furI)
        var json = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(account)) as? [String: Any])
        json["research"] = json.removeValue(forKey: "activeResearch")

        let restored = try JSONDecoder().decode(Account.self, from: JSONSerialization.data(withJSONObject: json))
        XCTAssertEqual(restored.activeResearch?.reward, .furI)

        let encoded = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(restored)) as? [String: Any])
        XCTAssertNotNil(encoded["activeResearch"])
        XCTAssertNil(encoded["research"])
    }
}

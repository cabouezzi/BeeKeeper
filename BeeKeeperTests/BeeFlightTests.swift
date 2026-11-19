import SceneKit
import XCTest
@testable import BeeKeeper

final class BeeFlightTests: XCTestCase {
    func testFlightDoesNotCrossThinWallsAtSeveralMovementStepDurations() {
        for angle in [Float.zero, Float.pi / 4] {
            for rate in [60, 30, 15] {
                let scene = SCNScene()
                scene.physicsWorld.timeStep = 1.0 / Double(rate)
                let wall = SCNNode(geometry: SCNBox(width: 0.08, height: 2, length: 1.2, chamferRadius: 0))
                wall.eulerAngles.y = angle
                wall.physicsBody = SCNPhysicsBody.static()
                scene.rootNode.addChildNode(wall)

                let start = wall.convertPosition(SCNVector3(-0.35, 0, 0), to: nil)
                let heading = wall.convertVector(SCNVector3(4, 0, 0), to: nil)
                let bee = Bee(initialVelocity: heading)
                bee.worldPosition = start
                scene.rootNode.addChildNode(bee)
                let view = SCNView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
                view.scene = scene
                _ = view.snapshot()

                let sightLine = wall.convertPosition(SCNVector3(0.35, 0, 0), to: nil)
                XCTAssertTrue(scene.physicsWorld.rayTestWithSegment(from: start, to: sightLine).contains { $0.node === wall })

                for frame in 0..<(rate * 2) {
                    let before = wall.convertPosition(bee.worldPosition, from: nil)
                    bee.droneStep(in: scene.physicsWorld)
                    let after = wall.convertPosition(bee.worldPosition, from: nil)
                    XCTAssertFalse(segmentEntersWall(before, after),
                        "Wall crossed at step 1/\(rate), angle \(angle), frame \(frame), before \(before), after \(after)")
                }

                let end = wall.convertPosition(bee.worldPosition, from: nil)
                XCTAssertGreaterThan(abs(end.z), 0.25, "Bee stayed pinned at step 1/\(rate), angle \(angle)")
            }
        }
    }

    private func segmentEntersWall(_ start: SCNVector3, _ end: SCNVector3) -> Bool {
        let halfSize = SCNVector3(0.04, 1, 0.6)
        var entry: Float = 0
        var exit: Float = 1
        for (a, b, limit) in [(start.x, end.x, halfSize.x), (start.y, end.y, halfSize.y), (start.z, end.z, halfSize.z)] {
            let delta = b - a
            if abs(delta) < 0.000001 {
                if abs(a) < limit - 0.001 { continue }
                return false
            }
            let first = (-limit + 0.001 - a) / delta
            let last = (limit - 0.001 - a) / delta
            entry = max(entry, min(first, last))
            exit = min(exit, max(first, last))
            if entry > exit { return false }
        }
        return entry <= exit
    }
}

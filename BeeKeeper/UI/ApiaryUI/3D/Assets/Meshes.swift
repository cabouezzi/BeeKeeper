//
//  Meshes.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import SceneKit

struct Meshes {
    static let floor: SCNGeometry = {
        let floor = SCNFloor()
        let material = SCNMaterial();
        material.diffuse.contents = UIColor.darkGray;
        floor.materials = [material]
        return floor
    }()
    
    static let ground: SCNGeometry = {
        let plane = SCNPlane(width: 20, height: 20)
        let material = SCNMaterial();
        material.diffuse.contents = UIColor.red;
        plane.materials = [material]
        return plane
    }()
    
    struct Bee {
        static let torso: SCNGeometry = {
            let scene = SCNScene(named: "BeeBody.scn")!
            let node = scene.rootNode.childNode(withName: "Stinger", recursively: true)!
            return node.geometry!
        }()
        
        static let stinger: SCNGeometry = {
            let scene = SCNScene(named: "BeeBody.scn")!
            let node = scene.rootNode.childNode(withName: "Stinger", recursively: true)!
            return node.geometry!
        }()
        
        static let head: SCNGeometry = {
            let scene = SCNScene(named: "BeeBody.scn")!
            let node = scene.rootNode.childNode(withName: "Head", recursively: true)!
            return node.geometry!
        }()
        
        static let abdomen: SCNGeometry = {
            let scene = SCNScene(named: "BeeBody.scn")!
            let node = scene.rootNode.childNode(withName: "Abdomen", recursively: true)!
            return node.geometry!
        }()
    }
    
    struct Structure {
        // TODO: Revisit: `node.geometry!.copy() as! SCNGeometry` will create new geometry objects as opposed to references to the same geometry. This allows for modifying a node independently
        static let hive: SCNGeometry = {
            let scene = SCNScene(named: "Hive.scn")!
            let node = scene.rootNode.childNode(withName: "hive", recursively: true)!
            return node.geometry!
        }()
        
        static let honeyStorage: SCNGeometry = {
            let scene = SCNScene(named: "Rack.scn")!
            let node = scene.rootNode.childNode(withName: "rack", recursively: true)!
            return node.geometry!
        }()
        
        static let pollenStorage: SCNGeometry = {
            return honeyStorage
        }()
        
        static let incubator: SCNGeometry = {
            let geo = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.2)
            geo.firstMaterial?.diffuse.contents = UIColor.green
            return geo
        }()
    }
}

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
        static let body: SCNGeometry = {
            let geo = SCNCylinder(radius: 0.1, height: 0.5)
            geo.firstMaterial?.diffuse.contents = UIColor.yellow
            return geo
        }()
    }
    
    struct Structure {
        static let hive: SCNGeometry = {
            let geo = SCNBox(width: 2, height: 1, length: 2, chamferRadius: 0.2)
            geo.firstMaterial?.diffuse.contents = UIColor.red
            return geo
        }()
        
        static let honeyStorage: SCNGeometry = {
            let geo = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0.2)
            geo.firstMaterial?.diffuse.contents = UIColor.brown
            return geo
        }()
        
        static let incubator: SCNGeometry = {
            let geo = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0.2)
            geo.firstMaterial?.diffuse.contents = UIColor.green
            return geo
        }()
    }
}

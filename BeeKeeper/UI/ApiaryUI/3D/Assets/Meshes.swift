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
        struct Torso {
            static let plain: SCNGeometry = {
                let scene = SCNScene(named: "BeePlain.scn")!
                let node = scene.rootNode.childNode(withName: "Torso", recursively: true)!
                return node.geometry!
            }()
            
            static let yellowStripes: SCNGeometry = {
                let scene = SCNScene(named: "BeeStripes.scn")!
                let node = scene.rootNode.childNode(withName: "TorsoStripes", recursively: true)!
                return node.geometry!
            }()
        }
        
        struct Stinger {
            static let plain: SCNGeometry = {
                let scene = SCNScene(named: "BeePlain.scn")!
                let node = scene.rootNode.childNode(withName: "Stinger", recursively: true)!
                return node.geometry!
            }()
        }
        
        struct Head {
            static let plain: SCNGeometry = {
                let scene = SCNScene(named: "BeePlain.scn")!
                let node = scene.rootNode.childNode(withName: "Head", recursively: true)!
                return node.geometry!
            }()
        }
        
        struct Abdomen {
            static let plain: SCNGeometry = {
                let scene = SCNScene(named: "BeePlain.scn")!
                let node = scene.rootNode.childNode(withName: "Abdomen", recursively: true)!
                return node.geometry!
            }()
            
            static let yellowStripes: SCNGeometry = {
                let scene = SCNScene(named: "BeeStripes.scn")!
                let node = scene.rootNode.childNode(withName: "AbdomenStripes", recursively: true)!
                return node.geometry!
            }()
        }
    }
    
    struct Structure {
        // TODO: Revisit: `node.geometry!.copy() as! SCNGeometry` will create new geometry objects as opposed to references to the same geometry. This allows for modifying a node independently
        static let hive: SCNGeometry = {
            let scene = SCNScene(named: "Hive.scn")!
            let node = scene.rootNode.childNode(withName: "hive", recursively: true)!
            return node.geometry!
        }()
        
        static let honeycombFrame: SCNGeometry = {
            let scene = SCNScene(named: "Frame.scn")!
            let node = scene.rootNode.childNode(withName: "frame", recursively: true)!
            return node.geometry!
        }()
        
        static let hiveCover: SCNGeometry = {
            let scene = SCNScene(named: "Hive.scn")!
            let node = scene.rootNode.childNode(withName: "top", recursively: true)!
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
            let scene = SCNScene(named: "ScienceStand.scn")!
            let node = scene.rootNode.childNode(withName: "incubator", recursively: true)!
            return node.flattenedClone().geometry!
        }()
    }
    
    struct Flowers {
        static let daisy: SCNGeometry = {
            return SCNScene(named: "Daisy.scn")!.rootNode.childNodes.first!.geometry!
        }()
        
        static let lavender: SCNGeometry = {
            return SCNScene(named: "Lavender.scn")!.rootNode.childNodes.first!.geometry!
        }()
    }
    
    struct Bubble {
        static let blank: SCNGeometry = {
            let scene = SCNScene(named: "Bubble.scn")!
            let node = scene.rootNode.childNode(withName: "plane", recursively: true)!
            return node.geometry!
        }()
        
        static let honey: SCNGeometry = {
            var geometry = Bubble.blank.copy() as! SCNGeometry
            guard let texture = UIImage(named: "honeyBubble") else { return geometry }
            geometry.materials.first?.diffuse.contents = texture
            return geometry
        }()
        
        static let pollen: SCNGeometry = {
            var geometry = Bubble.blank.copy() as! SCNGeometry
            guard let texture = UIImage(named: "pollenBubble") else { return geometry }
            geometry.materials.first?.diffuse.contents = texture
            return geometry
        }()
    }
}

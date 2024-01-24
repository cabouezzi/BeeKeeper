//
//  Meshes.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import SceneKit

struct Meshes {
    static var floor: SCNGeometry {
        let floor = SCNFloor()
        let material = SCNMaterial();
        material.diffuse.contents = UIColor.darkGray;
        floor.materials = [material]
        return floor
    }
    
    static var ground: SCNGeometry {
        let plane = SCNPlane(width: 20, height: 20)
        let material = SCNMaterial();
        material.diffuse.contents = UIColor.red;
        plane.materials = [material]
        return plane
    }
    
    struct Bee {
        struct Torso {
            static var plain: SCNGeometry {
                let scene = SCNScene(named: "BeePlain.scn")!
                let node = scene.rootNode.childNode(withName: "Torso", recursively: true)!
                return node.geometry!
            }
            
            static var grayStripes: SCNGeometry {
                let scene = SCNScene(named: "BeeStripesGray.scn")!
                let node = scene.rootNode.childNode(withName: "TorsoStripes", recursively: true)!
                return node.geometry!
            }
            
            static var yellowStripes: SCNGeometry {
                let scene = SCNScene(named: "BeeStripesYellow.scn")!
                let node = scene.rootNode.childNode(withName: "TorsoStripes", recursively: true)!
                return node.geometry!
            }
            
            static var orangeStripes: SCNGeometry {
                let scene = SCNScene(named: "BeeStripesOrange.scn")!
                let node = scene.rootNode.childNode(withName: "TorsoStripes", recursively: true)!
                return node.geometry!
            }
            
            static var bumble: SCNGeometry {
                let scene = SCNScene(named: "BeeAbdomens.scn")!
                let node = scene.rootNode.childNode(withName: "torsoHigh", recursively: true)!
                return node.geometry!
            }
            
            static var wasp: SCNGeometry {
                let scene = SCNScene(named: "BeeAbdomens.scn")!
                let node = scene.rootNode.childNode(withName: "torsoLow", recursively: true)!
                return node.geometry!
            }
        }
        
        struct Stinger {
            static var plain: SCNGeometry {
                let scene = SCNScene(named: "BeePlain.scn")!
                let node = scene.rootNode.childNode(withName: "Stinger", recursively: true)!
                return node.geometry!
            }
            
            static var medium: SCNGeometry {
                let scene = SCNScene(named: "BeeStingers.scn")!
                let node = scene.rootNode.childNode(withName: "StingerMedium", recursively: true)!
                return node.geometry!
            }
            
            static var long: SCNGeometry {
                let scene = SCNScene(named: "BeeStingers.scn")!
                let node = scene.rootNode.childNode(withName: "StingerLong", recursively: true)!
                return node.geometry!
            }
        }
        
        struct Head {
            static var plain: SCNGeometry {
                let scene = SCNScene(named: "BeePlain.scn")!
                let node = scene.rootNode.childNode(withName: "Head", recursively: true)!
                return node.geometry!
            }
        }
        
        struct Abdomen {
            static var plain: SCNGeometry {
                let scene = SCNScene(named: "BeePlain.scn")!
                let node = scene.rootNode.childNode(withName: "Abdomen", recursively: true)!
                return node.geometry!
            }
            
            static var grayStripes: SCNGeometry {
                let scene = SCNScene(named: "BeeStripesGray.scn")!
                let node = scene.rootNode.childNode(withName: "AbdomenStripes", recursively: true)!
                return node.geometry!
            }
            
            static var yellowStripes: SCNGeometry {
                let scene = SCNScene(named: "BeeStripesYellow.scn")!
                let node = scene.rootNode.childNode(withName: "AbdomenStripes", recursively: true)!
                return node.geometry!
            }
            
            static var orangeStripes: SCNGeometry {
                let scene = SCNScene(named: "BeeStripesOrange.scn")!
                let node = scene.rootNode.childNode(withName: "AbdomenStripes", recursively: true)!
                return node.geometry!
            }
            
            static var bumble: SCNGeometry {
                let scene = SCNScene(named: "BeeAbdomens.scn")!
                let node = scene.rootNode.childNode(withName: "abdomenHigh", recursively: true)!
                return node.geometry!
            }
            
            static var wasp: SCNGeometry {
                let scene = SCNScene(named: "BeeAbdomens.scn")!
                let node = scene.rootNode.childNode(withName: "abdomenLow", recursively: true)!
                return node.geometry!
            }
        }
    }
    
    struct Structure {
        static var hive: SCNGeometry {
            let scene = SCNScene(named: "Hive.scn")!
            let node = scene.rootNode.childNode(withName: "hive", recursively: true)!
            return node.geometry!
        }
        
        static var honeycombFrame: SCNGeometry {
            let scene = SCNScene(named: "Frame.scn")!
            let node = scene.rootNode.childNode(withName: "frame", recursively: true)!
            return node.geometry!
        }
        
        static var hiveCover: SCNGeometry {
            let scene = SCNScene(named: "Hive.scn")!
            let node = scene.rootNode.childNode(withName: "top", recursively: true)!
            return node.geometry!
        }
        
        static var honeyStorage: SCNGeometry {
            let scene = SCNScene(named: "Rack.scn")!
            let node = scene.rootNode.childNode(withName: "rack", recursively: true)!
            return node.geometry!
        }
        
        static var pollenStorage: SCNGeometry {
            return honeyStorage
        }
        
        static var incubator: SCNGeometry {
            let scene = SCNScene(named: "ScienceStand.scn")!
            let node = scene.rootNode.childNode(withName: "incubator", recursively: true)!
            return node.geometry!
        }
    }
    
    struct Flowers {
        static var daisy: SCNGeometry {
            return SCNScene(named: "Daisy.scn")!.rootNode.childNodes.first!.geometry!
        }
        
        static var lavender: SCNGeometry {
            return SCNScene(named: "Lavender.scn")!.rootNode.childNodes.first!.geometry!
        }
    }
    
    struct Bubble {
        static var blank: SCNGeometry {
            let scene = SCNScene(named: "Bubble.scn")!
            let node = scene.rootNode.childNode(withName: "plane", recursively: true)!
            return node.geometry!
        }
        
        static var honey: SCNGeometry {
            var geometry = Bubble.blank.copy() as! SCNGeometry
            guard let texture = UIImage(named: "honeyBubble") else { return geometry }
            geometry.materials = [SCNMaterial()]
            geometry.materials.first?.diffuse.contents = texture
            return geometry
        }
        
        static var pollen: SCNGeometry {
            var geometry = Bubble.blank.copy() as! SCNGeometry
            guard let texture = UIImage(named: "pollenBubble") else { return geometry }
            geometry.materials = [SCNMaterial()]
            geometry.materials.first?.diffuse.contents = texture
            return geometry
        }
        
        static var plus: SCNGeometry {
            var geometry = Bubble.blank.copy() as! SCNGeometry
            guard let texture = UIImage(named: "plusBubble") else { return geometry }
            geometry.materials = [SCNMaterial()]
            geometry.materials.first?.diffuse.contents = texture
            return geometry
        }
    }
}

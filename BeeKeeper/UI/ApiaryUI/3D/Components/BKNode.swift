//
//  NodeVisitor.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/9/23.
//

import SceneKit

open class BKNode: SCNNode {
    fileprivate var cacheSet = false
    fileprivate var materialCache: Any?
    
    final func highlight(color: UIColor = .yellow) {
        cacheSet = true
        materialCache = geometry?.materials.first?.emission.contents
        geometry?.materials.first?.emission.contents = color
    }
    
    final func unhighlight() {
        if cacheSet {
            geometry?.materials.first?.emission.contents = materialCache
        }
        cacheSet = false
    }
}

extension SCNNode {
    func firstParentModelNode() -> (SCNNode & Model)? {
        if let bknode = self as? (SCNNode & Model) {
            return bknode
        } else if let parent = parent {
            return parent.firstParentModelNode()
        } else {
            return nil
        }
    }
}

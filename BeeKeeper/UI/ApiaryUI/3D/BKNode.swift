//
//  NodeVisitor.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/9/23.
//

import SceneKit

open class BKNode: SCNNode {
    var model: (any Model)?
    
    fileprivate var cacheSet = false
    fileprivate var materialCache: Any?
    
    convenience init(model: some Model) {
        self.init()
        self.model = model
    }
    
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
    func firstBKNodeParent() -> BKNode? {
        if let bknode = self as? BKNode {
            return bknode
        } else if let parent = parent {
            return parent.firstBKNodeParent()
        } else {
            return nil
        }
    }
}

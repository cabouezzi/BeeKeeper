//
//  NodeVisitor.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/9/23.
//

import SceneKit

open class BKNode: SCNNode {
    var model: (any Model)?
    
    convenience init(model: some Model) {
        self.init()
        self.model = model
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

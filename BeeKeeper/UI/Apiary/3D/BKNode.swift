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

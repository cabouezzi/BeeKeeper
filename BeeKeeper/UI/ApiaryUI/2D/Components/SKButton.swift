//
//  SKButton.swift
//  Bee Keeper 3
//
//  Created by Chaniel Ezzi on 1/1/21.
//  Copyright © 2021 Cezzi. All rights reserved.
//

import SpriteKit

open class SKButton: SKSpriteNode {
    private var block: (() -> Void)?
    
    convenience init(texture: SKTexture, title: String? = nil, onTap block: (() -> Void)? = nil) {
        self.init()
        self.isUserInteractionEnabled = true
        self.texture = texture
        self.normalTexture = nil
        self.block = block
        
        #if !RELEASE
        let label = SKLabelNode(text: title)
        label.isUserInteractionEnabled = false
        self.addChild(label)
        #endif
    }
    
    convenience init(imageNamed name: String, title: String? = nil, onTap block: (() -> Void)? = nil) {
        self.init(texture: SKTexture(imageNamed: name), title: title, onTap: block)
    }
    
    func activate() {
        block?()
    }
    
    func onTap(_ block: (() -> Void)?) {
        self.block = block
    }
}

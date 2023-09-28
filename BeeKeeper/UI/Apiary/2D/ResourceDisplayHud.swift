//
//  ResourceDisplayHud.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/28/23.
//

import SpriteKit

final class ResourceDisplayHud: SKNode {
    var honeyBar: ResourceBar?
    var pollenBar: ResourceBar?
    var beeBreadBar: ResourceBar?
    
    override init() {
        super.init()
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layout() {
        guard let size = scene?.frame.size else { return }
        
        let barSize = CGSize(width: size.width / 3, height: size.height / 40)
        let verticalBarSpacing = barSize.height * 0.8
        let yOffset = UIApplication.shared.windows[0].safeAreaInsets.top + verticalBarSpacing
        let xOffset = barSize.width * 0.1 + UIApplication.shared.windows[0].safeAreaInsets.right
        
        // Setup honey display
        honeyBar = ResourceBar(containing: 1, capacity: 1, color: .orange, size: barSize)
        honeyBar?.position.x = size.width - xOffset
        honeyBar?.position.y = size.height - yOffset
        addChild(honeyBar!)
        
        // Setup pollen display
        pollenBar = ResourceBar(containing: 1, capacity: 1, color: .systemYellow, size: barSize)
        pollenBar?.position.x = size.width - xOffset
        pollenBar?.position.y = (honeyBar?.frame.minY ?? size.height - yOffset) - verticalBarSpacing
        
        addChild(pollenBar!)
        
        // Setup bee bread display
        #if DEBUG
        let showBeeBread = true
        #else
        let showBeeBread = GameManager.shared.account.unlockedGenes.contains(.beeBread)
        #endif
        
        if showBeeBread {
            beeBreadBar = ResourceBar(containing: 1, capacity: 1, color: .baige, size: barSize)
            beeBreadBar?.position.x = size.width - xOffset
            beeBreadBar?.position.y = (pollenBar?.frame.minY ?? (honeyBar?.frame.minY ?? size.height - yOffset)) - verticalBarSpacing
            addChild(beeBreadBar!)
        }
    }
    
    func update() {
        let resources = GameManager.shared.getAllResources()
        let maximum = GameManager.shared.getAllResources()
        honeyBar?.updateValues(containing: Float(resources.honey), capacity: Float(maximum.honey))
        pollenBar?.updateValues(containing: Float(resources.pollen), capacity: Float(maximum.pollen))
        beeBreadBar?.updateValues(containing: Float(resources.beeBread), capacity: Float(maximum.beeBread))
    }
}

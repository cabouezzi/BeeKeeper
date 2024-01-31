//
//  ApiaryView.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import SceneKit
import SpriteKit

class ApiaryView: SCNView {
    var apiary: Apiary { GameManager.shared.apiary }
    
    private var sun: SCNLight?
    let camera: Camera
    let overlay: ApiaryOverlay
    private(set) var isDark = false
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame frameRect: CGRect) {
        camera = Camera()
        
        self.overlay = ApiaryOverlay(size: frameRect.size)
        self.overlay.isUserInteractionEnabled = false
        self.overlay.isHidden = false
        
        super.init(frame: frameRect, options: nil)
        self.scene = SCNScene(named: "BeeKeeperForest.scn")
        self.scene?.background.contents = UIColor(red: 0.5, green: 0.9, blue: 1, alpha: 1)
        self.autoenablesDefaultLighting = false
        self.overlaySKScene = overlay
        self.pointOfView = camera.pointOfView
        self.backgroundColor = .blue
        self.isPlaying = true
        #if TEST
        self.showsStatistics = true
        #endif
        
        sun = scene?.rootNode.childNode(withName: "directional", recursively: true)?.light
        
        let floorNode = SCNNode(geometry: Meshes.floor)
        floorNode.position.y -= 1
        floorNode.categoryBitMask = 1 << 1
        
        scene?.rootNode.addChildNode(camera)
        scene?.rootNode.addChildNode(floorNode)
        
        GameManager.shared.addObserver(self)
        
        Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            turnDark(5)
            isDark = true
            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(30))) { [weak self] in
                guard let self = self else { return }
                turnLight(5)
                isDark = false
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        GameManager.shared.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let scale = max((safeAreaInsets.left + safeAreaInsets.right) / frame.size.width, (safeAreaInsets.top + safeAreaInsets.bottom) / frame.size.height)
        overlay.camera?.setScale(1 + scale)
    }
    
    func loadNodes() {
        for bee in apiary.bees {
            bee.position.y += 3
            scene?.rootNode.addChildNode(bee)
        }
        
        for structure in apiary.structures {
            structure.position.x = Float(structure.area.x) + Float(structure.area.width) / 2
            structure.position.z = Float(structure.area.y) + Float(structure.area.height) / 2
            if let geometry = structure.flattenedClone().geometry {
                let shape = SCNPhysicsShape(geometry: geometry)
                structure.physicsBody = SCNPhysicsBody(type: .kinematic, shape: shape)
            }
            scene?.rootNode.addChildNode(structure)
        }
    }
    
    func showMiniscreen(_ view: UIView) {
        let background = UIButton(frame: frame)
        background.backgroundColor = .clear
        background.addAction(for: .allTouchEvents) {
            background.removeFromSuperview()
            view.removeFromSuperview()
        }
        addSubview(background)
        addSubview(view)
        bringSubviewToFront(view)
    }
    
    func turnLight(_ duration: TimeInterval) {
        guard isDark else { return }
        
        apiary.bees.forEach({ $0.wake() })
        SCNTransaction.begin()
        SCNTransaction.animationDuration = duration
        sun?.intensity = 500
        SCNTransaction.commit()
        isDark = false
    }
    
    func turnDark(_ duration: TimeInterval) {
        guard !isDark else { return }
        
        for bee in apiary.bees {
            if let hive = apiary.structures.compactMap({ $0 as? Hive }).randomElement() {
                bee.sleep(hive)
            }
        }
        SCNTransaction.begin()
        SCNTransaction.animationDuration = duration
        sun?.intensity = 0
        SCNTransaction.commit()
        isDark = true
    }
}

extension ApiaryView: GameObserver {
    func gameManager(_ account: Account, _ apiary: Apiary, didHatchBee bee: Bee) {
        bee.position.y = 3
        bee.position.x = Float.random(in: -5...5)
        scene?.rootNode.addChildNode(bee)
    }
    
    func gameManager(_ account: Account, _ apiary: Apiary, didUpdateResources resources: Resources) {
        overlay.resources.update(resources)
    }
    
    func gameManager(_ account: Account, _ apiary: Apiary, didReleaseBees bees: [Bee]) {
        bees.forEach({ $0.removeFromParentNode() })
    }
}

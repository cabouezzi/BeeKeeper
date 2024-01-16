//
//  Camera.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/16/24.
//

import SceneKit

class Camera: SCNNode {
    let pointOfView: SCNNode
    
    override var camera: SCNCamera? {
        get { pointOfView.camera }
        set { pointOfView.camera = newValue }
    }
    
    private let followConstraint = SCNDistanceConstraint(target: nil)
    
    override init() {
        let camera = SCNCamera()
        camera.usesOrthographicProjection = false
        
        pointOfView = SCNNode()
        pointOfView.camera = camera
        pointOfView.position.x += 0
        pointOfView.position.y += 15
        pointOfView.position.z += 15
        pointOfView.eulerAngles.x -= .pi / 4
        super.init()
        
        eulerAngles.y -= .pi / 4
        addChildNode(pointOfView)
        constraints = [followConstraint]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func follow(_ node: SCNNode?) {
        if let node = node {
            followConstraint.target = node
            followConstraint.maximumDistance = 0
            pointOfView.position.x = 0
            pointOfView.position.z = 15
            followConstraint.isEnabled = true
        } else {
            followConstraint.target = nil
            followConstraint.isEnabled = false
        }
    }
}

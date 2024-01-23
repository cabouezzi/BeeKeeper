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
    
    var velocity: SCNVector3 = .zero
    private var zoomFactor: Float = 20
    private var minZoom: Float = 10
    private var maxZoom: Float = 60
    
    override init() {
        let camera = SCNCamera()
        camera.usesOrthographicProjection = false
        
        pointOfView = SCNNode()
        pointOfView.camera = camera
        pointOfView.eulerAngles.x -= .pi * 0.3
        super.init()
        zoom(0)
        
        eulerAngles.y -= .pi / 4
        addChildNode(pointOfView)
        constraints = [followConstraint]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func translate(vector: SCNVector3) {
        translate(x: vector.x, y: vector.y, z: vector.z)
    }
    
    func translate(x: Float, y: Float, z: Float) {
        var translation = worldRight * x + worldUp * y + worldFront * -z
        translation *= zoomFactor
        worldPosition += translation / minZoom
        worldPosition.x.clamp(min: -25, max: 25)
        worldPosition.z.clamp(min: -25, max: 25)
    }
    
    func zoom(_ factor: Float) {
        var newZoom = zoomFactor - factor
        newZoom.clamp(min: minZoom, max: maxZoom)
        zoomFactor = newZoom
        let dir = convertVector(SCNNode.localUp, to: pointOfView)
        pointOfView.position = dir * Float(newZoom)
        pointOfView.position.y += 5
    }
    
    func follow(_ node: SCNNode?) {
        if let node = node {
            followConstraint.target = node
            followConstraint.maximumDistance = 0
            followConstraint.isEnabled = true
        } else {
            if let last = followConstraint.target {
                worldPosition = last.worldPosition
            }
            followConstraint.target = nil
            followConstraint.isEnabled = false
        }
    }
}

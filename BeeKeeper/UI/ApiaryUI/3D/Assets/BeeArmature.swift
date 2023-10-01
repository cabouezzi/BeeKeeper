//
//  BeeArmature.swift
//  Bee Keeper 4
//
//  Created by Chaniel Ezzi on 1/11/21.
//  Copyright © 2021 Cezzi. All rights reserved.
//

import SceneKit

class BeeArmature: BKNode {
    private var bodyArmature: SCNNode!
    private var wingArmature: SCNNode!
    
    var rightWing: SCNNode!
    var leftWing: SCNNode!
    
    var head: SCNNode!
    var torso: SCNNode!
    var abdomen: SCNNode!
    var stinger: SCNNode!
    
    // wing nodes too? maybe later?
    
    // materials
    var stripesMaterial: SCNMaterial!

    override init() {
        super.init()
        let bodyScene = SCNScene(named: "BeeBody.scn")!
        let wingsScene = SCNScene(named: "BeeWings.scn")!
        addChildren(bodyScene.rootNode.childNodes)
        addChildren(wingsScene.rootNode.childNodes)
        
        bodyArmature = childNode(withName: "BodyArmature", recursively: true)!
        wingArmature = childNode(withName: "WingArmature", recursively: true)!
        
        rightWing = childNode(withName: "Top-R", recursively: true)
        leftWing = childNode(withName: "Top-L", recursively: true)
        
        head = childNode(withName: "Head", recursively: true)
        torso = childNode(withName: "Torso", recursively: true)
        abdomen = childNode(withName: "Abdomen", recursively: true)
        stinger = childNode(withName: "Stinger", recursively: true)
        
        stripesMaterial = abdomen.geometry?.material(named: "Stripes")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fly () {
        let flapsPerSecond: Double = 8
        
        let flap = SCNAction.customAction(duration: 1 / flapsPerSecond) { (node, float) in
            let rotateUp = SCNAction.rotateTo(x: -20 * .pi / 180, y: CGFloat(node.eulerAngles.y), z: CGFloat(node.eulerAngles.z), duration: 1 / (flapsPerSecond * 2))
            let rotateDown = SCNAction.rotateTo(x: -160 * .pi / 180, y: CGFloat(node.eulerAngles.y), z: CGFloat(node.eulerAngles.z), duration: 1 / (flapsPerSecond * 2))
            let repeatingFlap = SCNAction.repeatForever(.sequence([rotateUp, rotateDown]))
            node.runAction(repeatingFlap)
        }
        
//        if leftWing.action(forKey: "flap") == nil {
//            leftWing.runAction(flap, forKey: "flap")
//            print("left wing isn't flapping")
//        }
//        if rightWing.action(forKey: "flap") == nil {
//            rightWing.runAction(flap, forKey: "flap")
//            print("right win isn't flapping")
//        }
        
        leftWing.runAction(flap)
        rightWing.runAction(flap)
    }
    
    func bob () {
        let moveDown = SCNAction.move(by: SCNVector3(0, -2, 0), duration: 2.5)
        let moveUp = SCNAction.move(by: SCNVector3(0, 2, 0), duration: 2.5)
        moveDown.timingMode = .easeInEaseOut
        moveUp.timingMode = .easeInEaseOut
        
        let bounceSequence = SCNAction.sequence([moveDown, moveUp])
        let bounce = SCNAction.repeatForever(bounceSequence)
        runAction(bounce)
    }
    
    func attack () {
        
    }
    
    func wiggle () {
        
    }
}

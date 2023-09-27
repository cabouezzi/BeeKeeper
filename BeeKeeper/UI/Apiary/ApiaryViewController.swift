//
//  ApiaryViewController.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import UIKit

public class ApiaryViewController: UIViewController {
    var apiaryView: ApiaryView
    
    public init() {
        self.apiaryView = ApiaryView()
#if DEBUG
//        self.apiaryView.allowsCameraControl = true
        self.apiaryView.showsStatistics = true
#endif
        super.init(nibName: nil, bundle: nil)
        self.view = apiaryView
        
        addGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        apiaryView.loadNodes()
    }
    
    // MARK: - Gesture Recognizers
    
    private func addGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panHandler))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchHandler))
        
        apiaryView.addGestureRecognizer(tap)
        apiaryView.addGestureRecognizer(pan)
        apiaryView.addGestureRecognizer(pinch)
    }
    
    @objc
    private func tapHandler (_ gestureRecognizer: UITapGestureRecognizer) {
        let point = gestureRecognizer.location(in: apiaryView)
        gestureRecognizer.numberOfTapsRequired = 1
        
        // Check and handle 2D interaction
        if let spriteNode = apiaryView.overlay.nodes(at: apiaryView.overlay.convertPoint(fromView: point)).first {
            if let button = spriteNode as? SKButton {
                button.pop()
                button.activate()
            }
            return
        }
        
        // Check and handle 3D interaction
        let hitResults = apiaryView.hitTest(point, options: [:])
        guard let node = hitResults.first?.node as? BKNode else { return }
        node.model?.accept(self)
        node.model?.accept(apiaryView.overlay)
    }
    
    private lazy var lastCameraPosition = apiaryView.cameraNode.position
    
    @objc
    private func panHandler(_ gestureRecognizer: UIPanGestureRecognizer) {
        // Translates the gesture into a number, the difference from start –> beginning
        let xTranslation = Float(gestureRecognizer.translation(in: apiaryView).x)
        let yTranslation = Float(gestureRecognizer.translation(in: apiaryView).y)
        
        // What the camera should move by
        let xSpeed = -xTranslation / 30
        let ySpeed = -yTranslation / 30
        
        apiaryView.cameraNode.position.x = lastCameraPosition.x + xSpeed
        apiaryView.cameraNode.position.z = lastCameraPosition.z + ySpeed
        
        if gestureRecognizer.state == .ended {
            lastCameraPosition = apiaryView.cameraNode.position
        }
    }
    
    @objc
    private func pinchHandler(_ gestureRecognizer: UIPinchGestureRecognizer) {
        let velocity = gestureRecognizer.velocity / 2
        
        apiaryView.cameraNode.camera?.fieldOfView -= velocity
        
        if gestureRecognizer.state == .ended {
            lastCameraPosition = apiaryView.cameraNode.position
        }
    }
}

extension ApiaryViewController: ModelVisitor {
    public func visitHoneyStorage(_ model: HoneyStorage) -> () {
        print("\(model.name) was tapped. \(model.containing) / \(model.maximum). \(GameManager.shared.getAllResources())")
    }
    
    public func visitBee(_ model: Bee) -> Void {
        print("\(model.name) was tapped")
    }
    
    public func visitHive(_ model: Hive) -> Void {
        print("\(model.name) was tapped. \(model.containing) / \(model.maximum)")
    }
}

//
//  EvolutionViewController.swift
//  Bee Keeper
//
//  Created by Chaniel Ezzi on 3/20/21.
//  Copyright © 2021 Cezzi. All rights reserved.
//

import SpriteKit

class EvolutionViewController: UIViewController {
    var evolutionView: SKView!
    var evolutionScene: SKScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        evolutionScene = SKScene(fileNamed: "EvolutionScene.sks")
        evolutionScene.backgroundColor = .black
        
        evolutionView = SKView(frame: view.frame)
        evolutionView.presentScene(evolutionScene)
        
        view = evolutionView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

//
//  TutorialViewController.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/31/24.
//

import UIKit

class TutorialViewController: ApiaryViewController {
    enum State {
        
    }
    
    func endTutorial() {
        let avc = ApiaryViewController(frame: apiaryView.frame)
        navigationController?.setViewControllers([avc], animated: false)
    }
}

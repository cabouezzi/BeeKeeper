//
//  UIView.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/27/24.
//

import UIKit

extension UIView {
    func popAnimation(duration: TimeInterval = 0.15) {
        UIView.animate(withDuration: duration / 2, animations: { [unowned self] in
            transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { [unowned self] _ in
            UIView.animate(withDuration: duration / 2) { [unowned self] in
                transform = CGAffineTransform.identity
            }
        })
    }
    
    func fadeOut(duration: TimeInterval = 1) {
        UIView.animate(withDuration: duration, animations: { [unowned self] in
            alpha = 0
        })
    }
    
    func fadeIn(duration: TimeInterval = 1) {
        UIView.animate(withDuration: duration, animations: { [unowned self] in
            alpha = 1
        })
    }
}

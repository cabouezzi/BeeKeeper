//
//  UIView.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/27/24.
//

import UIKit

extension UIView {
    func popAnimation(duration: TimeInterval = 0.15) {
        UIView.animate(withDuration: duration / 2, animations: { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { [weak self] _ in
            UIView.animate(withDuration: duration / 2) { [weak self] in
                self?.transform = CGAffineTransform.identity
            }
        })
    }
    
    func fadeOut(duration: TimeInterval = 1) {
        UIView.animate(withDuration: duration, animations: { [weak self] in
            self?.alpha = 0
        })
    }
    
    func fadeIn(duration: TimeInterval = 1) {
        UIView.animate(withDuration: duration, animations: { [weak self] in
            self?.alpha = 1
        })
    }
}

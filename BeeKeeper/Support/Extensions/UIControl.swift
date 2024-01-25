//
//  UIControl.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/22/24.
//

import UIKit

// https://stackoverflow.com/a/41438789/19571311
extension UIControl {
    func addAction(for controlEvents: UIControl.Event = .touchUpInside, _ closure: @escaping () -> Void) {
        addAction(UIAction { (action: UIAction) in closure() }, for: controlEvents)
    }
}

//
//  UILabel.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/29/24.
//

import UIKit

extension UILabel {
    func setShadow(_ color: UIColor = .black) {
        shadowOffset = CGSize(width: font.pointSize * 0.05, height: font.pointSize * 0.05)
        shadowColor = .black
    }
}

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
        shadowColor = color
    }
}

extension UITextField {
    func setShadow(_ color: UIColor = .black) {
        layer.shadowOpacity = 1
        layer.shadowRadius = 0
        layer.shadowColor = color.cgColor
        let size = font?.pointSize ?? 20
        layer.shadowOffset = CGSize(width: size * 0.05, height: size * 0.05)
    }
}

//
//  ShopTab.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 2/21/24.
//

import UIKit

class ShopTab: UIButton {
    var foregroundColor: UIColor = .white {
        didSet { setNeedsDisplay() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let imageView = imageView {
            imageView.frame = imageView.frame.insetBy(dx: 5, dy: 5)
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        context.beginPath()
        
        context.move(to: CGPoint(x: 0, y: rect.height))
        context.addCurve(to: CGPoint(x: rect.width / 2, y: 0), control1: CGPoint(x: rect.width / 10, y: 0), control2: CGPoint(x: rect.width / 10, y: 0))
        context.addCurve(to: CGPoint(x: rect.width, y: rect.height), control1: CGPoint(x: rect.width * 9 / 10, y: 0), control2: CGPoint(x: rect.width * 9 / 10, y: 0))
        context.addLine(to: CGPoint(x: 0, y: rect.height))
        
        context.closePath()
        context.setFillColor(foregroundColor.cgColor)
        context.fillPath()
        
        context.restoreGState()
    }
}

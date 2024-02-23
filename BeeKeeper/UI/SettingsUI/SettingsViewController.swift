//
//  SettingsViewController.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 2/22/24.
//

import UIKit
import SwiftUI

class SettingsViewController: UIHostingController<SettingsView> {
    let background: UIView
    private var wrappedView: UIView?
    
    init(frame: CGRect) {
        background = UIView(frame: frame)
        background.backgroundColor = .black.withAlphaComponent(0.1)
        background.isUserInteractionEnabled = true
        super.init(rootView: SettingsView())
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wrappedView = view
        guard let wrappedView = wrappedView else { return }
        var f = background.frame
        f.size.height = min(background.frame.size.height * 0.8, 500)
        f.size.width = f.size.height * 1.25
        wrappedView.frame = f
        wrappedView.center = background.center
        wrappedView.isUserInteractionEnabled = true
        wrappedView.backgroundColor = .clear
        // Swap hierarchy
        view = background
        background.addSubview(wrappedView)
        
        background.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHandler)))
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        parent?.view.addSubview(view)
    }
    
    @objc override func removeFromParent() {
        super.removeFromParent()
        view.removeFromSuperview()
    }
    
    @objc func tapHandler(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let wrappedView = wrappedView else {
            print("SwiftUI view didn't get cached into UIView in SettingsViewController")
            removeFromParent()
            return
        }
        guard !wrappedView.frame.contains(gestureRecognizer.location(in: background)) else {
            return
        }
        removeFromParent()
    }
}

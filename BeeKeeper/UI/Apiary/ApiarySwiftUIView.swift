//
//  ApiarySwiftUIView.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 9/8/23.
//

import SwiftUI

struct ApiarySwiftUIView: UIViewControllerRepresentable {
    typealias UIViewControllerType = ApiaryViewController
    
    func makeUIViewController(context: Context) -> ApiaryViewController {
        let avc = ApiaryViewController()
        let frame = UIScreen.main.bounds.size
        avc.apiaryView.overlay.size = frame
        avc.apiaryView.overlay.layoutButtons()
        return avc
    }
    
    func updateUIViewController(_ nsViewController: ApiaryViewController, context: Context) {
        guard let screen = nsViewController.apiaryView.window?.screen else { return }
        nsViewController.apiaryView.overlay.size = screen.bounds.size
    }
}

//
//  LaunchView.swift
//  BeeKeeper
//
//  Created by Chaniel Ezzi on 1/25/24.
//

import SwiftUI

struct LaunchView: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
            ProgressView("Loading")
        }
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
    }
}

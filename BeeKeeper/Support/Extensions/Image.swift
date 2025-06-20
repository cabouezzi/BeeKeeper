//
//  View.swift
//  BeeKeeper
//
//  Created by Chaniel Abou-Ezzi on 6/19/25.
//

import SwiftUI

extension Image {
  /// Sizes any resizable image to match the given text style's height.
  func iconSize(_ textStyle: UIFont.TextStyle) -> some View {
    let pt = UIFont.preferredFont(forTextStyle: textStyle).pointSize
    return self
      .resizable()
      .scaledToFit()
      .frame(width: pt, height: pt)
  }
}

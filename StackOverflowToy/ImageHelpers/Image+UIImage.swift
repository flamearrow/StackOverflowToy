//
//  Image+UIImage.swift
//  StackOverflowToy
//
//  Created by Chen Cen on 3/23/25.
//

import UIKit
import SwiftUI

extension Image {
    @MainActor func asUIImage() -> UIImage? {
        let renderer = ImageRenderer(content: self)
        return renderer.uiImage
    }
}

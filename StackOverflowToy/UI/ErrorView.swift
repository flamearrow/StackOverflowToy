//
//  ErrorView.swift
//  StackOverflowToy
//
//  Created by Chen Cen on 3/23/25.
//

import Foundation
import SwiftUI

struct ErrorView: View {
    let error: Error
    var body: some View {
        Text("Error: \(error.localizedDescription)")
            .foregroundColor(.red)
    }
}

//
//  PrimaryButtonStyle.swift
//  StackOverflowToy
//
//  Created by Chen Cen on 3/25/25.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    let icon: String
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: icon)
            configuration.label
        }
        .font(.headline)
        .foregroundColor(.white)
        .padding()
        .background(Color.blue)
        .cornerRadius(10)
        .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

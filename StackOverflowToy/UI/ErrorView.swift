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
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 200))
                .foregroundColor(.red)
            
            Text("Error")
                .font(.headline)
                .foregroundColor(.red)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

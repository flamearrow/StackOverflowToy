//
//  UserRow.swift
//  StackOverflowToy
//
//  Created by Chen Cen on 3/22/25.
//

import SwiftUI

private extension Image {
    func profileImageStyle(size: CGFloat = 44) -> some View {
        self.resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}

struct UserRow: View {
    let user: User
    
    var body: some View {
        HStack {
            AsyncImage(
                url: .init(string: user.profile_image)
            ) { phase in
                if let image = phase.image {
                    image.profileImageStyle()
                } else if phase.error != nil {
                    Image(systemName: "exclamationmark.circle.fill")
                        .profileImageStyle()
                        .foregroundColor(.red)
                } else {
                    Image(systemName: "person.circle.fill")
                        .profileImageStyle()
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.display_name)
                    .font(.headline)
                
                Label("\(user.reputation)", systemImage: "star.fill")
                    .foregroundColor(.orange)
                    .font(.caption2)
                    .labelStyle(.titleAndIcon)
                .font(.subheadline)
            }
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "medal.fill")
                    .foregroundColor(.yellow)
                Text("\(user.badge_counts.gold)")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .background(Color(.systemBackground))
        
    }
}

#Preview {
    List {
        UserRow(user: .testUser1)
        UserRow(user: .testUser2)
        UserRow(user: .testUser3)
    }
    .listStyle(.inset)
}

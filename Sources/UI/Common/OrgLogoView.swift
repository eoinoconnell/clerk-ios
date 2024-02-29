//
//  OrgLogoView.swift
//
//
//  Created by Mike Pitre on 12/18/23.
//

import SwiftUI
import NukeUI

struct OrgLogoView: View {
    @EnvironmentObject private var clerk: Clerk
    @Environment(\.clerkTheme) private var clerkTheme
    
    var body: some View {
        LazyImage(request: .init(url: URL(string: clerk.environment.displayConfig.logoImageUrl))) { state in
            if let image = state.image {
                image
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
            } else {
                Image(systemName: "circle.square.fill")
                    .resizable()
                    .scaledToFit()
            }
        }
        .foregroundStyle(clerkTheme.colors.textPrimary)
        .frame(height: 32)
        .clipped()
    }
}

#Preview {
    OrgLogoView()
}

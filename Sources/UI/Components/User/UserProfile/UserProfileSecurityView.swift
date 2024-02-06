//
//  UserProfileSecurityView.swift
//
//
//  Created by Mike Pitre on 11/16/23.
//

#if canImport(UIKit)

import SwiftUI
import ClerkSDK

struct UserProfileSecurityView: View {
    @EnvironmentObject private var clerk: Clerk
    
    private var user: User? {
        clerk.session?.user
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
                HeaderView(title: "Security")
                    .multilineTextAlignment(.leading)
                Divider()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if clerk.environment.userSettings.instanceIsPasswordBased {
                UserProfilePasswordSection()
            }
            
            if !clerk.environment.userSettings.secondFactorAttributes.isEmpty {
                UserProfileMfaSection()
            }
            
            UserProfileActiveDevicesSection()
        }
    }
}

#Preview {
    ScrollView {
        UserProfileSecurityView()
            .padding()
            .padding(.vertical)
    }
    .environmentObject(Clerk.mock)
}

#endif

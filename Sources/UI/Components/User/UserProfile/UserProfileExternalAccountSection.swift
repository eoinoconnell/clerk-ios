//
//  UserProfileExternalAccountSection.swift
//
//
//  Created by Mike Pitre on 11/3/23.
//

#if canImport(UIKit)

import SwiftUI
import Clerk
import NukeUI
import Factory
import AuthenticationServices

struct UserProfileExternalAccountSection: View {
    @EnvironmentObject private var clerk: Clerk
    @Environment(\.clerkTheme) private var clerkTheme
    @State private var addExternalAccountIsPresented = false
    @Namespace private var namespace
    
    private var user: User? {
        clerk.client.lastActiveSession?.user
    }
    
    private var externalAccounts: [ExternalAccount] {
        (user?.externalAccounts ?? []).sorted()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Connected accounts")
                .font(.footnote.weight(.medium))
                .frame(minHeight: 32)
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(externalAccounts) { externalAccount in
                    ExternalAccountRow(
                        user: user,
                        externalAccount: externalAccount,
                        namespace: namespace
                    )
                }
                
                if let user, !user.unconnectedProviders.isEmpty {
                    Button(action: {
                        addExternalAccountIsPresented = true
                    }, label: {
                        Text("+ Connect account")
                            .font(.caption.weight(.medium))
                            .tint(.primary)
                            .frame(minHeight: 32)
                    })
                }
            }
            .padding(.leading, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .sheet(isPresented: $addExternalAccountIsPresented) {
            UserProfileAddExternalAccountView()
        }
    }
    
    private struct ExternalAccountRow: View {
        let user: User?
        let externalAccount: ExternalAccount
        let namespace: Namespace.ID
        @State private var confirmationSheetIsPresented = false
        @State private var errorWrapper: ErrorWrapper?
        
        private var removeResource: RemoveResource { .externalAccount(externalAccount) }
        
        var body: some View {
            HStack(spacing: 8) {
                if let provider = externalAccount.externalProvider {
                    LazyImage(url: provider.iconImageUrl)
                        .frame(width: 16, height: 16)
                }
                
                if let providerName = externalAccount.externalProvider?.data.name {
                    Text(providerName)
                        .font(.footnote)
                }
                
                if !externalAccount.displayName.isEmpty {
                    Group {
                        Text("•")
                        Text(externalAccount.displayName)
                    }
                    .foregroundStyle(.secondary)
                    .font(.footnote)
                }
                                
                if externalAccount.verification.status != .verified {
                    CapsuleTag(text: "Requires action", style: .warning)
                }
                
                Spacer()
                
                Menu {
                    if externalAccount.verification.status != .verified {
                        retryConnectionButton
                    }
                    
                    Button("Remove connected account", role: .destructive) {
                        confirmationSheetIsPresented = true
                    }
                } label: {
                    MoreActionsView()
                }
                .tint(.primary)
            }
            .clerkErrorPresenting($errorWrapper)
            .confirmationDialog(
                Text(removeResource.messageLine1),
                isPresented: $confirmationSheetIsPresented,
                titleVisibility: .visible
            ) {
                AsyncButton(role: .destructive) {
                    do {
                        try await removeResource.deleteAction()
                    } catch {
                        dump(error)
                    }
                } label: {
                    Text(removeResource.title)
                }
            } message: {
                Text(removeResource.messageLine2)
            }
        }
        
        @ViewBuilder
        private var retryConnectionButton: some View {
            if let provider = externalAccount.externalProvider {
                AsyncButton {
                    await retryConnection(provider)
                } label: {
                    Text("Retry connection")
                }
            }
        }
        
        private func retryConnection(_ provider: OAuthProvider) async {
            do {
                let externalAccount = try await user?.addExternalAccount(provider)
                try await externalAccount?.startExternalAuth()
            } catch {
                if case ASWebAuthenticationSessionError.canceledLogin = error {
                    return
                }
                
                errorWrapper = ErrorWrapper(error: error)
                dump(error)
            }
        }
    }
}

#Preview {
    _ = Container.shared.clerk.register { .mock }
    return UserProfileExternalAccountSection()
        .padding()
        .environmentObject(Clerk.mock)
}

#endif

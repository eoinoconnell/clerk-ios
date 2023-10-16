//
//  SignInViewModifier.swift
//
//
//  Created by Mike Pitre on 10/12/23.
//

#if canImport(UIKit)

import Foundation
import SwiftUI

struct SignInViewModifier: ViewModifier, KeyboardReadable {
    @Environment(\.clerkTheme) private var clerkTheme
    
    @Binding var isPresented: Bool
    @State private var keyboardShowing = false

    func body(content: Content) -> some View {
        Group {
            switch clerkTheme.signIn.presentationStyle {
            case .sheet: sheetStyle(content: content)
            case .fullScreenCover: fullScreenCoverStyle(content: content)
            }
        }
        .onReceive(keyboardPublisher, perform: { showing in
            keyboardShowing = showing
        })
        
    }
    
    @ViewBuilder
    private func sheetStyle(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented, content: {
                ScrollView {
                    SignInView()
                        .interactiveDismissDisabled(keyboardShowing)
                        .presentationDragIndicator(.visible)
                }
            })
            // hack to get toolbar to show within sheet
            .toolbar {
                if isPresented {
                    ToolbarItem(placement: .keyboard) {
                        HStack {
                            Spacer()
                            Button("Done") {
                                hideKeyboard()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
    }
    
    @ViewBuilder
    private func fullScreenCoverStyle(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented, content: {
                ScrollView {
                    SignInView()
                        .interactiveDismissDisabled(keyboardShowing)
                        .presentationDragIndicator(.visible)
                }
            })
            // hack to get toolbar to show within fullscreen cover
            .toolbar {
                if isPresented {
                    ToolbarItem(placement: .keyboard) {
                        HStack {
                            Spacer()
                            Button("Done") {
                                hideKeyboard()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
    }
}

extension View {
    func signInView(
        isPresented: Binding<Bool>
    ) -> some View {
        modifier(SignInViewModifier(
            isPresented: isPresented
        ))
    }
}

#Preview {
    Text("SignIn")
        .signInView(isPresented: .constant(true))
        .environment(\.clerkTheme.signIn.presentationStyle, .fullScreenCover)
}

#endif

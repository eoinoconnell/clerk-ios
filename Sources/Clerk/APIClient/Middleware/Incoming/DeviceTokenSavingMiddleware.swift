//
//  DeviceTokenSavingMiddleware.swift
//  Clerk
//
//  Created by Mike Pitre on 1/8/25.
//

import Foundation
import SimpleKeychain

struct DeviceTokenSavingMiddleware {
    
    static func process(_ response: HTTPURLResponse) {
        // Set the device token from the response headers whenever received
        if let deviceToken = response.value(forHTTPHeaderField: "Authorization") {
            do {
                try SimpleKeychain(service: Clerk.shared.keychainService, accessGroup: Clerk.shared.keychainAccessGroup, accessibility: .afterFirstUnlockThisDeviceOnly)
                    .set(deviceToken, forKey: "clerkDeviceToken")
            } catch let error {
                print("Keychain Error: \(error)")
            }

        }
    }
    
}

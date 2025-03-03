//
//  HeaderMiddleware.swift
//  Clerk
//
//  Created by Mike Pitre on 1/8/25.
//

import Foundation
import SimpleKeychain

struct HeaderMiddleware {
  
  @MainActor
  static func process(_ request: inout URLRequest) async {
    
      do {
          let deviceToken = try SimpleKeychain(service: Clerk.shared.keychainService, accessGroup: Clerk.shared.keychainAccessGroup).string(forKey: "clerkDeviceToken")
          request.setValue(deviceToken, forHTTPHeaderField: "Authorization")
      } catch let error {
          print("Keychain setting token error: \(error)")
      }
      
//    // Set the device token on every request
//    if let deviceToken = try? SimpleKeychain(service: Clerk.shared.keychainService, accessGroup: Clerk.shared.keychainAccessGroup).string(forKey: "clerkDeviceToken") {
//      request.setValue(deviceToken, forHTTPHeaderField: "Authorization")
//    }
    
    if Clerk.shared.debugMode, let client = Clerk.shared.client {
      request.setValue(client.id, forHTTPHeaderField: "x-clerk-client-id")
    }
    
    request.setValue(deviceID, forHTTPHeaderField: "x-native-device-id")
  }
  
}

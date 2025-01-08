//
//  ErrorThrowingMiddleware.swift
//  Clerk
//
//  Created by Mike Pitre on 1/8/25.
//

import Foundation
import Get

struct ErrorThrowingMiddleware {
    
    static func process(_ response: HTTPURLResponse, data: Data) throws {
        
        // If our response is an error status code...
        guard (200..<300).contains(response.statusCode) else {
            
            // ...and the response has a ClerkError body throw a custom clerk error
            if let clerkError = try? JSONDecoder.clerkDecoder.decode(ClerkErrorResponse.self, from: data).errors.first {
                throw clerkError
            }

            // ...else throw a generic api error
            throw APIError.unacceptableStatusCode(response.statusCode)
        }
        
    }
    
    
}

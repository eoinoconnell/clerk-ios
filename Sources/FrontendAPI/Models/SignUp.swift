//
//  SignUp.swift
//
//
//  Created by Mike Pitre on 10/2/23.
//

import Foundation
/**
 The SignUp object holds the state of the current sign up and provides helper methods to navigate and complete the sign up flow. Once a sign up is complete, a new user is created.
 
 There are two important steps that need to be done in order for a sign up to be completed:
 
 Supply all the required fields. The required fields depend on your instance settings.
 Verify contact information. Some of the supplied fields need extra verification. These are the email address and phone number.
 The above steps can be split into smaller actions (e.g. you don't have to supply all the required fields at once) and can done in any order. This provides great flexibility and supports even the most complicated sign up flows.
 
 Also, the attributes of the SignUp object can basically be grouped into three categories:
 
 Those that contain information regarding the sign-up flow and what is missing in order for the sign-up to complete. For more information on these, check our detailed sign-up flow guide.
 Those that hold the different values that we supply to the sign-up. Examples of these are username, emailAddress, firstName, etc.
 Those that contain references to the created resources once the sign-up is complete, i.e. createdSessionId and createdUserId.
 */
public struct SignUp: Decodable {
    
    init(
        id: String = "",
        status: String? = nil
    ) {
        self.id = id
        self.status = status
    }
    
    let id: String
    
    /**
     The status of the current sign-up.
     
     The following values are supported:
     - missing_requirements: There are required fields that are either missing or they are unverified.
     - complete: All the required fields have been supplied and verified, so the sign-up is complete and a new user and a session have been created.
     - abandoned: The sign-up has been inactive for a long period of time, thus it's considered as abandoned and need to start over.
     */
    let status: String?
}

extension SignUp {
    
    public struct CreateParams: Encodable {
        public init(
            firstName: String? = nil,
            lastName: String? = nil,
            password: String? = nil,
            emailAddress: String? = nil
        ) {
            self.firstName = firstName
            self.lastName = lastName
            self.password = password
            self.emailAddress = emailAddress
        }
        
        public var firstName: String?
        public var lastName: String?
        public var password: String?
        public var emailAddress: String?
    }
    
    public struct PrepareVerificationParams: Encodable {
        public init(strategy: VerificationStrategy) {
            self.strategy = strategy.stringValue
        }
        
        public var strategy: String
    }
    
    public struct AttemptVerificationParams: Encodable {
        public init(
            strategy: VerificationStrategy,
            code: String
        ) {
            self.strategy = strategy.stringValue
            self.code = code
        }
        
        public var strategy: String
        public var code: String
    }
    
}

extension SignUp {
    
    /**
     This method initiates a new sign-up flow. It creates a new SignUp object and de-activates any existing SignUp that the client might already had in progress.
     
     The form of the given params depends on the configuration of the instance. Choices on the instance settings affect which options are available to use.
     
     The create method will return a promise of the new SignUp object. This sign up might be complete if you supply the required fields in one go.
     However, this is not mandatory. Our sign-up process provides great flexibility and allows users to easily create multi-step sign-up flows.
     */
    @MainActor
    public func create(_ params: CreateParams) async throws {
        let request = APIEndpoint
            .v1
            .client
            .signUps
            .post(params)
        
        let client = try await Clerk.apiClient.send(request).value.client
        Clerk.shared.client = client ?? Client()
    }
    
    /**
     The prepareVerification is used to initiate the verification process for a field that requires it. 
     
     As mentioned above, there are two fields that need to be verified:
     - emailAddress: The email address can be verified via an email code. This is a one-time code that is sent to the email already provided to the SignUp object. The prepareVerification sends this email.
     - phoneNumber: The phone number can be verified via a phone code. This is a one-time code that is sent via an SMS to the phone already provided to the SignUp object. The prepareVerification sends this SMS.
     */
    @MainActor
    public func prepareVerification(_ params: PrepareVerificationParams) async throws {
        guard !Clerk.shared.client.signUp.id.isEmpty else {
            throw ClerkClientError(message: "Please initiate a sign up before attempting to verify.")
        }
        
        let request = APIEndpoint
            .v1
            .client
            .signUps
            .id(Clerk.shared.client.signUp.id)
            .prepareVerification
            .post(params)
        
        let client = try await Clerk.apiClient.send(request).value.client
        Clerk.shared.client = client ?? Client()
    }
    
    /**
     Attempts to complete the in-flight verification process that corresponds to the given strategy. In order to use this method, you should first initiate a verification process by calling SignUp.prepareVerification.
     
     Depending on the strategy, the method parameters could differ.
     */
    @MainActor
    public func attemptVerification(_ params: AttemptVerificationParams) async throws {
        guard !Clerk.shared.client.signUp.id.isEmpty else {
            throw ClerkClientError(message: "Please initiate a sign up before attempting to verify.")
        }
        
        let request = APIEndpoint
            .v1
            .client
            .signUps
            .id(Clerk.shared.client.signUp.id)
            .attemptVerification
            .post(params)
        
        let client = try await Clerk.apiClient.send(request).value.client
        Clerk.shared.client = client ?? Client()
    }
}

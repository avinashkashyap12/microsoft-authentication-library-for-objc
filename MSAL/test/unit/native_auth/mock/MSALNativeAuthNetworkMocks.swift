//
// Copyright (c) Microsoft Corporation.
// All rights reserved.
//
// This code is licensed under the MIT License.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files(the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions :
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import XCTest
@testable import MSAL
@_implementationOnly import MSAL_Private

struct MSALNativeAuthNetworkStubs {

    static let tenantName = "test_tenant"

    static let requestProvider = MSALNativeAuthRequestProvider(config: MSALNativeAuthConfigStubs.configuration)

    static var authority: MSALAADAuthority {
        try! .init(
            url: .init(string: DEFAULT_TEST_AUTHORITY)!,
            rawTenant: tenantName
        )
    }

    static var msidAuthority: MSIDAADAuthority {
        try! .init(
            url: .init(string: DEFAULT_TEST_AUTHORITY)!,
            rawTenant: tenantName,
            context: nil
        )
    }
}

class MSALNativeAuthRequestContextMock: MSIDRequestContext {

    let mockCorrelationId: UUID
    var mockTelemetryRequestId = ""
    var mockLogComponent = ""
    var mockAppRequestMetadata: [AnyHashable: Any] = [:]

    init(correlationId: UUID = .init(uuidString: DEFAULT_TEST_UID)!) {
        self.mockCorrelationId = correlationId
    }

    func correlationId() -> UUID {
        return mockCorrelationId
    }

    func logComponent() -> String {
        return mockLogComponent
    }

    func telemetryRequestId() -> String {
        return mockTelemetryRequestId
    }

    func appRequestMetadata() -> [AnyHashable: Any] {
        return mockAppRequestMetadata
    }
}

class MSALNativeAuthSignInResponseValidatorMock: MSALNativeAuthSignInResponseValidating {
    
    var expectedRequestContext: MSALNativeAuthRequestContext?
    var expectedConfiguration: MSIDConfiguration?
    var expectedTokenResponse: MSIDAADTokenResponse?
    var expectedTokenResponseError: Error?
    var tokenValidatesResponse: MSALNativeAuthSignInTokenValidatedResponse = .error(.generalError)
    
    func validateSignInTokenResponse(context: MSAL.MSALNativeAuthRequestContext, msidConfiguration: MSIDConfiguration, result: Result<MSIDAADTokenResponse, Error>) -> MSAL.MSALNativeAuthSignInTokenValidatedResponse {
        if let expectedRequestContext = expectedRequestContext {
            XCTAssertEqual(expectedRequestContext.correlationId(), context.correlationId())
            XCTAssertEqual(expectedRequestContext.telemetryRequestId(), context.telemetryRequestId())
        }
        if let expectedConfiguration = expectedConfiguration {
            XCTAssertEqual(expectedConfiguration, msidConfiguration)
        }
        if case .success(let successTokenResponse) = result, let expectedTokenResponse = expectedTokenResponse {
            XCTAssertEqual(successTokenResponse.accessToken, expectedTokenResponse.accessToken)
            XCTAssertEqual(successTokenResponse.refreshToken, expectedTokenResponse.refreshToken)
            XCTAssertEqual(successTokenResponse.idToken, expectedTokenResponse.idToken)
            XCTAssertEqual(successTokenResponse.scope, expectedTokenResponse.scope)
        }
        if case .failure(let tokenResponseError) = result, let expectedTokenResponseError = expectedTokenResponseError {
            XCTAssertEqual(tokenResponseError.localizedDescription, expectedTokenResponseError.localizedDescription)
        }
        return tokenValidatesResponse
    }
    
}

class MSALNativeAuthSignInRequestProviderMock: MSALNativeAuthSignInRequestProviding {
    var throwingError: Error?
    var signInInitiateResult: MSALNativeAuthSignInInitiateRequest?
    var expectedContext: MSIDRequestContext?
    var expectedUsername: String?
    var expectedCredentialToken: String?
    var expectedChallengeTypes: [MSAL.MSALNativeAuthInternalChallengeType]?
    var signInChallengeResult: MSALNativeAuthSignInChallengeRequest?
    var expectedTokenParams: MSALNativeAuthSignInTokenRequestProviderParams?
    var signInTokenResult: MSALNativeAuthSignInTokenRequest?
    
    func signInInitiateRequest(context: MSIDRequestContext, username: String, challengeTypes: [MSAL.MSALNativeAuthInternalChallengeType]) throws -> MSAL.MSALNativeAuthSignInInitiateRequest {
        if let expectedContext = expectedContext {
            XCTAssertEqual(expectedContext.correlationId(), context.correlationId())
            XCTAssertEqual(expectedContext.telemetryRequestId(), context.telemetryRequestId())
        }
        if let expectedUsername = expectedUsername {
            XCTAssertEqual(expectedUsername, username)
        }
        if let expectedChallengeTypes = expectedChallengeTypes {
            XCTAssertEqual(expectedChallengeTypes, challengeTypes)
        }
        return try returnMockedResult(result: signInInitiateResult)
    }
    
    func signInChallengeRequest(credentialToken: String, challengeTypes: [MSAL.MSALNativeAuthInternalChallengeType]?, context: MSIDRequestContext) throws -> MSAL.MSALNativeAuthSignInChallengeRequest {
        if let expectedCredentialToken = expectedCredentialToken {
            XCTAssertEqual(expectedCredentialToken, credentialToken)
        }
        if let expectedChallengeTypes = expectedChallengeTypes {
            XCTAssertEqual(expectedChallengeTypes, challengeTypes)
        }
        return try returnMockedResult(result: signInChallengeResult)
    }
    
    func signInTokenRequest(parameters: MSAL.MSALNativeAuthSignInTokenRequestProviderParams) throws -> MSAL.MSALNativeAuthSignInTokenRequest {
        if let expectedTokenParams = expectedTokenParams {
            XCTAssertEqual(expectedTokenParams.username, parameters.username)
            XCTAssertEqual(expectedTokenParams.credentialToken, parameters.credentialToken)
            XCTAssertEqual(expectedTokenParams.signInSLT, parameters.signInSLT)
            XCTAssertEqual(expectedTokenParams.grantType, parameters.grantType)
            XCTAssertEqual(expectedTokenParams.challengeTypes, parameters.challengeTypes)
            XCTAssertEqual(expectedTokenParams.scopes, parameters.scopes)
            XCTAssertEqual(expectedTokenParams.password, parameters.password)
            XCTAssertEqual(expectedTokenParams.oobCode, parameters.oobCode)
            XCTAssertEqual(expectedTokenParams.context.correlationId(), parameters.context.correlationId())
        }
        return try returnMockedResult(result: signInTokenResult)
    }
    
    private func returnMockedResult<T: MSIDHttpRequest>(result: T?) throws -> T  {
        if let throwingError = throwingError {
            throw throwingError
        }
        if let result = result {
            return result
        }
        XCTFail("Both parameters are nil")
        throw ErrorMock.error
    }
}

class MSALNativeAuthRequestProviderMock: MSALNativeAuthRequestProviding {

    private(set) var throwingError: Error?
    private(set) var signUpRequestFuncResult: MSALNativeAuthSignUpRequest?
    private(set) var signInRequestFuncResult: MSALNativeAuthSignInRequest?
    private(set) var resendCodeRequestFuncResult: MSALNativeAuthResendCodeRequest?
    private(set) var verifyCodeRequestFuncResult: MSALNativeAuthVerifyCodeRequest?

    var mockSignUp: MSALNativeAuthRequestSignUpProviding?

    var signUp: MSAL.MSALNativeAuthRequestSignUpProviding {
        mockSignUp!
    }

    func mockSignUpRequestFunc(throwingError: Error? = nil, result: MSALNativeAuthSignUpRequest? = nil) {
        self.throwingError = throwingError
        self.signUpRequestFuncResult = result
    }

    func signUpRequest(parameters: MSAL.MSALNativeAuthSignUpParameters, context: MSIDRequestContext) throws -> MSAL.MSALNativeAuthSignUpRequest {
        if throwingError == nil && signUpRequestFuncResult == nil {
            XCTFail("Both parameters are nil")
        }

        if let error = throwingError {
            throw error
        }

        if let signUpRequestFuncResult = signUpRequestFuncResult {
            return signUpRequestFuncResult
        }

        // This will cause the tests to immediately stop execution. Make sure you're setting one param using `mockFunc()`
        return signUpRequestFuncResult!
    }

    func signUpOTPRequest(parameters: MSAL.MSALNativeAuthSignUpOTPParameters, context: MSIDRequestContext) throws -> MSAL.MSALNativeAuthSignUpRequest {
        try signUpRequest(parameters: .init(email: "", password: ""), context: context)
    }

    func mockSignInRequestFunc(throwingError: Error? = nil, result: MSALNativeAuthSignInRequest? = nil) {
        self.throwingError = throwingError
        self.signInRequestFuncResult = result
    }

    func signInRequest(parameters: MSALNativeAuthSignInParameters, context: MSIDRequestContext) throws -> MSALNativeAuthSignInRequest {
        if throwingError == nil && signInRequestFuncResult == nil {
            XCTFail("Both parameters are nil")
        }

        if let error = throwingError {
            throw error
        }

        if let signInRequestFuncResult = signInRequestFuncResult {
            return signInRequestFuncResult
        }

        // This will cause the tests to immediately stop execution. Make sure you're setting one param using `mockFunc()`
        return signInRequestFuncResult!
    }

    func signInOTPRequest(parameters: MSAL.MSALNativeAuthSignInOTPParameters, context: MSIDRequestContext) throws -> MSAL.MSALNativeAuthSignInRequest {
        try signInRequest(parameters: .init(email: "", password: ""), context: context)
    }

    func mockResendCodeRequestFunc(throwingError: Error? = nil, result: MSALNativeAuthResendCodeRequest? = nil) {
        self.throwingError = throwingError
        self.resendCodeRequestFuncResult = result
    }

    func resendCodeRequest(parameters: MSAL.MSALNativeAuthResendCodeParameters, context: MSIDRequestContext) throws -> MSAL.MSALNativeAuthResendCodeRequest {
        if throwingError == nil && resendCodeRequestFuncResult == nil {
            XCTFail("Both parameters are nil")
        }

        if let error = throwingError {
            throw error
        }

        if let resendCodeRequestFuncResult = resendCodeRequestFuncResult {
            return resendCodeRequestFuncResult
        }

        // This will cause the tests to immediately stop execution. Make sure you're setting one param using `mockFunc()`
        return resendCodeRequestFuncResult!
    }

    func mockVerifyCodeRequestFunc(throwingError: Error? = nil, result: MSALNativeAuthVerifyCodeRequest? = nil) {
        self.throwingError = throwingError
        self.verifyCodeRequestFuncResult = result
    }

    func verifyCodeRequest(parameters: MSAL.MSALNativeAuthVerifyCodeParameters, context: MSIDRequestContext) throws -> MSAL.MSALNativeAuthVerifyCodeRequest {
        if throwingError == nil && verifyCodeRequestFuncResult == nil {
            XCTFail("Both parameters are nil")
        }

        if let error = throwingError {
            throw error
        }

        if let verifyCodeRequestFuncResult = verifyCodeRequestFuncResult {
            return verifyCodeRequestFuncResult
        }

        // This will cause the tests to immediately stop execution. Make sure you're setting one param using `mockFunc()`
        return verifyCodeRequestFuncResult!
    }
}

class MSALNativeAuthResponseHandlerMock: MSALNativeAuthResponseHandling {

    private(set) var throwingError: Error?
    private(set) var handleTokenFuncResult: MSIDTokenResult?
    private(set) var handleResendCodeFuncResult: Bool?
    var expectedAccountId: MSIDAccountIdentifier?
    var expectedContext: MSIDRequestContext?
    var expectedValidateAccount: Bool?

    func mockHandleTokenFunc(throwingError: Error? = nil, result: MSIDTokenResult? = nil) {
        self.throwingError = throwingError
        self.handleTokenFuncResult = result
    }

    func handle(
        context: MSIDRequestContext,
        accountIdentifier: MSIDAccountIdentifier,
        tokenResponse: MSIDTokenResponse,
        configuration: MSIDConfiguration,
        validateAccount: Bool
    ) throws -> MSIDTokenResult {
        if throwingError == nil && handleTokenFuncResult == nil {
            XCTFail("Both parameters are nil")
        }
        if let expectedContext = expectedContext {
            XCTAssertEqual(expectedContext.correlationId(), context.correlationId())
        }
        if let expectedAccountId = expectedAccountId {
            XCTAssertEqual(expectedAccountId.displayableId, accountIdentifier.displayableId)
            XCTAssertEqual(expectedAccountId.homeAccountId, accountIdentifier.homeAccountId)
        }
        if let expectedValidateAccount = expectedValidateAccount {
            XCTAssertEqual(expectedValidateAccount, validateAccount)
        }

        if let error = throwingError {
            throw error
        }

        if let handleFuncResult = handleTokenFuncResult {
            return handleFuncResult
        }

        // This will cause the tests to immediately stop execution. Make sure you're setting one param using `mockFunc()`
        return handleTokenFuncResult!
    }

    func mockHandleResendCodeFunc(throwingError: Error? = nil, result: Bool? = nil) {
        self.throwingError = throwingError
        self.handleResendCodeFuncResult = result
    }

    func handle(
        context: MSIDRequestContext,
        resendCodeReponse: MSAL.MSALNativeAuthResendCodeRequestResponse
    ) throws -> Bool {
        if throwingError == nil && handleResendCodeFuncResult == nil {
            XCTFail("Both parameters are nil")
        }

        if let error = throwingError {
            throw error
        }

        if let handleResendCodeFuncResult = handleResendCodeFuncResult {
            return handleResendCodeFuncResult
        }

        // This will cause the tests to immediately stop execution. Make sure you're setting one param using `mockFunc()`
        return handleResendCodeFuncResult!
    }
}

class HttpModuleMockConfigurator {

    static let baseUrl = URL(string: "https://www.contoso.com")!

    static func configure(request: MSIDHttpRequest,
                          response: HTTPURLResponse? = nil,
                          responseJson: Any) {

        let parameters = ["p1": "v1"]

        var httpResponse: HTTPURLResponse!
        if response == nil {
            httpResponse = HTTPURLResponse(
                url: HttpModuleMockConfigurator.baseUrl,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )
        } else {
            httpResponse = response
        }

        var urlRequest = URLRequest(url: HttpModuleMockConfigurator.baseUrl)
        urlRequest.httpMethod = "POST"

        let testUrlResponse = MSIDTestURLResponse.request(HttpModuleMockConfigurator.baseUrl, reponse: httpResponse)
        testUrlResponse?.setUrlFormEncodedBody(parameters)
        testUrlResponse?.setResponseJSON(responseJson)
        MSIDTestURLSession.add(testUrlResponse)

        request.urlRequest = urlRequest
        request.parameters = parameters
    }
}

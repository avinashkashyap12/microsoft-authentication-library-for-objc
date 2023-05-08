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

import Foundation

import XCTest
@testable import MSAL
@_implementationOnly import MSAL_Private

final class MSALNativeAuthSignInTokenRequestParametersTest: XCTestCase {
    let baseUrl = URL(string: DEFAULT_TEST_AUTHORITY)!
    var config: MSALNativeAuthConfiguration! = nil
    private let context = MSALNativeAuthRequestContextMock(
        correlationId: .init(uuidString: DEFAULT_TEST_UID)!
    )

    func testMakeEndpointUrl_whenRightUrlStringIsUsed_noExceptionThrown() {
        XCTAssertNoThrow(config = try .init(clientId: DEFAULT_TEST_CLIENT_ID, authority: MSALAADAuthority(url: baseUrl, rawTenant: "tenant"), challengeTypes: [.password]))
        let parameters = MSALNativeAuthSignInTokenRequestParameters(config:config,
                                                                    context: MSALNativeAuthRequestContextMock(),
                                                                    username: "username",
                                                                    credentialToken: "Test Credential Token",
                                                                    signInSLT: "Test SignIn SLT",
                                                                    grantType: .password,
                                                                    challengeTypes: [.redirect],
                                                                    scope: "scope",
                                                                    password: "password",
                                                                    oobCode: "Test OTP Code")
        var resultUrl: URL? = nil
        XCTAssertNoThrow(resultUrl = try parameters.makeEndpointUrl())
        XCTAssertEqual(resultUrl?.absoluteString, "https://login.microsoftonline.com/tenant/oauth2/v2.0/token")
    }

    func test_passwordParameters_shouldCreateCorrectBodyRequest() throws {
        XCTAssertNoThrow(config = try .init(clientId: DEFAULT_TEST_CLIENT_ID, authority: MSALAADAuthority(url: baseUrl, rawTenant: "tenant"), challengeTypes: [.password]))
        let params = MSALNativeAuthSignInTokenRequestParameters(
            config: config,
            context: context,
            username: DEFAULT_TEST_ID_TOKEN_USERNAME,
            credentialToken: "Test Credential Token",
            signInSLT: "Test SignIn SLT",
            grantType: .password,
            challengeTypes: [.redirect],
            scope: "<scope-1>",
            password: "password",
            oobCode: "oob"
        )

        let body = params.makeRequestBody()

        let expectedBodyParams = [
            "client_id": DEFAULT_TEST_CLIENT_ID,
            "username": DEFAULT_TEST_ID_TOKEN_USERNAME,
            "credential_token": "Test Credential Token",
            "signin_slt": "Test SignIn SLT",
            "grant_type": "password",
            "challenge_type": "password",
            "scope": "<scope-1>",
            "password": "password",
            "oob": "oob"
        ]

        XCTAssertEqual(body, expectedBodyParams)
    }

    func test_nilParameters_shouldCreateCorrectParameters() throws {
        XCTAssertNoThrow(config = try .init(clientId: DEFAULT_TEST_CLIENT_ID, authority: MSALAADAuthority(url: baseUrl, rawTenant: "tenant"), challengeTypes: [.password, .redirect]))
        let params = MSALNativeAuthSignInTokenRequestParameters(
            config: config,
            context: context,
            username: nil,
            credentialToken: nil,
            signInSLT: nil,
            grantType: .password,
            challengeTypes: [.redirect],
            scope: nil,
            password: nil,
            oobCode: nil
        )

        let body = params.makeRequestBody()

        let expectedBodyParams = [
            "client_id": params.config.clientId,
            "grant_type": "password"
        ]

        XCTAssertEqual(body, expectedBodyParams)
    }
}

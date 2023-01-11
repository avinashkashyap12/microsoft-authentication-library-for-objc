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

@_implementationOnly import MSAL_Private

protocol MSALNativeTokenResponseValidating {

    var defaultValidator: MSIDTokenResponseValidator { get }
    var factory: MSIDOauth2Factory { get }
    var context: MSIDRequestContext { get }
    var configuration: MSIDConfiguration { get }
    var accountIdentifier: MSIDAccountIdentifier { get }

    func validateResponse(_ tokenResponse: MSIDTokenResponse) throws -> MSIDTokenResult
    func validateAccount(with tokenResult: MSIDTokenResult, error: inout NSError?) -> Bool
}

final class MSALNativeTokenResponseValidator: MSALNativeTokenResponseValidating {

    // MARK: - Variables

    let defaultValidator: MSIDTokenResponseValidator
    let factory: MSIDOauth2Factory
    let context: MSIDRequestContext
    let configuration: MSIDConfiguration
    let accountIdentifier: MSIDAccountIdentifier

    // MARK: - Init

    init(
        defaultValidator: MSIDTokenResponseValidator = MSIDTokenResponseValidator(),
        factory: MSIDOauth2Factory,
        context: MSIDRequestContext,
        configuration: MSIDConfiguration,
        accountIdentifier: MSIDAccountIdentifier
    ) {
        self.defaultValidator = defaultValidator
        self.factory = factory
        self.context = context
        self.configuration = configuration
        self.accountIdentifier = accountIdentifier
    }

    // MARK: - Internal

    func validateResponse(_ tokenResponse: MSIDTokenResponse) throws -> MSIDTokenResult {
        var validationError: NSError?

        let tokenResult = defaultValidator.validate(
            tokenResponse,
            oauthFactory: factory,
            configuration: configuration,
            requestAccount: accountIdentifier,
            correlationID: context.correlationId(),
            error: &validationError
        )

        // Special case - need to return homeAccountId in case of Intune policies required.

        if let error = validationError, error.code == MSIDErrorCode.serverProtectionPoliciesRequired.rawValue {
            MSALLogger.log(level: .warning, context: context, format: "Received Protection Policy Required error.")
            throw MSALNativeError.serverProtectionPoliciesRequired(homeAccountId: accountIdentifier.homeAccountId)
        }

        guard let tokenResult = tokenResult else {
            MSALLogger.log(level: .error, context: context, format: "TokenResult is nil after validation.")
            throw MSALNativeError.validationError
        }

        return tokenResult
    }

    func validateAccount(with tokenResult: MSIDTokenResult, error: inout NSError?) -> Bool {
        return defaultValidator.validateAccount(
            accountIdentifier,
            tokenResult: tokenResult,
            correlationID: context.correlationId(),
            error: &error
        )
    }
}

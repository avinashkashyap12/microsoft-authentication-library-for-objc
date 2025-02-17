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

protocol MSALNativeAuthResetPasswordRequestProviding {
    func start(
        parameters: MSALNativeAuthResetPasswordStartRequestProviderParameters
    ) throws -> MSIDHttpRequest

    func challenge(
        token: String,
        context: MSIDRequestContext
    ) throws -> MSIDHttpRequest

    func `continue`(
        parameters: MSALNativeAuthResetPasswordContinueRequestParameters
    ) throws -> MSIDHttpRequest

    func submit(
        parameters: MSALNativeAuthResetPasswordSubmitRequestParameters
    ) throws -> MSIDHttpRequest

    func pollCompletion(
        parameters: MSALNativeAuthResetPasswordPollCompletionRequestParameters
    ) throws -> MSIDHttpRequest
}

final class MSALNativeAuthResetPasswordRequestProvider: MSALNativeAuthResetPasswordRequestProviding {

    // MARK: - Variables
    private let requestConfigurator: MSALNativeAuthRequestConfigurator
    private let telemetryProvider: MSALNativeAuthTelemetryProviding

    // MARK: - Init

    init(
        requestConfigurator: MSALNativeAuthRequestConfigurator,
        telemetryProvider: MSALNativeAuthTelemetryProviding = MSALNativeAuthTelemetryProvider()
    ) {
        self.requestConfigurator = requestConfigurator
        self.telemetryProvider = telemetryProvider
    }

    // MARK: - Reset Password Start

    func start(
        parameters: MSALNativeAuthResetPasswordStartRequestProviderParameters
    ) throws -> MSIDHttpRequest {

        let requestParams = MSALNativeAuthResetPasswordStartRequestParameters(
            context: parameters.context,
            username: parameters.username
        )

        let request = MSIDHttpRequest()
        try requestConfigurator.configure(configuratorType: .resetPassword(.start(requestParams)),
                                      request: request,
                                      telemetryProvider: telemetryProvider)
        return request
    }

    // MARK: - Reset Password Challenge

    func challenge(token: String, context: MSIDRequestContext) throws -> MSIDHttpRequest {
        let requestParams = MSALNativeAuthResetPasswordChallengeRequestParameters(
            context: context,
            passwordResetToken: token
        )

        let request = MSIDHttpRequest()
        try requestConfigurator.configure(configuratorType: .resetPassword(.challenge(requestParams)),
                                      request: request,
                                      telemetryProvider: telemetryProvider)
        return request
    }

    // MARK: - Reset Password Continue

    func `continue`(
        parameters: MSALNativeAuthResetPasswordContinueRequestParameters
    ) throws -> MSIDHttpRequest {

        let request = MSIDHttpRequest()
        try requestConfigurator.configure(configuratorType: .resetPassword(.continue(parameters)),
                                      request: request,
                                      telemetryProvider: telemetryProvider)
        return request
    }

    // MARK: - Reset Password Submit

    func submit(
        parameters: MSALNativeAuthResetPasswordSubmitRequestParameters
    ) throws -> MSIDHttpRequest {

        let request = MSIDHttpRequest()
        try requestConfigurator.configure(configuratorType: .resetPassword(.submit(parameters)),
                                      request: request,
                                      telemetryProvider: telemetryProvider)
        return request
    }

    // MARK: - Reset Password Poll Completion

    func pollCompletion(
        parameters: MSALNativeAuthResetPasswordPollCompletionRequestParameters
    ) throws -> MSIDHttpRequest {

        let request = MSIDHttpRequest()
        try requestConfigurator.configure(configuratorType: .resetPassword(.pollCompletion(parameters)),
                                      request: request,
                                      telemetryProvider: telemetryProvider)
        return request
    }
}

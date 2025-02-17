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
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

@objcMembers
public class SignUpBaseState: MSALNativeAuthBaseState {
    let controller: MSALNativeAuthSignUpControlling
    let username: String
    let inputValidator: MSALNativeAuthInputValidating

    init(
        controller: MSALNativeAuthSignUpControlling,
        username: String,
        flowToken: String,
        inputValidator: MSALNativeAuthInputValidating = MSALNativeAuthInputValidator(),
        correlationId: UUID
    ) {
        self.controller = controller
        self.username = username
        self.inputValidator = inputValidator
        super.init(flowToken: flowToken, correlationId: correlationId)
    }
}

/// An object of this type is created when a user is required to supply a verification code to continue a sign up flow.
@objcMembers public class SignUpCodeRequiredState: SignUpBaseState {
    /// Requests the server to resend the verification code to the user.
    /// - Parameter delegate: Delegate that receives callbacks for the operation.
    public func resendCode(delegate: SignUpResendCodeDelegate) {
        Task {
            let result = await resendCodeInternal()

            switch result {
            case .codeRequired(let newState, let sentTo, let channelTargetType, let codeLength):
                await delegate.onSignUpResendCodeCodeRequired(
                    newState: newState,
                    sentTo: sentTo,
                    channelTargetType: channelTargetType,
                    codeLength: codeLength
                )
            case .error(let error):
                await delegate.onSignUpResendCodeError(error: error)
            }
        }
    }

    /// Submits the code to the server for verification.
    /// - Parameters:
    ///   - code: Verification code that the user supplies.
    ///   - delegate: Delegate that receives callbacks for the operation.
    public func submitCode(code: String, delegate: SignUpVerifyCodeDelegate) {
        Task {
            let controllerResponse = await submitCodeInternal(code: code)

            switch controllerResponse.result {
            case .completed(let state):
                await delegate.onSignUpCompleted(newState: state)
            case .passwordRequired(let state):
                if let function = delegate.onSignUpPasswordRequired {
                    controllerResponse.telemetryUpdate?(.success(()))
                    await function(state)
                } else {
                    let error = VerifyCodeError(type: .generalError, message: MSALNativeAuthErrorMessage.delegateNotImplemented)
                    controllerResponse.telemetryUpdate?(.failure(error))
                    await delegate.onSignUpVerifyCodeError(error: error, newState: nil)
                }
            case .attributesRequired(let attributes, let state):
                if let function = delegate.onSignUpAttributesRequired {
                    controllerResponse.telemetryUpdate?(.success(()))
                    await function(attributes, state)
                } else {
                    let error = VerifyCodeError(type: .generalError, message: MSALNativeAuthErrorMessage.delegateNotImplemented)
                    controllerResponse.telemetryUpdate?(.failure(error))
                    await delegate.onSignUpVerifyCodeError(error: error, newState: nil)
                }
            case .error(let error, let state):
                await delegate.onSignUpVerifyCodeError(error: error, newState: state)
            }
        }
    }
}

/// An object of this type is created when a user is required to supply a password to continue a sign up flow.
@objcMembers public class SignUpPasswordRequiredState: SignUpBaseState {

    /// Submits the password to the server for verification.
    /// - Parameters:
    ///   - password: Password that the user supplied.
    ///   - delegate: Delegate that receives callbacks for the operation.
    public func submitPassword(password: String, delegate: SignUpPasswordRequiredDelegate) {
        Task {
            let controllerResponse = await submitPasswordInternal(password: password)

            switch controllerResponse.result {
            case .completed(let state):
                await delegate.onSignUpCompleted(newState: state)
            case .attributesRequired(let attributes, let state):
                if let function = delegate.onSignUpAttributesRequired {
                    controllerResponse.telemetryUpdate?(.success(()))
                    await function(attributes, state)
                } else {
                    let error = PasswordRequiredError(type: .generalError, message: MSALNativeAuthErrorMessage.delegateNotImplemented)
                    controllerResponse.telemetryUpdate?(.failure(error))
                    await delegate.onSignUpPasswordRequiredError(error: error, newState: nil)
                }
            case .error(let error, let state):
                await delegate.onSignUpPasswordRequiredError(error: error, newState: state)
            }
        }
    }
}

/// An object of this type is created when a user is required to supply attributes to continue a sign up flow.
@objcMembers public class SignUpAttributesRequiredState: SignUpBaseState {
    /// Submits the attributes to the server for verification.
    /// - Parameters:
    ///   - attributes: Dictionary of attributes that the user supplied.
    ///   - delegate: Delegate that receives callbacks for the operation.
    public func submitAttributes(
        attributes: [String: Any],
        delegate: SignUpAttributesRequiredDelegate
    ) {
        Task {
            let result = await submitAttributesInternal(attributes: attributes)

            switch result {
            case .completed(let state):
                await delegate.onSignUpCompleted(newState: state)
            case .error(let error):
                await delegate.onSignUpAttributesRequiredError(error: error)
            case .attributesRequired(let attributes, let state):
                await delegate.onSignUpAttributesRequired(attributes: attributes, newState: state)
            case .attributesInvalid(let attributes, let state):
                await delegate.onSignUpAttributesInvalid(attributeNames: attributes, newState: state)
            }
        }
    }
}

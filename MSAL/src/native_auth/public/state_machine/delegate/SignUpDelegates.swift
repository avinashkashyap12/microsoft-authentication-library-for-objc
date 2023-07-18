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

@objc
public protocol SignUpPasswordStartDelegate {
    /// Notifies the delegate that the operation resulted in an error.
    /// - Parameter error: An error object indicating why the operation failed.
    func onSignUpPasswordError(error: SignUpPasswordStartError)

    /// Notifies the delegate that a verification code is required from the user to continue.
    /// - Parameters:
    ///   - newState: An object representing the new state of the flow with follow on methods.
    ///   - sentTo: The email/phone number that the code was sent to.
    ///   - channelTargetType: The channel (email/phone) the code was sent through.
    ///   - codeLength: The length of the code required.
    func onSignUpCodeRequired(newState: SignUpCodeRequiredState,
                              sentTo: String,
                              channelTargetType: MSALNativeAuthChannelType,
                              codeLength: Int)
}

@objc
public protocol SignUpStartDelegate {
    /// Notifies the delegate that the operation resulted in an error.
    /// - Parameter error: An error object indicating why the operation failed.
    func onSignUpError(error: SignUpStartError)

    /// Notifies the delegate that a verification code is required from the user to continue.
    /// - Parameters:
    ///   - newState: An object representing the new state of the flow with follow on methods.
    ///   - sentTo: The email/phone number that the code was sent to.
    ///   - channelTargetType: The channel (email/phone) the code was sent through.
    ///   - codeLength: The length of the code required.
    func onSignUpCodeRequired(newState: SignUpCodeRequiredState,
                              sentTo: String,
                              channelTargetType: MSALNativeAuthChannelType,
                              codeLength: Int)
}

@objc
public protocol SignUpVerifyCodeDelegate {
    /// Notifies the delegate that the operation resulted in an error.
    /// - Parameters:
    ///   - error: An error object indicating why the operation failed.
    ///   - newState: An object representing the new state of the flow with follow on methods.
    func onSignUpVerifyCodeError(error: VerifyCodeError, newState: SignUpCodeRequiredState?)

    /// Notifies the delegate that attributes are required from the user to continue.
    /// - Note: If a flow requires attributes but this optional method is not implemented, then ``onSignUpVerifyCodeError(error:newState:)`` will be called.
    /// - Parameter newState: An object representing the new state of the flow with follow on methods.
    @objc optional func onSignUpAttributesRequired(newState: SignUpAttributesRequiredState)

    /// Notifies the delegate that a password is required from the user to continue.
    /// - Note: If a flow requires a password but this optional method is not implemented, then ``onSignUpVerifyCodeError(error:newState:)`` will be called.
    /// - Parameter newState: An object representing the new state of the flow with follow on methods.
    @objc optional func onSignUpPasswordRequired(newState: SignUpPasswordRequiredState)

    /// Notifies the delegate that the sign up operation completed successfully.
    /// - Parameter newState: An object representing the new state of the flow with follow on methods.
    func onSignUpCompleted(newState: SignInAfterSignUpState)
}

@objc
public protocol SignUpResendCodeDelegate {
    /// Notifies the delegate that the operation resulted in an error.
    /// - Parameter error: An error object indicating why the operation failed.
    func onSignUpResendCodeError(error: ResendCodeError)

    /// Notifies the delegate that a verification code is required from the user to continue.
    /// - Parameters:
    ///   - newState: An object representing the new state of the flow with follow on methods.
    ///   - sentTo: The email/phone number that the code was sent to.
    ///   - channelTargetType: The channel (email/phone) the code was sent through.
    ///   - codeLength: The length of the code required.
    func onSignUpResendCodeCodeRequired(
        newState: SignUpCodeRequiredState,
        sentTo: String,
        channelTargetType: MSALNativeAuthChannelType,
        codeLength: Int
    )
}

@objc
public protocol SignUpPasswordRequiredDelegate {
    /// Notifies the delegate that the operation resulted in an error.
    /// - Parameters:
    ///   - error: An error object indicating why the operation failed.
    ///   - newState: An object representing the new state of the flow with follow on methods.
    func onSignUpPasswordRequiredError(error: PasswordRequiredError, newState: SignUpPasswordRequiredState?)

    /// Notifies the delegate that attributes are required from the user to continue.
    /// - Note: If a flow requires attributes but this optional method is not implemented, then ``onSignUpPasswordRequiredError(error:newState:)`` will be called.
    /// - Parameter newState: An object representing the new state of the flow with follow on methods.
    @objc optional func onSignUpAttributesRequired(newState: SignUpAttributesRequiredState)

    /// Notifies the delegate that the sign up operation completed successfully.
    /// - Parameter newState: An object representing the new state of the flow with follow on methods.
    func onSignUpCompleted(newState: SignInAfterSignUpState)
}

@objc
public protocol SignUpAttributesRequiredDelegate {
    /// Notifies the delegate that the operation resulted in an error.
    /// - Parameters:
    ///   - error: An error object indicating why the operation failed.
    ///   - newState: An object representing the new state of the flow with follow on methods.
    func onSignUpAttributesRequiredError(error: AttributesRequiredError, newState: SignUpAttributesRequiredState?)

    /// Notifies the delegate that the sign up operation completed successfully.
    /// - Parameter newState: An object representing the new state of the flow with follow on methods.
    func onSignUpCompleted(newState: SignInAfterSignUpState)
}

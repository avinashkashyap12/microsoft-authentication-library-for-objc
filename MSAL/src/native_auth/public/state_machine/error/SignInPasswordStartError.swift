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
public class SignInPasswordStartError: MSALNativeAuthError {
    let type: SignInPasswordStartErrorType

    init(type: SignInPasswordStartErrorType, message: String? = nil) {
        self.type = type
        super.init(identifier: type.rawValue, message: message)
    }

    /// Describes an error that provides messages describing why an error occurred and provides more information about the error.
    public override var errorDescription: String? {
        return super.errorDescription ?? type.rawValue
    }

    /// Returns `true` if the error requires to use a browser.
    public var isBrowserRequired: Bool {
        return type == .browserRequired
    }

    /// Returns `true` if the user that is trying to sign in cannot be found.
    public var isUserNotFound: Bool {
        return type == .userNotFound
    }

    /// Returns `true` when the password introduced is not valid.
    public var isInvalidPassword: Bool {
        return type == .invalidPassword
    }

    /// Returns `true` when the username introduced is not valid.
    public var isInvalidUsername: Bool {
        return type == .invalidUsername
    }
}

public enum SignInPasswordStartErrorType: String, CaseIterable {
    case browserRequired = "Browser required"
    case userNotFound = "User not found"
    case invalidPassword = "Invalid password"
    case invalidUsername = "Invalid username"
    case generalError = "General error"
}

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

// swiftlint:disable:next type_name
struct MSALNativeAuthSignInChallengeRequestResponse: Decodable {

    // MARK: - Variables
    let credentialToken: String?
    let challengeType: MSALNativeAuthChallengeType
    let bindingMethod: String?
    let displayName: String?
    let displayType: String?
    let codeLength: String?
    let interval: Double

    enum CodingKeys: String, CodingKey {
        case credentialToken = "credential_token"
        case challengeType = "challenge_type"
        case bindingMethod = "binding_method"
        case displayName = "display_name"
        case displayType = "display_type"
        case codeLength = "code_length"
        case interval = "interval"
    }
}

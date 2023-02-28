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

final class MSALNativeAuthVerifyCodeRequest: MSIDHttpRequest {

    init(params: MSALNativeAuthVerifyCodeRequestParameters) throws {
        super.init()

        self.context = params.context

        self.parameters = makeBodyRequestParameters(with: params)

        let url = try params.makeEndpointUrl()
        self.urlRequest = URLRequest(url: url)

        self.urlRequest?.httpMethod = MSALParameterStringForHttpMethod(.POST)
    }

    func configure(
        requestConfigurator: MSIDHttpRequestConfiguratorProtocol = MSIDAADRequestConfigurator(),
        requestSerializer: MSIDRequestSerialization,
        serverTelemetry: MSIDHttpRequestServerTelemetryHandling
    ) {
        self.serverTelemetry = serverTelemetry
        self.requestSerializer = requestSerializer
        requestConfigurator.configure(self)
    }

    private func makeBodyRequestParameters(with params: MSALNativeAuthVerifyCodeRequestParameters) -> [String: String] {
        typealias Key = MSALNativeAuthRequestParametersKey

        return [
            Key.clientId.rawValue: params.clientId,
            Key.flowToken.rawValue: params.credentialToken,
            Key.otp.rawValue: params.otp
        ]
    }
}

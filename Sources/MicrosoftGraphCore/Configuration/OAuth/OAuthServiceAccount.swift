//
//  File.swift
//  
//
//  Created by vine on 2021/1/4.
//

import Foundation
import NIOHTTP1
import AsyncHTTPClient
import NIO

public final class OAuthServiceAccount: OAuthRefreshable {
    public let httpClient: HTTPClient
    public let credentials: MsGraphAccountCredentials
    public let eventLoop: EventLoop
    
    public let scope: String
    
    private let decoder = JSONDecoder()
    
    init(credentials: MsGraphAccountCredentials, scopes: [MsGraphAPIScope] = [MsGraphDefaultScope.defalut], httpClient: HTTPClient, eventLoop: EventLoop) {
        self.credentials = credentials
        self.httpClient = httpClient
        self.eventLoop = eventLoop
        self.scope = scopes.map { $0.value }.joined(separator: " ")
    }
    
    public func refresh() async throws -> OAuthAccessToken {
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"]
        let bodyBuffer: ByteBuffer = .init(string:"client_id=\(credentials.client_id)&scope=\(scope)&client_secret=\(credentials.secret)&grant_type=\("client_credentials")"
                                    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
        let tokenUrl = MsGraphOauthTokenUrl.replacingOccurrences(of: "{tenant}", with: "\(credentials.tenant_id)", range: nil)
        var request = HTTPClientRequest(url: tokenUrl)
        request.method = .POST
        request.headers = headers
        request.body = .bytes(bodyBuffer)
        
        let response = try await httpClient.execute(request, timeout: .seconds(30))
        
        var byteBuffer = try await response.body.reduce(into: ByteBuffer()) { accumulatingBuffer, nextBuffer in
            var nextBuffer = nextBuffer
            accumulatingBuffer.writeBuffer(&nextBuffer)
        }
        
        guard let responseData = byteBuffer.readData(length: byteBuffer.readableBytes),
              response.status == .ok else {
            throw OauthRefreshError.noResponse(response.status)
        }
        let tokenModel = try self.decoder.decode(OAuthAccessToken.self, from: responseData)
        return tokenModel
    }
}

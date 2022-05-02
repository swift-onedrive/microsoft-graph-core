//
//  File.swift
//  
//
//  Created by vine on 2021/1/4.
//

import Foundation

public struct MsGraphAccountCredentials: Codable {
    public let tenant_id: String
    public let client_id: String
    public let secret: String
    
    /// 配置凭证, 应用概述
    /// - Parameters:
    ///   - tenantId: 目录(租户) ID
    ///   - clientId: 应用程序(客户端) ID
    ///   - secret: 证书和密码，值
    public init(tenantId: String, clientId: String, secret: String ) {
        self.tenant_id = tenantId
        self.client_id = clientId
        self.secret = secret
    }
}

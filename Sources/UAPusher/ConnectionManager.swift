import Foundation
import HTTP
import TLS
import Vapor

public final class ConnectionManager {
    static let baseUrl = "https://go.urbanairship.com"
    private let client: ClientProtocol
    private let config: UAPusherConfig
    
    public init(
        config: UAPusherConfig,
        clientFactory: ClientFactoryProtocol
    ) throws {
        client = try clientFactory.makeClient(
            hostname: ConnectionManager.baseUrl,
            port: 443,
            securityLayer: .tls(Context(.client))
        )
        self.config = config
    }
    
    /// Defines the headers of the request with the given appKey and
    /// masterSecret
    ///
    /// - Parameters:
    ///   - appKey: UA applicatication key
    ///   - masterSecret: UA master secret key
    /// - Returns: array of HeaderKey
    func defineHeaders(appKey: String, masterSecret: String) -> [HeaderKey: String] {
        
        let username = appKey
        let password = masterSecret
        let loginString = username + ":" + password
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        let headers = [
            HeaderKey("Accept"): "application/vnd.urbanairship+json; version=3;",
            HeaderKey("Content-Type"): "application/json",
            HeaderKey("Authorization"): "Basic \(base64LoginString)"
        ]
        
        return headers
    }
    
    /// This will send the POST request to each of the defined
    /// applicationGroups and the applications defined by them
    ///
    /// - Parameters:
    ///   - slug: endpoint
    ///   - content: JSON content
    /// - Returns: array of Status for each request made
    /// - Throws: if POST fails
    func post(slug: String, content: JSON) throws -> [Response] {
        let url = ConnectionManager.baseUrl + slug
        let body = content.makeBody()
        
        var responses: [Response] = []
        
        for applicationGroup in self.config.applicationGroups {
            
            for application in applicationGroup.applications {
                
                let headers = defineHeaders(
                    appKey: application.appKey,
                    masterSecret: application.masterSecret
                )

                let uaResponse = try client.post(
                    url,
                    query: [:],
                    headers,
                    body
                )
                
                responses.append(uaResponse)
            }
        }
        
        return responses
    }
}

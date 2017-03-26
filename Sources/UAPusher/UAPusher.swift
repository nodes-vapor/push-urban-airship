import Vapor
import Foundation
import HTTP

public final class UAPusher {
    
    public let config: UAPusherConfig
    public let connectionManager: ConnectionMananger
    public let drop: Droplet
    
    public convenience init(drop: Droplet) throws {
        let uaPusherConfig = try UAPusherConfig(drop: drop)
        let connectionManager = ConnectionMananger(drop: drop, config: uaPusherConfig)
        
        try self.init(config: uaPusherConfig, connectionMananger: connectionManager, drop: drop)
    }
    
    public init(config: UAPusherConfig, connectionMananger: ConnectionMananger, drop: Droplet) throws {
        self.config = config
        self.connectionManager = connectionMananger
        self.drop = drop
    }
    
    public func send(request: UARequest) throws -> Status {
        
        //Add more defensive coding here
        
        let responses = try self.connectionManager.post(slug: "/api/push", content: request.getBody())
        
        for response in responses {
            
            if response != .accepted {
                throw Abort.custom(status: response, message: "UA request was not OK")
            }
            
        }
        
        return .accepted
    }
}

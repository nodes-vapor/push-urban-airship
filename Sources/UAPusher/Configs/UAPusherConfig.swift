import Vapor

public struct UAPusherConfig {
    var applicationGroups: [ApplicationGroup] = []
    
    public init(config: Config) throws {
        guard let pusherConfig: Config = config["uapusher"] else {
            throw Abort(
                .internalServerError,
                metadata: nil,
                reason: "UAPusher error - uapusher.json config is missing."
            )
        }

        guard let applicationGroups = pusherConfig["applicationGroups"]?.object else {
            throw Abort(
                .internalServerError,
                metadata: nil,
                reason: "UAPusher error - applicationGroups are not set."
            )
        }
        
        if (applicationGroups.count < 1){
            throw Abort(
                .internalServerError,
                metadata: nil,
                reason: "UAPusher error - there are no applicationGroups."
            )
        }
        
        for applicationGroup in applicationGroups {
            
            var group = ApplicationGroup(name: applicationGroup.key, applications: [])
            
            // Try to get the apps inside the  applicationGroup
            guard let applications = applicationGroup.value.object else {
                throw Abort(
                    .internalServerError,
                    metadata: nil,
                    reason: "UAPusher error - applicationGroup is missing applications."
                )
            }
            
            for application in applications {
                
                let appName = application.key
                
                guard let masterSecret = application.value.object?["masterSecret"]?.string else {
                    throw Abort(
                        .internalServerError,
                        metadata: nil,
                        reason: "UAPusher error - application is missing masterSecret."
                    )
                }
                
                guard let appKey = application.value.object?["appKey"]?.string else {
                    throw Abort(
                        .internalServerError,
                        metadata: nil,
                        reason: "UAPusher error - application is missing appKey."
                    )
                }
                
                group.applications.append(
                    Application(
                        name: appName,
                        masterSecret: masterSecret,
                        appKey: appKey
                    )
                )
            }
            
            // Store the group
            self.applicationGroups.append(group)
        }
    }
}

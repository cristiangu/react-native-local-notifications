import Foundation
import UserNotifications

public typealias guuMethodNSDictionaryBlock = ((any Error)?, [AnyHashable : Any]?) -> Void

let kGuuUserInfoNotification = "__guulabs_notification"
let kGuuUserInfoTrigger = "__guulabs_trigger"

enum CoreEventType : Int {
    case dismissed = 0
    case delivered = 3
    case triggerNotificationCreated = 7
}

//@objc public protocol CoreDelegate: NSObjectProtocol {
//    @objc optional func didReceiveGuuCoreEvent(_ event: NSDictionary)
//}

@objc public class CoreGuu: NSObject {
    
    @objc public class func setCoreDelegate(_ coreDelegate: (any CoreDelegate)?) {
        CoreDelegateHolder.shared.delegate = coreDelegate
    }
    
    @objc public static func parseDataFromUserInfo(_ userInfo: [String: Any]) -> [String: Any] {
        var data = [String: Any]()
        for (key, value) in userInfo {
            // build data dict from remaining keys but skip keys that shouldn't be included in data
            if key == "aps" || key.hasPrefix("gcm.") || key.hasPrefix("google.") ||
                // guu or guu_options
                key.hasPrefix("guu") ||
                // fcm_options
                key.hasPrefix("fcm") {
                continue
            }
            data[key] = value
        }
        return data
    }
    
    @objc public static func parseUNNotificationContent(content: UNNotificationContent) -> [String: Any] {
        var dictionary = [String: Any]()
        var iosDict = [String: Any]()
        
        dictionary["title"] = content.title
        dictionary["subtitle"] = content.subtitle
        dictionary["body"] = content.body
        dictionary["data"] = content.userInfo
        iosDict["badgeCount"] = content.badge
        iosDict["categoryId"] = content.categoryIdentifier
        iosDict["launchImageName"] = content.launchImageName
        iosDict["threadId"] = content.threadIdentifier
        
        if #available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, *) {
            if let targetContentIdentifier = content.targetContentIdentifier {
                iosDict["targetContentId"] = targetContentIdentifier
            }
        }
        
        dictionary["ios"] = iosDict
        return dictionary
    }
    
    @objc public static func parseUNNotificationRequest(_ request: UNNotificationRequest) -> [String: Any] {
        var dictionary = [String: Any]()
        
        dictionary = parseUNNotificationContent(content: request.content)
        dictionary["id"] = request.identifier
        
        let userInfo = request.content.userInfo
        
        // Check for remote details
        if let _ = request.trigger as? UNPushNotificationTrigger {
            var remote = [String: Any]()
            
            remote["messageId"] = userInfo["gcm.message_id"]
            remote["senderId"] = userInfo["google.c.sender.id"]
            
            if let aps = userInfo["aps"] as? [String: Any] {
                remote["mutableContent"] = aps["mutable-content"]
                remote["contentAvailable"] = aps["content-available"]
            }
            
            dictionary["remote"] = remote
        }
        
        dictionary["data"] = parseDataFromUserInfo(userInfo as? [String: Any] ?? [:])
        
        return dictionary
    }
    
}

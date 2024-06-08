import Foundation
import UserNotifications

let kGuuUserInfoNotification = "__guulabs_notification"
let kGuuUserInfoTrigger = "__guulabs_trigger"

enum CoreEventType : String {
    case notificationPressed = "notificationPressed"
    case notificationActionPressed = "notificationActionPressed"
    case notificationDelivered = "notificationDelivered"
}

//@objc public protocol CoreDelegate: NSObjectProtocol {
//    @objc optional func didReceiveGuuCoreEvent(_ event: NSDictionary)
//}

@objc public class CoreGuu: NSObject {
    
    @objc public class func setCoreDelegate(_ coreDelegate: (any CoreDelegate)?) {
        CoreDelegateHolder.shared.delegate = coreDelegate
    }
    
    static func parseDataFromUserInfo(_ userInfo: [String: Any]) -> [String: Any] {
        var data = [String: Any]()
        for (key, value) in userInfo {
            // build data dict from remaining keys but skip keys that shouldn't be included in data
            if key == "aps" || key.hasPrefix("gcm.") || key.hasPrefix("google.") ||
                // guu or guu_options
                key.hasPrefix("guu") ||
                // fcm_options
                key.hasPrefix("fcm") ||
                key == kGuuUserInfoTrigger ||
                key == kGuuUserInfoNotification {
                continue
            }
            data[key] = value
        }
        return data
    }
    
   static func parseUNNotificationContent(content: UNNotificationContent) -> [String: Any] {
        var dictionary = [String: Any]()
        let iosDict = [String: Any]()
        
        dictionary["title"] = content.title
        dictionary["subtitle"] = content.subtitle
        dictionary["body"] = content.body
        dictionary["data"] = content.userInfo
        dictionary["ios"] = iosDict
        return dictionary
    }
    
    static func parseUNNotificationRequest(_ request: UNNotificationRequest) -> [String: Any] {
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
        if let guuNotifiction = userInfo[kGuuUserInfoNotification] as? [String: Any] {
            dictionary["ios"] = guuNotifiction["ios"]
        }
        
        return dictionary
    }
    
}

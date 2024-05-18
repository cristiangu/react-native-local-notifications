import Foundation
import UserNotifications

public typealias GuuLabsMethodNSDictionaryBlock = (Error?, [String: Any]?) -> Void

@objc public class LocalNotificationsUNUserNotificationCenter: NSObject {
    static let shared = { LocalNotificationsUNUserNotificationCenter() }()
    weak var originalDelegate: UNUserNotificationCenterDelegate?
    
    var originalUNCDelegateRespondsTo: (willPresentNotification: Bool, didReceiveNotificationResponse: Bool, openSettingsForNotification: Bool)? = nil
    
    var initialNotification: [String: Any]?
    var initialNotificationGathered: Bool = false
    @objc public var initialNotificationBlock: GuuLabsMethodNSDictionaryBlock?
    var initialNotificationID: String? = nil
    var notificationOpenedAppID: String? = nil
    
    // the instance class method can be reached from ObjC.
    @objc public class func instance() -> LocalNotificationsUNUserNotificationCenter {
        return LocalNotificationsUNUserNotificationCenter.shared
    }
    
    @objc public func observe() {
        let center = UNUserNotificationCenter.current()
        if let delegate = center.delegate {
            originalDelegate = delegate
            let openSettingsSelector = #selector(UNUserNotificationCenterDelegate.userNotificationCenter(_:openSettingsFor:))
            let openSettings = delegate.responds(to: openSettingsSelector)
            
            let willPresentNotificationSelector = #selector(UNUserNotificationCenterDelegate .userNotificationCenter(_:willPresent:withCompletionHandler:))
            let willPresentNotification = delegate.responds(to: willPresentNotificationSelector)
            
            let didReceiveNotificationResponseSelector = #selector(UNUserNotificationCenterDelegate.userNotificationCenter(_:didReceive:withCompletionHandler:))
            let didReceiveNotificationResponse = delegate.responds(to: didReceiveNotificationResponseSelector)
            
            originalUNCDelegateRespondsTo = (willPresentNotification, didReceiveNotificationResponse, openSettings)
        }
        center.delegate = self
    }
    
    
    @objc public func onDidFinishLaunchingNotification(_ notifUserInfo: [AnyHashable : Any]?) {
        if let notifUserInfo {
            let guuNotification = notifUserInfo[kGuuUserInfoNotification] as? [AnyHashable : Any]
            self.initialNotificationID = guuNotification?["id"] as? String
        }
        initialNotificationGathered = true
    }
    
    @objc public func getInitialNotification() -> [AnyHashable : Any]? {
        if initialNotificationGathered && initialNotificationBlock != nil {
            // copying initial notification
            if initialNotification != nil && (initialNotificationID == notificationOpenedAppID) {
                let initialNotificationCopy = initialNotification
                initialNotification = nil
                initialNotificationBlock?(nil, initialNotificationCopy)
            } else {
                initialNotificationBlock?(nil, nil)
            }
            initialNotificationBlock = nil
        }
        return nil
    }
    
    
    
}

// MARK: - UNUserNotificationCenter Delegate Methods

extension LocalNotificationsUNUserNotificationCenter: UNUserNotificationCenterDelegate {
    
    // The method will be called on the delegate only if the application is in the
    // foreground. If the the handler is not called in a timely manner then the
    // notification will not be presented. The application can choose to have the
    // notification presented as a sound, badge, alert and/or in the notification
    // list. This decision should be based on whether the information in the
    // notification is otherwise visible to the user.
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let guuNotification = notification.request.content.userInfo[kGuuUserInfoNotification] as? [AnyHashable : Any]
        
        // we only care about notifications created through this lib
        if(guuNotification == nil) {
            if let respondsTo = originalUNCDelegateRespondsTo?.willPresentNotification, respondsTo == true {
                originalDelegate?.userNotificationCenter?(
                    center, willPresent: notification, withCompletionHandler: completionHandler
                )
            }
            return
        }
        
        
        notificationOpenedAppID = guuNotification?["id"] as? String
        let ios = guuNotification?["ios"] as? [AnyHashable: Any]
        
        var presentationOptions: UNNotificationPresentationOptions = []
        let foregroundPresentationOptions = ios?["foregroundPresentationOptions"]
        
        let guuTrigger = notification.request.content.userInfo[kGuuUserInfoTrigger] as? Bool
        if let guuTrigger = guuTrigger {
            // post DELIVERED event
            CoreDelegateHolder.instance().didReceiveGuuCoreEvent(
                [
                    "type": CoreEventType.delivered.rawValue,
                    "detail": [
                        "notification": guuNotification,
                    ]
                ])
        }
        completionHandler(presentationOptions)
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        var guuNotification = response.notification.request.content.userInfo[kGuuUserInfoNotification] as? [AnyHashable : Any]
        notificationOpenedAppID = guuNotification?["id"] as? String
        
        if(guuNotification == nil) {
            guuNotification = Core.parseUNNotificationRequest(response.notification.request)
        }
        
        if(guuNotification == nil) {
            CoreDelegateHolder.instance().didReceiveGuuCoreEvent(
                [
                    "type": CoreEventType.dismissed.rawValue,
                    "detail": [
                        "notification": guuNotification,
                    ]
                ])
            return
        }
        
    }
}

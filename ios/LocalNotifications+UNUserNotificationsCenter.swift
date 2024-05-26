import Foundation
import UserNotifications

@objc public class LocalNotificationsUNUserNotificationCenter: NSObject {
    static let shared = { LocalNotificationsUNUserNotificationCenter() }()
    weak var originalDelegate: UNUserNotificationCenterDelegate?
    
    var originalUNCDelegateRespondsTo: (willPresentNotification: Bool, didReceiveNotificationResponse: Bool, openSettingsForNotification: Bool)? = nil
    
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
        
        // we only care about notifications created through this lib
        guard let guuNotification = notification.request.content.userInfo[kGuuUserInfoNotification] as? [AnyHashable : Any] else {
            if let respondsTo = originalUNCDelegateRespondsTo?.willPresentNotification, respondsTo {
                originalDelegate?.userNotificationCenter?(
                    center, willPresent: notification, withCompletionHandler: completionHandler
                )
            }
            return
        }
        
        let foregroundPresentationOptions = (guuNotification["ios"] as? [String: Any])?["foregroundPresentationOptions"] as? [String: Any];
        let alert = (foregroundPresentationOptions?["alert"] as? Bool) ?? false
        var presentationOptions: UNNotificationPresentationOptions = []
        if(alert) {
            presentationOptions.insert(UNNotificationPresentationOptions.alert)
        }
        
        let guuTrigger = notification.request.content.userInfo[kGuuUserInfoTrigger] as? Bool
        if let _ = guuTrigger {
            // post DELIVERED event
            let notificationDict = CoreGuu.parseUNNotificationRequest(notification.request)
            CoreDelegateHolder.shared.didReceiveGuuCoreEvent(
                [
                    "type": CoreEventType.delivered.rawValue,
                    "detail": [
                        "notification": notificationDict,
                    ]
                ])
        }
        completionHandler(presentationOptions)
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let _ = response.notification.request.content.userInfo[kGuuUserInfoNotification] else {
            if let respondsTo = originalUNCDelegateRespondsTo?.didReceiveNotificationResponse, respondsTo {
                originalDelegate?.userNotificationCenter?(center, didReceive: response, withCompletionHandler: completionHandler)
            }
            return
        }
        
        var eventType = "";
        let event: NSMutableDictionary = [:]
        let eventDetail: NSMutableDictionary = [:]
        let eventDetailPressAction: NSMutableDictionary = [:]
        if(response.actionIdentifier == UNNotificationDefaultActionIdentifier) {
            eventType = CoreEventType.pressed.rawValue
            eventDetailPressAction["id"] = "default"
        } else {
            eventType = CoreEventType.actionPressed.rawValue
            eventDetailPressAction["id"] = response.actionIdentifier
        }
        
        let notificationDict = CoreGuu.parseUNNotificationRequest(response.notification.request)
        eventDetail["notification"] = notificationDict
        eventDetail["pressAction"] = eventDetailPressAction
        
        event["type"] = eventType
        event["detail"] = eventDetail
        
        CoreDelegateHolder.shared.didReceiveGuuCoreEvent(event as NSDictionary)
        completionHandler()
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        if(originalDelegate == nil) {
            return
        }
        if #available(iOS 12.0, macOS 10.14, macCatalyst 13.0, *) {
            if let respondsTo = originalUNCDelegateRespondsTo?.openSettingsForNotification, respondsTo {
                originalDelegate?.userNotificationCenter?(center, openSettingsFor: notification)
            }
        }
    }
}

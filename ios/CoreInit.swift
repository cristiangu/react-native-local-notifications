import Foundation

@objc public class CoreInit: NSObject {
    static let shared = { CoreInit() }()
    
    @objc public class func instance() -> CoreInit {
        return CoreInit.shared
    }
    
    @objc public func setupListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.application_onDidFinishLaunchingNotification(notification:)), name: UIApplication.didFinishLaunchingNotification, object: nil)
    }
    
    
    @objc func application_onDidFinishLaunchingNotification(notification: NSNotification) {
        LocalNotificationsUNUserNotificationCenter.instance().onDidFinishLaunchingNotification()
        LocalNotificationsUNUserNotificationCenter.instance().getInitialNotification()
        LocalNotificationsUNUserNotificationCenter.instance().observe()
    }
}

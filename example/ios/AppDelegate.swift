//
//  AppDelegate.swift
//  LocalNotificationsExample
//
//  Created by Cristian Gutu on 05.05.2024.
//

import Foundation
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: RCTAppDelegate {
  
  let notificationCenter = UNUserNotificationCenter.current()
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    //notificationCenter.delegate = self
    notificationCenter.requestAuthorization(options: [.sound, .badge, .alert]) { granted, error in
      if(granted) {
        print("Notification authorization granted")
      } else {
        print("Notification authorization denied")
      }
    }
    self.moduleName = "LocalNotificationsExample";
    // You can add your custom initial props in the dictionary below.
    // They will be passed down to the ViewController used by React Native.
    self.initialProps = [:]
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func createRootView(with bridge: RCTBridge!, moduleName: String!, initProps: [AnyHashable : Any]!) -> UIView! {
    let rootView = super.createRootView(with: bridge, moduleName: moduleName, initProps: initProps)
    return rootView
  }
  
  override func sourceURL(for bridge: RCTBridge!) -> URL! {
    return self.getBundleUrl()
  }
  
  func getBundleUrl() -> URL? {
#if DEBUG
    return RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index", fallbackExtension: nil)
#else
    return Bundle.main.url(forResource: "main", withExtension: "jsbundle")
#endif
  }
  
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    return RCTLinkingManager.application(app, open: url);
  }
  
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    return RCTLinkingManager.application(
      application,
      continue: userActivity,
      restorationHandler: restorationHandler
    )
  }
  
}

//extension AppDelegate: UNUserNotificationCenterDelegate {
//  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
//    let userInfo = response.notification.request.content.userInfo
//    let a = 1
//  }
//  
//}

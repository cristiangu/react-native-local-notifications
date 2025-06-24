//
//  AppDelegate.swift
//  LocalNotificationsExample
//
//  Created by Cristian Gutu on 05.05.2024.
//

import Foundation
import UIKit
import UserNotifications
import React
import React_RCTAppDelegate
import ReactAppDependencyProvider

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  var reactNativeDelegate: ReactNativeDelegate?
  var reactNativeFactory: RCTReactNativeFactory?

  let notificationCenter = UNUserNotificationCenter.current()

  func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
    //notificationCenter.delegate = self
    notificationCenter.requestAuthorization(options: [.sound, .badge, .alert]) { granted, error in
      if(granted) {
        print("Notification authorization granted")
      } else {
        print("Notification authorization denied")
      }
    }
     let delegate = ReactNativeDelegate()
    let factory = RCTReactNativeFactory(delegate: delegate)
    delegate.dependencyProvider = RCTAppDependencyProvider()

    reactNativeDelegate = delegate
    reactNativeFactory = factory

    window = UIWindow(frame: UIScreen.main.bounds)

    factory.startReactNative(
      withModuleName: "LocalNotificationsExample",
      in: window,
      launchOptions: launchOptions
    )

    return true
  }

  func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    return RCTLinkingManager.application(app, open: url);
  }

  func application(
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

class ReactNativeDelegate: RCTDefaultReactNativeFactoryDelegate {
  override func sourceURL(for bridge: RCTBridge) -> URL? {
    self.bundleURL()
  }

  override func bundleURL() -> URL? {
#if DEBUG
    RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index")
#else
    Bundle.main.url(forResource: "main", withExtension: "jsbundle")
#endif
  }
}

//extension AppDelegate: UNUserNotificationCenterDelegate {
//  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
//    let userInfo = response.notification.request.content.userInfo
//    let a = 1
//  }
//
//}

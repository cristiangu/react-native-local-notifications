package com.localnotifications

import android.content.Context
import android.content.Intent
import com.facebook.react.ReactApplication
import com.facebook.react.bridge.Arguments
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.localnotifications.model.EXTRAS_NOTIFICATION


class NotificationReceiverHandler {

  companion object {

    fun handleNotificationDelivered(context: Context?, intent: Intent) {
      val notificationBundle = intent.extras?.getBundle(EXTRAS_NOTIFICATION) ?: return
      val reactNativeHost = (context?.applicationContext as ReactApplication).reactNativeHost
      val reactInstanceManager = reactNativeHost.reactInstanceManager
      val reactContext = reactInstanceManager.currentReactContext
      val event = Arguments.createMap()
      event.putMap("detail", Arguments.fromBundle(notificationBundle).copy())
      event.putString("type", "notificationDelivered")
      reactContext?.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
        ?.emit("app.guulabs.notification-event", event)
    }

    fun handleNotificationPressed(context: Context?, intent: Intent) {
      val notificationBundle = intent.extras?.getBundle(EXTRAS_NOTIFICATION) ?: return
      val reactNativeHost = (context?.applicationContext as ReactApplication).reactNativeHost
      val reactInstanceManager = reactNativeHost.reactInstanceManager
      val reactContext = reactInstanceManager.currentReactContext
      val event = Arguments.createMap()
      event.putMap("detail", Arguments.fromBundle(notificationBundle).copy())
      event.putString("type", "notificationDelivered")
      reactContext?.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
        ?.emit("app.guulabs.notification-event", event)
    }
  }


}

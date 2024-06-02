package com.localnotifications

import android.content.Context
import android.content.Intent
import com.facebook.react.ReactApplication
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.WritableMap
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.localnotifications.model.EXTRAS_NOTIFICATION


class NotificationReceiverHandler {

  companion object {
    private const val notificationReactNativeEvent = "app.guulabs.notification-event"

    private fun sendReactNativeEvent(event: WritableMap, context: Context) {
      val reactNativeHost = (context.applicationContext as ReactApplication).reactNativeHost
      val reactInstanceManager = reactNativeHost.reactInstanceManager
      val reactContext = reactInstanceManager.currentReactContext
      reactContext?.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
        ?.emit(notificationReactNativeEvent, event)
    }

    private fun sendNotificationEventFromIntent(intent: Intent, eventType: NotificationEventType, context: Context) {
      val notificationBundle = intent.extras?.getBundle(EXTRAS_NOTIFICATION) ?: return
      val event = Arguments.createMap()
      event.putMap("detail", Arguments.fromBundle(notificationBundle).copy())
      event.putString("type", eventType.raw)
      sendReactNativeEvent(event, context)
    }

    fun handleNotificationDelivered(context: Context?, intent: Intent) {
      val safeContext = context ?: return
      sendNotificationEventFromIntent(
        intent,
        NotificationEventType.DELIVERED,
        safeContext
      )
    }

    fun handleNotificationPressed(context: Context?, intent: Intent) {
      val safeContext = context ?: return
      sendNotificationEventFromIntent(
        intent,
        NotificationEventType.PRESSED,
        safeContext
      )
    }
  }
}

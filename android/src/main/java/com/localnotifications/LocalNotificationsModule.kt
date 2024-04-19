package com.localnotifications

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap

class LocalNotificationsModule internal constructor(val context: ReactApplicationContext) :
  LocalNotificationsSpec(context) {

  override fun getName(): String {
    return NAME
  }

  @ReactMethod
  override fun scheduleNotification(
    notification: ReadableMap?,
    trigger: ReadableMap?,
    promise: Promise?
  ) {
    if(notification == null || trigger == null) {
      return
    }
    val title = notification.getString("title") ?: return
    val body = notification.getString("body")
    val data = notification.getMap("data")
    val scheduleId = notification.getString("id")?: return
    val androidParamsMap = notification.getMap("android")
    val smallIconResName = androidParamsMap?.getString("smallIcon")
    val dateInMillis = trigger.getDouble("timestamp").toLong()

    NotificationScheduler().scheduleNotification(
      context,
      title,
      body,
      data,
      smallIconResName,
      scheduleId,
      dateInMillis
    )
    promise?.resolve(null)
  }

  @ReactMethod
  override fun cancelScheduledNotifications(ids: ReadableArray?, promise: Promise?) {
    promise?.resolve(null)
  }

  @ReactMethod
  override fun cancelAllScheduledNotifications(promise: Promise?) {
    promise?.resolve(null)
  }

  companion object {
    const val NAME = "LocalNotifications"
  }
}

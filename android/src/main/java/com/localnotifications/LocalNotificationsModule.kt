package com.localnotifications

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.localnotifications.util.ArrayUtil

class LocalNotificationsModule internal constructor(val context: ReactApplicationContext) :
  LocalNotificationsSpec(context) {

  override fun getName(): String {
    return NAME
  }

  @ReactMethod
  override fun scheduleNotification(
    notification: ReadableMap,
    trigger: ReadableMap,
    promise: Promise?
  ) {
    val title = notification.getString("title")
    if(title == null) {
      promise?.reject("Error", "Title prop is missing.")
      return
    }
    val body = notification.getString("body")
    val data = notification.getMap("data")
    val scheduleId = notification.getString("id")
    val androidParamsMap = notification.getMap("android")
    val smallIconResName = androidParamsMap?.getString("smallIcon")
    val colorHex = androidParamsMap?.getString("color")
    if(!trigger.hasKey("timestamp")) {
      promise?.reject("Error", "Timestamp prop is missing.")
      return
    }
    val dateInMillis = trigger.getDouble("timestamp").toLong()

    val scheduledId = NotificationScheduler.scheduleNotification(
      context,
      title,
      body,
      colorHex,
      data,
      smallIconResName,
      scheduleId,
      dateInMillis
    )
    promise?.resolve(scheduledId)
  }

  @ReactMethod
  override fun cancelScheduledNotifications(ids: ReadableArray?, promise: Promise?) {
    if(ids == null || ids.size() == 0) {
      promise?.resolve(null)
      return
    }
    val safeIds = (ArrayUtil.toArray(ids) as? Array<*>)?.filterIsInstance<String>() ?: listOf()
    NotificationScheduler.cancelScheduledNotifications(
      safeIds.toTypedArray(),
      context
    )
    promise?.resolve(null)
  }

  @ReactMethod
  override fun cancelAllScheduledNotifications(promise: Promise?) {
    NotificationScheduler.cancelAllScheduledNotifications(context)
    promise?.resolve(null)
  }

  companion object {
    const val NAME = "LocalNotifications"
  }
}

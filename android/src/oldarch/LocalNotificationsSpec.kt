package com.localnotifications

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap

abstract class LocalNotificationsSpec internal constructor(context: ReactApplicationContext) :
  ReactContextBaseJavaModule(context) {

  abstract fun scheduleNotification(
    notification: ReadableMap?,
    trigger: ReadableMap?,
    promise: Promise?
  )

  abstract fun cancelScheduledNotifications(ids: ReadableArray?, promise: Promise?)

  abstract fun cancelAllScheduledNotifications(promise: Promise?)

}

package com.localnotifications

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.localnotifications.model.NotificationModel
import com.localnotifications.util.ArrayUtil
import java.util.UUID


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
      promise?.reject("Error", "title field is missing.")
      return
    }
    if(!trigger.hasKey("timestamp")) {
      promise?.reject("Error", "timestamp field is missing.")
      return
    }
    val dateInMillis = trigger.getDouble("timestamp").toLong()
    val myBundle = Arguments.toBundle(notification)
    if(myBundle == null) {
      promise?.reject("Error", "Could not parse the notification fields.")
      return
    }
    if(!myBundle.containsKey("id")) {
      myBundle.putString("id",  UUID.randomUUID().toString())
    }
    val notificationModel = NotificationModel(myBundle)
    NotificationScheduler.scheduleNotificationNew(
      context,
      notificationModel,
      dateInMillis
    )

    promise?.resolve(notificationModel.id)
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

  override fun addListener(eventType: String?) {
    //TODO("Not yet implemented")
  }

  override fun removeListeners(count: Double) {
    //TODO("Not yet implemented")
  }


  companion object {
    const val NAME = "LocalNotifications"

//    fun onEventReceived(context: Context, intent: Intent) {
//      val params: WritableMap?
//      val extras = intent.extras
//      params = if (extras != null) {
//        try {
//          Arguments.fromBundle(extras)
//        } catch (e: Exception) {
//          Arguments.createMap()
//        }
//      } else {
//        Arguments.createMap()
//      }
//
//      val reactContext: ReactContext = (context.applicationContext as CustomReactNativeApplication)
//        .getReactContext()
//      if (reactContext != null) {
//        reactContext.getJSModule(
//          DeviceEventManagerModule.RCTDeviceEventEmitter::class.java
//        )
//          .emit("broadcaster-data-received", params)
//      }
//    }
  }
}

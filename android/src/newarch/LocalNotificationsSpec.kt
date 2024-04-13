package com.localnotifications

import com.facebook.react.bridge.ReactApplicationContext

abstract class LocalNotificationsSpec internal constructor(context: ReactApplicationContext) :
  NativeLocalNotificationsSpec(context) {
}

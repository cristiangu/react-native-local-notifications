package com.localnotifications

import android.content.Context
import android.content.Intent


class NotificationReceiverHandler {

  companion object {
    fun handleNotification(context: Context?, intent: Intent) {
      if (!intent.hasExtra("notification")) {
        return
      }
//      if (context != null && ContextHolder.getApplicationContext() == null) {
//        ContextHolder.setApplicationContext(context.applicationContext)
//      }
      //handleNotificationIntent(context, intent)
    }
  }


}

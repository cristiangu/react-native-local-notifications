package com.localnotifications

import android.app.Activity
import android.content.Intent
import android.os.Bundle


// For Android 12 +
class NotificationReceiverActivity : Activity() {

  companion object  {
    val TAG = "NotificationReceiverActivity"
  }
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    NotificationReceiverHandler.handleNotificationPressed(this, intent)
    finish()
  }

  override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    NotificationReceiverHandler.handleNotificationPressed(this, intent)
    finish()
  }
}

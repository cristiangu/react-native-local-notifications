package com.localnotifications

import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.util.Log
import androidx.core.app.NotificationCompat
import com.localnotifications.util.IntentUtil
import com.localnotifications.util.JsonUtil
import org.json.JSONObject

// Constants for notification
const val channelID = "com.localnotifications.main_channel"
const val EXTRA_SCHEDULE_ID = "com.localnotifications.EXTRA_SCHEDULE_ID"
const val EXTRA_TITLE = "com.localnotifications.EXTRA_TITLE"
const val EXTRA_MESSAGE = "com.localnotifications.EXTRA_MESSAGE"
const val EXTRA_DATA = "com.localnotifications.EXTRA_DATA"
const val EXTRA_COLOR = "com.localnotifications.EXTRA_COLOR"
const val EXTRA_SMALL_ICON_RES_ID = "com.localnotifications.EXTRA_SMALL_ICON_RES_ID"


// BroadcastReceiver for handling notifications
class NotificationReceiver : BroadcastReceiver() {
  private val TAG = "NotificationReceiver"
  override fun onReceive(context: Context, intent: Intent) {
    val id = intent.getIntExtra(EXTRA_SCHEDULE_ID, -1)

    val launchActivityClass: Class<*>? = IntentUtil.getLaunchActivity("default", context)
    val receiverIntent = Intent(context, launchActivityClass)
    receiverIntent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)

    val pendingIntent = PendingIntent.getActivity(
      context,
      id,
      receiverIntent,
      PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
    )
    val notification = NotificationCompat.Builder(context, channelID)

    try {
      val colorHex = intent.getStringExtra(EXTRA_COLOR)
      if(colorHex != null) {
        notification.setColor(Color.parseColor(colorHex))
      }
    } catch (e: Exception) {
      Log.e(TAG, "Failed to parse the HEX color string.", e)
    }

    val jsonObject = JSONObject(intent.getStringExtra(EXTRA_DATA) ?: "{}")
    notification
      .setSmallIcon(intent.getIntExtra(EXTRA_SMALL_ICON_RES_ID, 0))
      .setContentTitle(intent.getStringExtra(EXTRA_TITLE))
      .setContentText(intent.getStringExtra(EXTRA_MESSAGE))
      .setExtras(JsonUtil.convertJsonToBundle(jsonObject))
      .setContentIntent(pendingIntent)
      .setAutoCancel(true)

    val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    manager.notify(id, notification.build())
  }
}

package com.localnotifications

import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.app.NotificationCompat
import com.localnotifications.model.EXTRAS_NOTIFICATION
import com.localnotifications.model.NotificationModel

// Constants for notification
const val channelID = "com.localnotifications.main_channel"

// BroadcastReceiver for handling notifications
class NotificationReceiver : BroadcastReceiver() {
  private val TAG = "NotificationReceiver"
  override fun onReceive(context: Context, intent: Intent) {
    val notificationBundle = intent.extras?.getBundle(EXTRAS_NOTIFICATION) ?: return
    val notificationModel = NotificationModel.fromBundle(notificationBundle)
    val id = notificationModel.id.hashCode()

    val receiverIntent = Intent(context, NotificationReceiverActivity::class.java)
    receiverIntent.putExtras(intent)
    receiverIntent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
    val pendingIntent = PendingIntent.getActivity(
      context,
      id,
      receiverIntent,
      PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
    )

    val notification = NotificationCompat.Builder(context, channelID)
    try {
      val color = notificationModel.android?.getColor()
      if(color != null) {
        notification.setColor(color)
      }
    } catch (e: Exception) {
      Log.e(TAG, "Failed to parse the HEX color string.", e)
    }

    notification
      .setSmallIcon(notificationModel.android?.getSmallIcon(context)!!, 0)
      .setContentTitle(notificationModel.title)
      .setContentText(notificationModel.body)
      .setContentIntent(pendingIntent)
      .setAutoCancel(true)

    val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    manager.notify(id, notification.build())

    NotificationReceiverHandler.handleNotificationDelivered(context, receiverIntent)
  }
}

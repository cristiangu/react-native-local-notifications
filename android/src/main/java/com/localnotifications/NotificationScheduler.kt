package com.localnotifications

import android.annotation.SuppressLint
import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableMap
import com.localnotifications.util.MapUtil
import com.localnotifications.util.ResourceUtil


class NotificationScheduler {
  @SuppressLint("ScheduleExactAlarm")
  public fun scheduleNotification(
    context: ReactApplicationContext,
    title: String,
    body: String?,
    data: ReadableMap?,
    smallIconResName: String?,
    scheduleId: String,
    triggerDateInMillis: Long
  ) {
    createNotificationChannel(context)

    // Create an intent for the Notification BroadcastReceiver
    val intent = Intent(context, NotificationReceiver::class.java)
    intent.putExtra(EXTRA_TITLE, title)
    intent.putExtra(EXTRA_MESSAGE, body)
    intent.putExtra(EXTRA_SCHEDULE_ID, scheduleId.hashCode())
    intent.putExtra(EXTRA_DATA, MapUtil.toJSONObject(data).toString())

    val safeSmallIconResName = ResourceUtil.getImageResourceId(smallIconResName ?: "ic_launcher", context)
    intent.putExtra(EXTRA_SMALL_ICON_RES_ID, safeSmallIconResName)

    // Create a PendingIntent for the broadcast
    val pendingIntent = PendingIntent.getBroadcast(
      context,
      scheduleId.hashCode(),
      intent,
      PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
    )

    // Get the AlarmManager service
    val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      alarmManager.setExactAndAllowWhileIdle(
        AlarmManager.RTC_WAKEUP,
        triggerDateInMillis,
        pendingIntent
      )
    } else {
      alarmManager.setExact(
        AlarmManager.RTC_WAKEUP,
        triggerDateInMillis,
        pendingIntent
      )
    }
  }


  private fun createNotificationChannel(context: Context) {
    if (Build.VERSION.SDK_INT < 26) {
      return;
    }

    // Create a notification channel for devices running
    // Android Oreo (API level 26) and above
    val name = "Default Channel"
    val importance = NotificationManager.IMPORTANCE_DEFAULT
    val channel = NotificationChannel(channelID, name, importance)

    // Get the NotificationManager service and create the channel
    val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    notificationManager.createNotificationChannel(channel)
  }

}

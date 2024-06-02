package com.localnotifications

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import com.facebook.react.bridge.ReactApplicationContext
import com.localnotifications.model.EXTRAS_NOTIFICATION
import com.localnotifications.model.NotificationModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking


object NotificationScheduler {


  fun scheduleNotificationNew(
    context: ReactApplicationContext,
    notification: NotificationModel,
    triggerDateInMillis: Long
  ) {
    createNotificationChannel(context)

    // Create an intent for the Notification BroadcastReceiver
    val intent = getNotificationIntent(context)
    intent.putExtra(EXTRAS_NOTIFICATION, notification.toBundle())

    // Create a PendingIntent for the broadcast
    val pendingIntent = getBroadcastPendingIntent(context, notification.id, intent)
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

    runBlocking(Dispatchers.IO) {
      LocalStorage.addScheduleIds(arrayOf(notification.id), context)
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


  private fun getNotificationIntent(context: Context): Intent {
    return Intent(context, NotificationReceiver::class.java)
  }

  private fun getBroadcastPendingIntent(
    context: Context,
    scheduleId: String?,
    intent: Intent
  ): PendingIntent {
    return PendingIntent.getBroadcast(
      context,
      scheduleId.hashCode(),
      intent,
      PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
    )
  }

  fun cancelScheduledNotifications(scheduleIds: Array<String>, context: Context) {
    val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    scheduleIds.forEach {
      val pendingIntent = getBroadcastPendingIntent(
        context,
        it,
        getNotificationIntent(context)
      )
      alarmManager.cancel(pendingIntent)
    }
    runBlocking(Dispatchers.IO) {
      LocalStorage.removeScheduleIds(scheduleIds, context)
    }
  }

  fun cancelAllScheduledNotifications(context: Context) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
      val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
      alarmManager.cancelAll()
    } else {
      runBlocking(Dispatchers.IO) {
        val allScheduleIds = LocalStorage.getAllScheduleIds(context)
        cancelScheduledNotifications(allScheduleIds, context)
      }
    }

    runBlocking(Dispatchers.IO) {
      LocalStorage.removeAllScheduleIds(context)
    }
  }

}

package com.localnotifications.util

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.util.Log


object IntentUtil {
  private const val TAG = "IntentUtil"
  fun isAvailableOnDevice(ctx: Context?, intent: Intent?): Boolean {
    return try {
      if (ctx == null || intent == null) {
        return false
      }
      val mgr = ctx.packageManager
      val list = mgr.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY)
      list.size > 0
    } catch (e: Exception) {
      Log.e(TAG, "An error occurred whilst trying to check if intent is available on device", e)
      false
    }
  }

  fun getActivityName(intent: Intent?): String? {
    if (intent == null) {
      return null
    }
    try {
      val className = intent.component!!.className
      val index = className.lastIndexOf(".")
      if (index != -1) {
        return className.substring(index + 1)
      }
    } catch (e: Exception) {
      // noop
    }
    return null
  }

  fun startActivityOnUiThread(activity: Activity?, intent: Intent?, context: Context) {
    if (activity == null || intent == null) {
      Log.w(TAG, "Activity or intent is null when calling startActivityOnUiThread()")
      return
    }
    val ctx: Context = context.applicationContext
    activity.runOnUiThread(
      Runnable {
        try {
          ctx.startActivity(intent)
        } catch (e: Exception) {
          Log.e(
            TAG,
            "An error occurred whilst trying to start activity on Ui Thread",
            e
          )
        }
      })
  }

  fun getLaunchActivity(launchActivity: String?, context: Context): Class<*>? {
    val activity: String?
    activity = if (launchActivity != null && launchActivity != "default") {
      launchActivity
    } else {
      getMainActivityClassName(context)
    }
    if (activity == null) {
      Log.e("ReceiverService", "Launch Activity for notification could not be found.")
      return null
    }
    val launchActivityClass = getClassForName(activity)
    if (launchActivityClass == null) {
      Log.e(
        "ReceiverService",
        String.format("Launch Activity for notification does not exist ('%s').", launchActivity)
      )
      return null
    }
    return launchActivityClass
  }

  private fun getClassForName(className: String): Class<*>? {
    return try {
      Class.forName(className)
    } catch (e: ClassNotFoundException) {
      null
    }
  }

  fun getMainActivityClassName(context: Context): String? {
      val packageName: String = context.applicationContext.packageName
      val launchIntent: Intent? = context
        .applicationContext
        .packageManager
        .getLaunchIntentForPackage(packageName)

      return if (launchIntent == null || launchIntent.component == null) {
        null
      } else launchIntent.component!!.className
    }
}






package com.localnotificationsexample

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import com.facebook.react.ReactActivity
import com.facebook.react.ReactActivityDelegate
import com.facebook.react.defaults.DefaultNewArchitectureEntryPoint.fabricEnabled
import com.facebook.react.defaults.DefaultReactActivityDelegate

class MainActivity : ReactActivity() {

  /**
   * Returns the name of the main component registered from JavaScript. This is used to schedule
   * rendering of the component.
   */
  override fun getMainComponentName(): String = "LocalNotificationsExample"

  /**
   * Returns the instance of the [ReactActivityDelegate]. We use [DefaultReactActivityDelegate]
   * which allows you to enable New Architecture with a single boolean flags [fabricEnabled]
   */
  override fun createReactActivityDelegate(): ReactActivityDelegate =
      DefaultReactActivityDelegate(this, mainComponentName, fabricEnabled)

  override fun onResume() {
    super.onResume()
    this.checkNotificationPermissions()
  }

  private fun checkNotificationPermissions(): Boolean {
    // Check if notification permissions are granted
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      val notificationManager =
        this.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

      val isEnabled = notificationManager.areNotificationsEnabled()

      if (!isEnabled) {
        // Open the app notification settings if notifications are not enabled
        val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
        intent.putExtra(Settings.EXTRA_APP_PACKAGE, this.packageName)
        this.startActivity(intent)

        return false
      }
    } else {
      val areEnabled = NotificationManagerCompat.from(this).areNotificationsEnabled()

      if (!areEnabled) {
        // Open the app notification settings if notifications are not enabled
        val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
        intent.putExtra(Settings.EXTRA_APP_PACKAGE, this.packageName)
        this.startActivity(intent)

        return false
      }
    }

    // Permissions are granted
    return true
  }
}

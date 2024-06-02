package com.localnotifications.model

import android.content.Context
import android.graphics.Color
import android.os.Bundle
import android.util.Log
import androidx.annotation.Keep
import com.localnotifications.util.ResourceUtil


@Keep
class NotificationAndroidModel(private val mNotificationAndroidBundle: Bundle) {
  companion object {
    val TAG = "NotificationAndroidModel"

    fun fromBundle(bundle: Bundle?): NotificationAndroidModel {
      if(bundle == null) {
        return NotificationAndroidModel(Bundle.EMPTY)
      }
      return NotificationAndroidModel(bundle);
    }
  }


  /**
   * Gets the small icon resource id from its string name, or null if the icon is missing from the
   * device.
   */
  fun getSmallIcon(context: Context): Int {
    val defaultResourceId = ResourceUtil.getImageResourceId("ic_launcher", context)
    if (!mNotificationAndroidBundle.containsKey("smallIcon")) {
      return defaultResourceId
    }

    val rawIcon: String? = mNotificationAndroidBundle.getString("smallIcon")
    val smallIconId: Int = ResourceUtil.getImageResourceId(rawIcon, context)
    if (smallIconId == 0) {
      Log.d(
        TAG,
        String.format("Notification small icon '%s' could not be found", rawIcon)
      )
      return defaultResourceId
    }
    return smallIconId
  }

  /**
   * Gets the parsed notification color
   *
   * @return Integer
   */
  fun getColor(): Int? {
    return if (mNotificationAndroidBundle.containsKey("color")) {
      Color.parseColor(mNotificationAndroidBundle.getString("color"))
    } else null
  }

}




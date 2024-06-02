package com.localnotifications.model

import android.os.Bundle
import com.localnotifications.KeepForSdk

const val EXTRAS_NOTIFICATION = "notificationModel"
@KeepForSdk
class NotificationModel(private val mNotificationBundle: Bundle) {

  val hashCode: Int
    get() = id.hashCode()
  val id: String
    get() = mNotificationBundle.getString("id")!!
  val title: String?
    get() = mNotificationBundle.getString("title")
  val subTitle: String?
    get() = mNotificationBundle.getString("subtitle")
  val body: String?
    get() = mNotificationBundle.getString("body")
  val android: NotificationAndroidModel?
    get() = NotificationAndroidModel.fromBundle(mNotificationBundle.getBundle("android"))
  val data: Bundle
    get() {
      val data = mNotificationBundle.getBundle("data")
      return if (data != null) data.clone() as Bundle else Bundle()
    }

  @KeepForSdk
  fun toBundle(): Bundle {
    return mNotificationBundle.clone() as Bundle
  }

  companion object {
    fun fromBundle(bundle: Bundle): NotificationModel {
      return NotificationModel(bundle)
    }
  }
}

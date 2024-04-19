package com.localnotifications.util

import android.os.Bundle
import org.json.JSONException
import org.json.JSONObject


object JsonUtil {

  fun convertJsonToBundle(json: JSONObject): Bundle? {
    val bundle = Bundle()
    try {
      val iterator = json.keys()
      while (iterator.hasNext()) {
        val key = iterator.next() as String
        val value = json[key]
        when (value.javaClass.simpleName) {
          "String" -> bundle.putString(key, value as String)
          "Integer" -> bundle.putInt(key, (value as Int))
          "Long" -> bundle.putLong(key, (value as Long))
          "Boolean" -> bundle.putBoolean(key, (value as Boolean))
          "JSONObject" -> bundle.putBundle(key, convertJsonToBundle(value as JSONObject))
          "Float" -> bundle.putFloat(key, (value as Float))
          "Double" -> bundle.putDouble(key, (value as Double))
          else -> bundle.putString(key, value.javaClass.simpleName)
        }
      }
    } catch (e: JSONException) {
      e.printStackTrace()
    }
    return bundle
  }
}

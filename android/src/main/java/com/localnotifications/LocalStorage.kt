package com.localnotifications

import android.content.Context
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.localnotifications.util.ArrayUtil
import kotlinx.coroutines.flow.first
import org.json.JSONArray


private val Context.dataStore by preferencesDataStore("com.localnotifications.datastore")

private val KEY_SCHEDULE_IDS = stringPreferencesKey("scheduleIds")
object LocalStorage {

  suspend fun addScheduleIds(scheduleIds: Array<String>, context: Context) {
    context.dataStore.edit { preferences ->

      val currentJsonArray = JSONArray(
        preferences[KEY_SCHEDULE_IDS] ?: "[]"
      )
      for(scheduleId in scheduleIds) {
        currentJsonArray.put(scheduleId)
      }

      preferences[KEY_SCHEDULE_IDS] = currentJsonArray.toString()
    }
  }

  suspend fun removeScheduleIds(scheduleIds: Array<String>, context: Context) {
    context.dataStore.edit { preferences ->

      val currentJsonArray = JSONArray(
        preferences[KEY_SCHEDULE_IDS] ?: "[]"
      )
      val newArray = mutableListOf<String>()
      for(i in 0 until currentJsonArray.length()) {
        val id = currentJsonArray.getString(i) ?: continue
        if(!scheduleIds.contains(id)) {
          newArray.add(id)
        }
      }

      preferences[KEY_SCHEDULE_IDS] = JSONArray(newArray).toString()
    }
  }

  suspend fun removeAllScheduleIds(context: Context) {
    context.dataStore.edit { preferences ->
      preferences[KEY_SCHEDULE_IDS] = "[]"
    }
  }

  suspend fun getAllScheduleIds(context: Context): Array<String> {
    val store = context.dataStore.data.first()
    val jsonArray = JSONArray(store[KEY_SCHEDULE_IDS] ?: "[]")
    val list = (ArrayUtil.toArray(jsonArray) as? Array<*>)?.filterIsInstance<String>() ?: listOf()
    return list.toTypedArray()
  }

}

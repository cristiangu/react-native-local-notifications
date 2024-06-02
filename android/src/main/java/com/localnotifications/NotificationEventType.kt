package com.localnotifications

enum class NotificationEventType(val raw: String) {
  PRESSED("notificationPressed"),
  DELIVERED("notificationDelivered")
}

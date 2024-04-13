import UserNotifications

@objc public class NotificationScheduler: NSObject {

  @objc public static func scheduleNotification(title: String, body: String, triggerDate: Date) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = UNNotificationSound.default

    let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate), repeats: false)

    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

      UNUserNotificationCenter.current().add(request) { error in
          if let error = error {
              print("Error scheduling notification: \(error.localizedDescription)")
          } else {
              print("Notification scheduled successfully")
          }
      }
  }
}

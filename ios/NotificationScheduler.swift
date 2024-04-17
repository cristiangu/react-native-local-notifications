import UserNotifications

@objc public class NotificationScheduler: NSObject {
    
    @objc public static func scheduleNotification(
        title: String,
        body: String,
        data: NSMutableDictionary?,
        scheduleId: String,
        triggerDate: Date
    ) {
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        let data = data?.mutableCopy()
        if data != nil {
            content.userInfo = data as! [AnyHashable : Any]
        }
        content.sound = UNNotificationSound.default
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: triggerDate
            ),
            repeats: false
        )
        
        let request = UNNotificationRequest(identifier: scheduleId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully at " + triggerDate.description)
            }
        }
    }
    
    @objc public static func cancelScheduledNotifications(scheduleIds: [String]) {
        UNUserNotificationCenter
            .current()
            .removePendingNotificationRequests(withIdentifiers: scheduleIds)
    }
    
    @objc public static func cancelAllScheduledNotifications() {
        UNUserNotificationCenter
            .current()
            .removeAllPendingNotificationRequests()
    }
}



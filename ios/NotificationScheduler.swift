import UserNotifications

@objc public class NotificationScheduler: NSObject {
    
    @objc public static func scheduleNotification(
        title: String,
        body: String,
        data: NSMutableDictionary?,
        scheduleId: String?,
        triggerDate: Date
    ) -> String {
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
        let safeScheduleId = scheduleId ?? UUID().uuidString
        let request = UNNotificationRequest(identifier: safeScheduleId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            let tag = "[react-native-local-notifications]"
            if let error = error {
                print("\(tag) Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("\(tag) Notification scheduled successfully at \(triggerDate.description)")
            }
        }
        return safeScheduleId
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



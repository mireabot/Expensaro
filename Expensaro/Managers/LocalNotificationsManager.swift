//
//  LocalNotificationsManager.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/9/23.
//

import SwiftUI
import UserNotifications

final class LocalNotificationsManager : ObservableObject {
  
  static let shared = LocalNotificationsManager()
  
  func createNotification(for payment: RecurringTransaction) {
    let content = UNMutableNotificationContent()
    content.title = "\(payment.name) payment is due tomorrow"
    content.subtitle = "Open app to renew it in advance"
    content.sound = UNNotificationSound.default
    
    // show this notification five seconds from now
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Source.Functions.dateToTimeInterval(payment.dueDate), repeats: false)
    
    // choose a random identifier
    let request = UNNotificationRequest(identifier: "Transaction\(payment.id)", content: content, trigger: trigger)
    
    // add our notification request
    UNUserNotificationCenter.current().add(request)
  }
  
  func deleteNotification(for payment: RecurringTransaction) {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["Transaction\(payment.id)"])
  }
}

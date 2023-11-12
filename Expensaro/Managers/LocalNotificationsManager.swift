//
//  LocalNotificationsManager.swift
//  Expensaro
//
//  Created by Mikhail Kolkov on 11/9/23.
//

import SwiftUI
import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate{
  //Singleton is requierd because of delegate
  static let shared: NotificationManager = NotificationManager()
  let notificationCenter = UNUserNotificationCenter.current()
  
  private override init(){
    super.init()
    //This assigns the delegate
    notificationCenter.delegate = self
  }
  
  func requestAuthorization(onSuccess: @escaping() -> Void, onFail: @escaping() -> Void) {
    print(#function)
    notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
      if granted {
        print("Access Granted!")
        onSuccess()
      } else {
        print("Access Not Granted")
        onFail()
      }
    }
  }
  
  func deleteNotifications(){
    print(#function)
    notificationCenter.removeAllPendingNotificationRequests()
  }
  ///This is just a reusable form of all the copy and paste you did in your buttons. If you have to copy and paste make it reusable.
  func scheduleTriggerNotification(for payment: RecurringTransaction) {
    print(#function)
    let content = UNMutableNotificationContent()
    content.title = "\(payment.name) payment is due tomorrow"
    content.body = "Open app to renew it in advance"
    content.sound = UNNotificationSound.default
    
    let modifiedDate = Calendar.current.date(byAdding: .day, value: -1, to: payment.dueDate) ?? Date()
    
    let comps = Calendar.current.dateComponents([.year,.month,.day], from: modifiedDate)
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
    
    let request = UNNotificationRequest(identifier: "Transaction\(payment.id)", content: content, trigger: trigger)
    print(request)
    notificationCenter.add(request)
  }
  
  func deleteNotification(for payment: RecurringTransaction) {
    print(#function)
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["Transaction\(payment.id)"])
  }
  
  ///Prints to console schduled notifications
  func printNotifications(completion: @escaping ([String]) -> Void) {
    print(#function)
    notificationCenter.getPendingNotificationRequests { request in
      for req in request {
        if req.trigger is UNCalendarNotificationTrigger {
          print("---------------------------------------------")
          print(req.identifier)
          print(req.content.title)
          print(req.content.body)
          print(req.content.subtitle)
          print(req.trigger?.description ?? "")
          print("---------------------------------------------")
        }
      }
      completion([request.description])
    }
  }
  //MARK: UNUserNotificationCenterDelegate
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    
    completionHandler(.banner)
  }
}

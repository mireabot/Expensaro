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
  @AppStorage("currencySign") private var currencySign = "USD"
  
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
    content.title = "\(payment.name) is due tomorrow"
    content.body = "Your \(payment.amount.formattedAsCurrencySolid(with: currencySign)) \(payment.name) payment is due tomorrow. Don't forget to renew or cancel as needed!"
    content.sound = UNNotificationSound.default
    
    let dueDate = Source.Functions.localDate(with: payment.dueDate)
    let calendar = Calendar.current
    
    if let dayBeforeDueDate = calendar.date(byAdding: .day, value: -1, to: dueDate) {
      let components = calendar.dateComponents([.year, .month, .day], from: dayBeforeDueDate)
      let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
      let request = UNNotificationRequest(identifier: "Payment\(payment.id)", content: content, trigger: trigger)
      notificationCenter.add(request)
    } else {
      print("Cannot perform scheduling")
    }
  }
  
  func deleteNotification(for payment: RecurringTransaction) {
    print(#function)
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["Payment\(payment.id)"])
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

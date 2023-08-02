//
//  UserNotification.swift
//  Mini Challenge 01
//
//  Created by Thiago Liporace on 02/08/23.
//

import Foundation
import SwiftUI
import UserNotifications

//struct UserNotification {
//
//    public func NotificationPermission(){
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { sucess, error in
//            if sucess {
//                print("All set!")
//            }
//            else if let error = error {
//                print(error.localizedDescription)
//            }
//        }
//    }
//
//    public func SendNotification(){
//        let content = UNMutableNotificationContent()
//        content.title = "it's time to Feed'Em Up!"
//        content.sound = UNNotificationSound.default
//
//        var date = DateComponents()
//        date.hour = 13
//        date.minute = 53
//
//        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
//
//        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//
//        UNUserNotificationCenter.current().add(request)
//    }
//}

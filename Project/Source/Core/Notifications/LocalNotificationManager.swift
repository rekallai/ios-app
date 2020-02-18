//
//  LocalNotificationManager.swift
//  Rekall
//
//  Created by Ray Hunter on 15/10/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class LocalNotificationManager {
    
    static let shared = LocalNotificationManager()

    private init() {}
    
    func scheduleNotificationFor(order: PurchasedOrder) {

        guard let ticketDate = order.tickets?.first?.date else {
            print("ERROR: scheduleNotificationFor: order ticket did not have a date")
            return
        }
        
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let dayBefore = ticketDate.addingTimeInterval(-24 * 60 * 60)
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: dayBefore)
        dateComponents.hour = 19
        dateComponents.minute = 0
        
        guard let orderId = order.orderId, let venueName = order.venueName else {
            print("ERROR: Failed to schedule notification - missing key data")
            return
        }

        scheduleNotification(dateComponents: dateComponents,
                             orderId: orderId,
                             venueName: venueName)
    }
    
    private func scheduleNotification(dateComponents: DateComponents,
                                      orderId: String,
                                      venueName: String?) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Your Tickets", comment: "Notifications title")
        
        if let venueName = venueName {
            let format = NSLocalizedString("Don't forget you have tickets to %@ at \(Environment.shared.projectName) tomorrow.",
                                           comment: "Notification message")
            content.body = String(format: format, venueName)
        } else {
            content.body = NSLocalizedString("Don't forget you have tickets at \(Environment.shared.projectName) tomorrow.",
                                             comment: "Notification message")
        }
           
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: orderId,
                                            content: content,
                                            trigger: trigger)

        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("ERROR: Scheduling notification: \(error)")
            }
        }
    }
    
    func removePendingNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests()
    }
}

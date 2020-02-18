//
//  EventShareItemSource.swift
//  Rekall
//
//  Created by Steve on 10/2/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class EventShareItemSource: NSObject, UIActivityItemSource {
    var event: Event?
    let adURL = Environment.shared.shareBaseUrl
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return "\(event?.name ?? "") @ \(Environment.shared.projectName)!"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return URL(string: "\(adURL)/event/\(event?.slug ?? "")")
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "\(event?.name ?? "") @ \(Environment.shared.projectName)!"
    }
    
}

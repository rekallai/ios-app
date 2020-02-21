//
//  ADAnalytics.swift
//  Rekall
//
//  Created by Ray Hunter on 25/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import Analytics

class ADAnalytics {
    
    static let shared = ADAnalytics()
    
    private init(){
        let segConfig = SEGAnalyticsConfiguration(writeKey: Environment.shared.segmentWriteKey)
        segConfig.trackApplicationLifecycleEvents = true
        segConfig.recordScreenViews = true
        SEGAnalytics.setup(with: segConfig)
    }
    
    func track(event: String, properties: [String : Any]? = nil){
        SEGAnalytics.shared()?.track(event, properties: properties)
    }
}

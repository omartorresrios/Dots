//
//  Event.swift
//  ReputationApp
//
//  Created by Omar Torres on 10/01/18.
//  Copyright © 2018 OmarTorres. All rights reserved.
//

import UIKit

class Event {
    
    var duration: TimeInterval
    var event_url: String
    var imageUrl: NSURL
    
    var progress: CGFloat = 0
    var playing: Bool = false
    
    var createdAt: String = String()
    var userFullname: String = String()
    
    init(duration: TimeInterval, event_url: String, imageUrl: NSURL, createdAt: String, userFullname: String) {
        self.duration = duration
        self.event_url = event_url
        self.imageUrl = imageUrl
        self.createdAt = createdAt
        self.userFullname = userFullname
    }
}


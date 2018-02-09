//
//  Review.swift
//  ReputationApp
//
//  Created by Omar Torres on 30/07/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit

class Review {
    
    let fileURL: URL
    var duration: TimeInterval
    
    var progress: CGFloat = 0
    var playing: Bool = false
    
    let createdAt: Date = Date()
    
    init(fileURL: URL, duration: TimeInterval) {
        self.fileURL = fileURL
        self.duration = duration
    }
}




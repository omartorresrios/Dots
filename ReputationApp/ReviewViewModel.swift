//
//  ReviewViewModel.swift
//  ReputationApp
//
//  Created by Omar Torres on 12/23/18.
//  Copyright © 2018 OmarTorres. All rights reserved.
//

import Foundation

struct ReviewViewModel {
    let fileURL: URL
    var duration: TimeInterval
    
    var playing: Bool = false
    
    let createdAt: Date = Date()
    
    init(review: Review) {
        self.fileURL = review.fileURL
        self.duration = review.duration
    }
}

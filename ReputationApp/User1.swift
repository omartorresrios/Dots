//
//  User1.swift
//  ReputationApp
//
//  Created by Omar Torres on 31/12/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit

struct Review1 {
    
    var progress: CGFloat = 0
    var playing: Bool = false
    
    var fileURL: URL
    //    var createdAt: String?
    var duration: TimeInterval
    var from: Int?
    var to: Int?
    var id: Int?
    
    var fromAvatarUrl: String?
    var fromFullname: String?
    var fromId: Int?
    var fromUsername: String?
    
    var toAvatarUrl: String?
    var toFullname: String?
    var toId: Int?
    var toUsername: String?
    
    init(reviewDictionary: [String: Any]) {
        
        //        self.createdAt = reviewDictionary["createdAt"] as? String ?? ""
        
        self.fileURL = reviewDictionary["audio"] as! URL
        self.from = reviewDictionary["from"] as? Int ?? 0
        self.id = reviewDictionary["id"] as? Int ?? 0
        self.to = reviewDictionary["to"] as? Int ?? 0
        self.duration = (reviewDictionary["duration"]  as? String ?? "").toDouble
        
        var receiverData = reviewDictionary["receiver"] as! [String: Any]
        
        self.toAvatarUrl = receiverData["avatarUrl"] as? String ?? ""
        self.toFullname = receiverData["fullname"] as? String ?? ""
        self.toId = receiverData["id"] as? Int ?? 0
        self.toUsername = receiverData["username"]  as? String ?? ""
        
        var senderData = reviewDictionary["sender"] as! [String: Any]
        
        self.fromAvatarUrl = senderData["avatarUrl"] as? String ?? ""
        self.fromFullname = senderData["fullname"] as? String ?? ""
        self.fromId = senderData["id"] as? Int ?? 0
        self.fromUsername = senderData["username"]  as? String ?? ""
    }
}

extension String {
    var toDouble: Double {
        return Double(self) ?? 0.0
    }
}

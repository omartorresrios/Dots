//
//  User.swift
//  ReputationApp
//
//  Created by Omar Torres on 28/05/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import Foundation

struct User {
    
    var id: Int
    var fullname: String
    let username: String
    var email: String
    var profileImageUrl: String
    
    init(uid: Int, dictionary: [String: Any]) {
        self.id = dictionary["id"] as? Int ?? 0
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["avatarUrl"]  as? String ?? ""
    }
}


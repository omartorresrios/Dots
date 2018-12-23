//
//  UserViewModel.swift
//  ReputationApp
//
//  Created by Omar Torres on 12/23/18.
//  Copyright © 2018 OmarTorres. All rights reserved.
//

import Foundation

struct UserViewModel {
    
    var id: Int
    var fullname: String
    let username: String
    var email: String
    var profileImageUrl: String
    
    init(uid: Int, user: User) {
        self.id = user.id
        self.fullname = user.fullname
        self.email = user.email
        self.username = user.username
        self.profileImageUrl = user.profileImageUrl
    }
    
}

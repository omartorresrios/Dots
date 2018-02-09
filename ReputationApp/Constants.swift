//
//  Constants.swift
//  ReputationApp
//
//  Created by Omar Torres on 25/05/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import Foundation

let API_AUTH_NAME = "<YOUR_HEROKU_API_ADMIN_NAME>"
let API_AUTH_PASSWORD = "<YOUR_HEROKU_API_PASSWORD>"
let BASE_URL = "https://protected-anchorage-18127.herokuapp.com/api"

// Boolean auth UserDefaults keys
let DEFAULTS_REGISTERED = "isRegistered"
let DEFAULTS_AUTHENTICATED = "isAuthenticated"

// Auth Email
let DEFAULTS_EMAIL = "email"
let DEFAULTS_TOKEN = "authToken"

// Register url
let POST_REGISTER_ACCT = "\(BASE_URL)/users/signup"

// Login url
let POST_LOGIN_ACCT = "\(BASE_URL)/users/signin"

// Get all users url
let GET_ALL_USERS = "\(BASE_URL)/all_users"

//
//  AuthService.swift
//  ReputationApp
//
//  Created by Omar Torres on 25/05/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit

class AuthService {
    static let instance = AuthService()
    
    let defaults = UserDefaults.standard
    
    var isRegistered: Bool? {
        get {
            return defaults.bool(forKey: DEFAULTS_REGISTERED) == true
        }
        set {
            defaults.set(newValue, forKey: DEFAULTS_REGISTERED)
        }
    }
    
    var isAuthenticated: Bool? {
        get {
            return defaults.bool(forKey: DEFAULTS_AUTHENTICATED) == true
        }
        set {
            defaults.set(newValue, forKey: DEFAULTS_AUTHENTICATED)
        }
    }
    
    var email: String? {
        get {
            return defaults.value(forKey: DEFAULTS_EMAIL) as? String
        }
        set {
            defaults.set(newValue, forKey: DEFAULTS_EMAIL)
        }
    }
    
    var authToken: String? {
        get {
            return defaults.value(forKey: DEFAULTS_TOKEN) as? String
        }
        set {
            defaults.set(newValue, forKey: DEFAULTS_TOKEN)
        }
    }
    
    let httpHelper = HTTPHelper()
    
    
    func updateUserLoggedInFlag() {
        // Update the NSUserDefaults flag
        let defaults = UserDefaults.standard
        defaults.set("loggedIn", forKey: "userLoggedIn")
        defaults.synchronize()
    }
    
    // Signup user
    func makeSignUpRequest(_ fullName: String, userName:String, userEmail:String, userAvatar: String, userPassword:String, completion: @escaping _Callback) {
        
        guard let URL = URL(string: "https://protected-anchorage-18127.herokuapp.com/api/users/signup") else {
            completion(false)
            return
        }
        
        
        // Create the URL Request and set it's method and content type.
        var request = NSMutableURLRequest(url: URL)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        // Create an dictionary of the info for our new project, including the selected images.
        let encrypted_password = AESCrypt.encrypt(userPassword, password: HTTPHelper.API_AUTH_PASSWORD)
        
        let json = ["fullname": fullName, "username": userName, "email": userEmail, "avatar": userAvatar, "password": encrypted_password]
        
        do {
            // Convert our dictionary to JSON and NSData
            let newProjectJSONData = try JSONSerialization.data(withJSONObject: json, options: [])
            
            // Assign the request body
            request.httpBody = newProjectJSONData
            
            URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                if (error == nil) {
                    // Success
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    print("URL Session Task Succeeded: HTTP \(statusCode)")

                    // Print out response string
                    let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    print("Response String = \(responseString!)")

                    // Check for status 200 or 409
                    if statusCode != 200 && statusCode != 409 {

                        completion(false)
                        return
                    } else {

                        completion(true)
                    }
                } else {
                    // Failure
                    print("URL Session Task Failed: \(error?.localizedDescription)")
                    completion(false)
                }
            }).resume()
            
            
        } catch let error {
            print(error)
        }
        
        
        
        
        
        
        
        
        
        
//        let encrypted_password = AESCrypt.encrypt(userPassword, password: HTTPHelper.API_AUTH_PASSWORD)
//        
//        let json = ["fullname": fullName, "username": userName, "email": userEmail, "avatar": userAvatar, "password": encrypted_password]
////        httpRequest.httpBody = "fullname=\(fullName)&username=\(userName)&email=\(userEmail)&avatar=\(userAvatar)&password=\(encrypted_password)".data(using: String.Encoding.utf8)
//        
//        let sessionConfig = URLSessionConfiguration.default
//        
//        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
//        
//        guard let URL = URL(string: "https://protected-anchorage-18127.herokuapp.com/api/users/signup") else {
//            completion(false)
//            return
//        }
//        
//        var request = URLRequest(url: URL)
//        request.httpMethod = "POST"
//        
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
//            
//            let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
//                if (error == nil) {
//                    // Success
//                    let statusCode = (response as! HTTPURLResponse).statusCode
//                    print("URL Session Task Succeeded: HTTP \(statusCode)")
//                    
//                    // Print out response string
//                    let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
//                    print("Response String = \(responseString!)")
//                    
//                    // Check for status 200 or 409
//                    if statusCode != 200 && statusCode != 409 {
//                        
//                        completion(false)
//                        return
//                    } else {
//                        
//                        completion(true)
//                    }
//                } else {
//                    // Failure
//                    print("URL Session Task Failed: \(error?.localizedDescription)")
//                    completion(false)
//                }
//            })
//            task.resume()
//            session.finishTasksAndInvalidate()
//            
//        } catch let err {
//            
//            completion(false)
//            print(err)
//        }
        
        
        
//        // 1. Create HTTP request and set request header
//        let httpRequest = httpHelper.buildRequest(path: "users/signup", method: "POST", authType: HTTPRequestAuthType.HTTPBasicAuth)
//        
//        // 2. Password is encrypted with the API key
//        let encrypted_password = AESCrypt.encrypt(userPassword, password: HTTPHelper.API_AUTH_PASSWORD)
//        
//        // 3. Send the request Body
//        httpRequest.httpBody = "fullname=\(fullName)&username=\(userName)&email=\(userEmail)&avatar=\(userAvatar)&password=\(encrypted_password)".data(using: String.Encoding.utf8)
//        
//        // 4. Send the request
//        URLSession.shared.dataTask(with: httpRequest as URLRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
//            if error == nil {
//                // Success
//                let statusCode = (response as! HTTPURLResponse).statusCode
//                print("URL Session Task Succeeded: HTTP \(statusCode)")
//                completion(true)
//                
//                DispatchQueue.main.async {
//                    do {
//                        let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
//                        
//                        guard json != nil else {
//                            print("Error while parsing")
//                            return
//                        }
//                        
//                        // Print out response string
//                        let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
//                        print("Response String = \(responseString!)")
//                        
//                        if let token = json?["authenticationToken"] as? String {
//                            self.authToken = token
//                            print("this is the authToken: \(self.authToken)")
//                            completion(true)
//                        }
//                        
//                        // Updatge userLoggedInFlag
//                        self.updateUserLoggedInFlag()
//                        
//                    } catch {
//                        print("Caught an error: \(error)")
//                        completion(false)
//                    }
//                }
//            } else {
//                // Failure
//                print("URL Session Task Failed: \(error?.localizedDescription)")
//                completion(false)
//            }
//        }).resume()
    }
    
    
    func makeSignInRequest(_ userEmail: String, userPassword:String, completion: @escaping _Callback) {
        
        // Create HTTP request and set request Body
        let httpRequest = httpHelper.buildRequest(path: "users/signin", method: "POST", authType: HTTPRequestAuthType.HTTPBasicAuth)

        let encrypted_password = AESCrypt.encrypt(userPassword, password: HTTPHelper.API_AUTH_PASSWORD)

        let json = ["email": userEmail, "password": encrypted_password!] as [String : Any]
//        httpRequest.httpBody = "email=\(userEmail)&password=\(encrypted_password)".data(using: String.Encoding.utf8);
        
        do {
            // Convert our dictionary to JSON and NSData
            let newProjectJSONData = try JSONSerialization.data(withJSONObject: json, options: [])
            
            // Assign the request body
            httpRequest.httpBody = newProjectJSONData
            
            // 4. Send the request
            
            URLSession.shared.dataTask(with: httpRequest as URLRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                
                if error == nil {
                    // Success
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    print("URL Session Task Succeeded: HTTP \(statusCode)")
                    if statusCode != 200 {
                        // Failed
                        print("There's no a 200 status in LoginController. Failed")
                        completion(false)
                        return
                    }
                    DispatchQueue.main.async {
                        guard let data = data else {
                            completion(false)
                            return
                        }
                        
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                            
                            guard json != nil else {
                                print("Error while parsing")
                                completion(false)
                                return
                            }
                            
                            // Print out response string
                            let responseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                            print("Response String = \(responseString!)")
                            
                            if let userDic = json?["user"] as? NSDictionary {
                                print("dataArray: \(userDic["authenticationToken"] as! String)")
                                self.authToken = userDic["authenticationToken"] as? String
                                completion(true)
                                print("this is the authToken: \(self.authToken)")
                            } else {
                                completion(false)
                            }
                            
                            // Updatge userLoggedInFlag
                            self.updateUserLoggedInFlag()
                            
                        } catch {
                            completion(false)
                            print("Caught an error: \(error)")
                        }
                    }
                    
                } else {
                    // Failure
                    print("URL Session Task Failed: \(error!.localizedDescription)")
                    completion(false)
                    return
                }
            }).resume()
            
        } catch let err {
            print(err)
        }
        
    }
    
}


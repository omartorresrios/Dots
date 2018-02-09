//
//  HTTPHelper.swift
//  ReputationApp
//
//  Created by Omar Torres on 10/05/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import Foundation

enum HTTPRequestAuthType {
    case HTTPBasicAuth
    case HTTPTokenAuth
}

enum HTTPRequestContentType {
    case HTTPJsonContent
    case HTTPMultipartContent
}

struct HTTPHelper {
    
    static let API_AUTH_NAME = "<YOUR_HEROKU_API_ADMIN_NAME>"
    static let API_AUTH_PASSWORD = "<YOUR_HEROKU_API_PASSWORD>"
    static let BASE_URL = "https://protected-anchorage-18127.herokuapp.com/api"
    
    
    
    func buildRequest(path: String, method: String, authType: HTTPRequestAuthType,
                      requestContentType: HTTPRequestContentType = HTTPRequestContentType.HTTPJsonContent, requestBoundary:String = "") -> NSMutableURLRequest {
        
        // 1. Create the request URL from path
        let requestURL = NSURL(string: "\(HTTPHelper.BASE_URL)/\(path)")
        let request = NSMutableURLRequest(url: requestURL as! URL)
        
        // Set HTTP request method and Content-Type
        request.httpMethod = method
        
        // 2. Set the correct Content-Type for the HTTP Request. This will be multipart/form-data for photo upload request and application/json for other requests in this app
        switch requestContentType {
        case .HTTPJsonContent:
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        case .HTTPMultipartContent:
            let contentType = "multipart/form-data; boundary=\(requestBoundary)"
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        
        
        // 3. Set the correct Authorization header.
        switch authType {
        case .HTTPBasicAuth:
            // Set BASIC authentication header
            let basicAuthString = "\(HTTPHelper.API_AUTH_NAME):\(HTTPHelper.API_AUTH_PASSWORD)"
            let utf8str = basicAuthString.data(using: String.Encoding.utf8)
            let base64EncodedString = utf8str?.base64EncodedString()
            
            request.addValue("Basic \(base64EncodedString!)", forHTTPHeaderField: "Authorization")
        case .HTTPTokenAuth:
            // Retreieve Auth_Token from Keychain
            if let userToken = KeychainAccess.passwordForAccount(account: "Auth_Token", service: "KeyChainService") as String? {
                // Set Authorization header
                request.addValue("Token \(userToken)", forHTTPHeaderField: "Authorization")
            }
        }
        
        return request
    }
    
    func sendRequest(request: URLRequest, completionHandler: @escaping (Data?, Error?) -> Void) -> () {
        
        // Create a NSURLSession task
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error == nil {
                DispatchQueue.main.async {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        guard json != nil else {
                            print("Error while parsing")
                            return
                        }
                        
                        // Print out response string
                        let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                        print("Response String = \(responseString!)")
                        
                        print("User was successfully created! :)")
                        
                        
                    } catch {
                        print("Caught an error: \(error)")
                    }
                }
            } else {
                print("There is an error: \(error)")
            }
        })
        // Start the task
        task.resume()
        
    }
    
    func getErrorMessage(error: NSError) -> NSString {
        var errorMessage : NSString
        
        // return correct error message
        if error.domain == "HTTPHelperError" {
            let userInfo = error.userInfo as NSDictionary!
            errorMessage = userInfo?.value(forKey: "message") as! NSString
        } else {
            errorMessage = error.description as NSString
        }
        
        return errorMessage
    }
    
}

//
//  DataService.swift
//  ReputationApp
//
//  Created by Omar Torres on 25/05/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import Foundation
import Photos
import Alamofire

class DataService {
    
    static let instance = DataService()
    
    func savePhoto(image: UIImage, view: UIView) {
        let library = PHPhotoLibrary.shared()
        
        
        
        library.performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { (success, err) in
            if let err = err {
                print("Failed to save image to photo library: ", err)
            }
            print("Successfully saved image to library")
            
            DispatchQueue.main.async {
                let savedLabel = UILabel()
                savedLabel.text = "Se guardó!"
                savedLabel.font = UIFont(name: "SFUIDisplay-Medium", size: 18)
                savedLabel.textColor = .white
                savedLabel.numberOfLines = 0
                savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
                savedLabel.textAlignment = .center
                
                savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
                savedLabel.center = view.center
                
                view.addSubview(savedLabel)
                
                savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    
                    savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                    
                }, completion: { (completed) in
                    
                    UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                        
                        savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                        savedLabel.alpha = 0
                        
                    }, completion: { (_) in
                        
                        savedLabel.removeFromSuperview()
                        
                    })
                    
                })
            }
        }
    }
    
    func saveVideo(url: URL, view: UIView) {
        let blurView = UIView()
        blurView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addSubview(blurView)
        blurView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        let loader = UIActivityIndicatorView(activityIndicatorStyle: .white)
        loader.alpha = 1.0
        loader.startAnimating()
        
        blurView.addSubview(loader)
        loader.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        loader.centerYAnchor.constraint(equalTo: blurView.centerYAnchor).isActive = true
        loader.centerXAnchor.constraint(equalTo: blurView.centerXAnchor).isActive = true
        
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { (success, err) in
            if let err = err {
                print("Failed to save video to library: ", err)
            }
            print("Successfully saved video to library")
            
            
            DispatchQueue.main.async {
                loader.stopAnimating()
                let savedLabel = UILabel()
                blurView.addSubview(savedLabel)
                savedLabel.anchor(top: nil, left: blurView.leftAnchor, bottom: nil, right: blurView.rightAnchor, paddingTop: 0, paddingLeft: 50, paddingBottom: 0, paddingRight: 50, width: 0, height: 60)
                savedLabel.centerYAnchor.constraint(equalTo: blurView.centerYAnchor).isActive = true
                savedLabel.text = "¡Guardado! 👌"
                savedLabel.font = UIFont(name: "SFUIDisplay-Medium", size: 18)
                savedLabel.textColor = .white
                savedLabel.translatesAutoresizingMaskIntoConstraints = false
                savedLabel.numberOfLines = 0
                savedLabel.textAlignment = .center
                
                
                savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    
                    savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                    
                }, completion: { (completed) in
                    
                    UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                        
                        savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                        savedLabel.alpha = 0
                        
                    }, completion: { (_) in
                        
                        savedLabel.removeFromSuperview()
                        blurView.removeFromSuperview()
                        
                    })
                    
                })
            }
        }
    }
    
    func shareVideo(authToken: String, videoCaption: UITextView, videoUrl: URL, duration: String, completion: @escaping (Bool) -> ()) {
        guard let caption = videoCaption.text else { return }
        
        // Set Authorization header
        let header = ["Authorization": "Token token=\(authToken)"]
        
        let parameters = ["description": caption, "duration": duration] as [String : Any]
        
        let url = URL(string: "https://protected-anchorage-18127.herokuapp.com/api/writeEvent")!
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            multipartFormData.append(videoUrl, withName: "video", fileName: ".mp4", mimeType: "video/mp4")
            
            for (key, value) in parameters {
                multipartFormData.append(((value as Any) as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
            
        }, usingThreshold: UInt64.init() , to: url, method: .post, headers: header, encodingCompletion: { encodingResult in
            
            switch encodingResult {
            case .success(let upload, _, _):
                
                upload.responseJSON { response in
                    print("request: \(response.request!)") // original URL request
                    print("response: \(response.response!)") // URL response
                    print("response data: \(response.data!)") // server data
                    print("result: \(response.result)") // result of response serialization
                    
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                        print("send video successfully")
                        completion(true)
                    }
                    
                    if response.result.isFailure == true {
                        completion(false)
                    }
                }
                
            case .failure(let encodingError):
                print("Alamofire proccess failed", encodingError)
                completion(false)
            }
        })
    }
    
    func shareAudio(authToken: String, userId: Int, audioUrl: URL, duration: TimeInterval, completion: @escaping (Bool) -> ()) {
        // Set Authorization header
        let header = ["Authorization": "Token token=\(authToken)"]
        
        let parameters = ["duration": duration] as [String : Any]
        
        let url = URL(string: "https://protected-anchorage-18127.herokuapp.com/api/\(userId)/speak")!
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            multipartFormData.append(audioUrl, withName: "audio", fileName: ".m4a", mimeType: "audio/m4a")
            
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
            }
            
        }, usingThreshold: UInt64.init() , to: url, method: .post, headers: header, encodingCompletion: { encodingResult in
            
            switch encodingResult {
            case .success(let upload, _, _):
                
                upload.responseJSON { response in
                    print("request: \(response.request!)") // original URL request
                    print("response: \(response.response!)") // URL response
                    print("response data: \(response.data!)") // server data
                    print("result: \(response.result)") // result of response serialization
                    
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                        print("send audio successfully")
                        completion(true)
                    }
                }
                
            case .failure(let encodingError):
                print("Alamofire proccess failed", encodingError)
                completion(false)
            }
        })
    }
    
}

//
//  PreviewPhotoContainerView.swift
//  ReputationApp
//
//  Created by Omar Torres on 7/10/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import Photos
import Locksmith
import Alamofire

class PreviewPhotoContainerView: UIView {
    
    let previewImageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()
    
    let photoCaption: UITextView = {
        let tv = UITextView()
        tv.layer.cornerRadius = 4
        return tv
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .yellow
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    func handleSave() {
        
        guard let previewImage = previewImageView.image else { return }
        
        DataService.instance.savePhoto(image: previewImage, view: self)
    }
    
    func handleNext() {
        
        // TODO: Mejorar la entrada de estos elementos
        
        addSubview(photoCaption)
        photoCaption.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 100)
        photoCaption.alpha = 0
        
        addSubview(sendButton)
        sendButton.anchor(top: photoCaption.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 4, width: 20, height: 20)
        sendButton.alpha = 0
        
        UIView.animate(withDuration: 0.3, delay: 0.4, options: .curveEaseIn, animations: {
            
            self.photoCaption.alpha = 1
            self.sendButton.alpha = 1
            
        }) { (succes) in
            print("success")
        }
    }
    
    func handleSend() {
        // Retreieve Auth_Token from Keychain
        if let userToken = Locksmith.loadDataForUserAccount(userAccount: "AuthToken") {
            
            let authToken = userToken["authenticationToken"] as! String
            
            print("the current user token: \(userToken)")
            
            guard let caption = photoCaption.text else { return }
            
            // Set Authorization header
            let header = ["Authorization": "Token token=\(authToken)"]
            
            let parameters = ["description": caption] as [String : Any]
            
            let url = URL(string: "https://protected-anchorage-18127.herokuapp.com/api/writeEvent")!
            
            Alamofire.upload(multipartFormData: { multipartFormData in
                
                let pictureSelected = UIImageJPEGRepresentation(self.previewImageView.image!, 0.5)
                
                if let pictureData = pictureSelected {
                    multipartFormData.append(pictureData, withName: "picture", fileName: "picture.jpg", mimeType: "image/png")
                }
                
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
                        }
                    }
                    
                case .failure(let encodingError):
                    print("Alamofire proccess failed", encodingError)
                }
            })
            
        } else {
            print("Impossible retrieve token")
        }
    }
    
    func handleCancel() {
        self.removeFromSuperview()
    }
    
    func setupViews() {
        
        addSubview(previewImageView)
        previewImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(cancelButton)
        cancelButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        
        addSubview(saveButton)
        saveButton.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 24, paddingBottom: 24, paddingRight: 0, width: 50, height: 50)
        
        addSubview(nextButton)
        nextButton.anchor(top: nil, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 24, paddingBottom: 24, paddingRight: 0, width: 50, height: 50)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

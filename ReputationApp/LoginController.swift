//
//  LoginController.swift
//  ReputationApp
//
//  Created by Omar Torres on 10/05/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import Alamofire
import Locksmith
import GoogleSignIn
import Google

class LoginController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate, UIGestureRecognizerDelegate {
    
    let googleButton = GIDSignInButton()
    var imageData: Data?
    var tap = UITapGestureRecognizer()
    let customAlertMessage = CustomAlertMessage()
    
    let customLoginView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        return view
    }()
    
    let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "dots_logo")
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let customLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "logo_google").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    let termsServiceButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.numberOfLines = 0
        let attributedTitle = NSMutableAttributedString(string: "Continuando, aceptas nuestros Términos de Servicio.", attributes: [NSFontAttributeName: UIFont(name: "SFUIDisplay-Regular", size: 12)!, NSForegroundColorAttributeName: UIColor.white])
        button.titleLabel?.textAlignment = .center
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowTermsOfService), for: .touchUpInside)
        return button
    }()
    
    func handleShowTermsOfService() {
        let termsOfServiceController = TermsOfServiceController()
        present(termsOfServiceController, animated: true, completion: nil)
    }
    
    func handleLogin() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func updateUserLoggedInFlag() {
        // Update the NSUserDefaults flag
        let defaults = UserDefaults.standard
        defaults.set("loggedIn", forKey: "userLoggedIn")
        defaults.synchronize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.mainGreen()
        
        var error: NSError?
        
        GGLContext.sharedInstance().configureWithError(&error)
        
        if error != nil {
            print(error ?? "some error")
            return
        }
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        view.addSubview(logoImageView)
        logoImageView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        setupCustomLoginButton()
        
        view.addSubview(termsServiceButton)
        termsServiceButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 12, paddingRight: 20, width: 0, height: 0)
    }
    
    func setupCustomLoginButton() {
        view.addSubview(customLoginView)
        customLoginView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        customLoginView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        customLoginView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        customLoginView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLogin)))
        
        customLoginView.addSubview(customLoginButton)
        customLoginButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 25, height: 25)
        customLoginButton.centerYAnchor.constraint(equalTo: customLoginView.centerYAnchor).isActive = true
        customLoginButton.centerXAnchor.constraint(equalTo: customLoginView.centerXAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = true
    }
    
    func saveApiTokenInKeychain(tokenString: String, idInt: Int, nameString: String, avatarString: String) {
        // save API AuthToken in Keychain
        try! Locksmith.saveData(data: ["authenticationToken": tokenString], forUserAccount: "AuthToken")
        try! Locksmith.saveData(data: ["id": idInt], forUserAccount: "currentUserId")
        try! Locksmith.saveData(data: ["name": nameString], forUserAccount: "currentUserName")
        try! Locksmith.saveData(data: ["avatar": avatarString], forUserAccount: "currentUserAvatar")
        
        print("AuthToken recién guardado: \(Locksmith.loadDataForUserAccount(userAccount: "AuthToken")!)")
        print("currentUserId recién guardado: \(Locksmith.loadDataForUserAccount(userAccount: "currentUserId")!)")
        print("currentUserName recién guardado: \(Locksmith.loadDataForUserAccount(userAccount: "currentUserName")!)")
        print("currentUserAvatar recién guardado: \(Locksmith.loadDataForUserAccount(userAccount: "currentUserAvatar")!)")
        
    }
    
    func dismissviewMessage() {
        customAlertMessage.removeFromSuperview()
        view.removeGestureRecognizer(tap)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: customAlertMessage))!{
            return false
        }
        return true
    }
    
    func showCustomAlertMessage(image: UIImage, message: String) {
        DispatchQueue.main.async {
            
            self.customAlertMessage.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
            
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.view.addSubview(self.customAlertMessage)
                self.customAlertMessage.anchor(top: nil, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
                self.customAlertMessage.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
                
                self.customAlertMessage.iconMessage.image = image
                self.customAlertMessage.labelMessage.text = message
                
                self.customAlertMessage.transform = .identity
                
                self.tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissviewMessage))
                self.view.addGestureRecognizer(self.tap)
                self.tap.delegate = self
                
            }, completion: nil)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        // Check for internet connection
        if (reachability?.isReachable)! {
            
            if error != nil {
                print("Some error while configuring Google login: ", error)
                return
            }
            
            print("user id: ", GIDSignIn.sharedInstance().currentUser.userID)
            print("user name: ", user.profile.name)
            print("user email: ", user.profile.email)
            print("user profile image: ", user.profile.imageURL(withDimension: 400))
            
            guard let google_id = GIDSignIn.sharedInstance().currentUser.userID else { return }
            guard let fullname = user.profile.name else { return }
            guard let email = user.profile.email else { return }
            guard let avatar = user.profile.imageURL(withDimension: 400) else { return }
            
            let emailRegEx = "[A-Z0-9a-z._%+-]+@(mambo)+\\.pe"
            let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            
            if emailTest.evaluate(with: email) == true { // Valid email
                print("Eres mambero")
                if let data = try? Data(contentsOf: avatar) {
                    self.imageData = data
                }
                
                let parameters = ["google_id": google_id, "fullname": fullname, "email": email] as [String : Any]
                
                let url = URL(string: "https://protected-anchorage-18127.herokuapp.com/api/users/google/login")!
                
                // Set BASIC authentication header
                let basicAuthString = "\(HTTPHelper.API_AUTH_NAME):\(HTTPHelper.API_AUTH_PASSWORD)"
                let utf8str = basicAuthString.data(using: String.Encoding.utf8)
                let base64EncodedString = utf8str?.base64EncodedString()
                
                let headers = ["Authorization": "Basic \(String(describing: base64EncodedString))"]
                
                Alamofire.upload(multipartFormData: { multipartFormData in
                    
                    if let imgData = self.imageData {
                        multipartFormData.append(imgData, withName: "avatar", fileName: "avatar.jpg", mimeType: "image/png")
                    }
                    
                    for (key, value) in parameters {
                        multipartFormData.append(((value as Any) as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                    }
                    
                }, usingThreshold: UInt64.init() , to: url, method: .post, headers: headers, encodingCompletion: { encodingResult in
                    
                    switch encodingResult {
                    case .success(let upload, _, _):
                        
                        self.updateUserLoggedInFlag()
                        
                        upload.responseJSON { response in
                            print("request: \(response.request!)") // original URL request
                            print("response: \(response.response!)") // URL response
                            print("response data: \(response.data!)") // server data
                            print("result: \(response.result)") // result of response serialization
                            
                            if let JSON = response.result.value as? NSDictionary {
                                let userJSON = JSON["user"] as! NSDictionary
                                let authToken = userJSON["authenticationToken"] as! String
                                let userId = userJSON["id"] as! Int
                                let userName = userJSON["fullname"] as! String
                                let avatarUrl = userJSON["avatarUrl"] as! String
                                print("userJSON: \(userJSON)")
                                print("JSON: \(JSON)")
                                self.saveApiTokenInKeychain(tokenString: authToken, idInt: userId, nameString: userName, avatarString: avatarUrl)
                                print("authToken: \(authToken)")
                                print("userId: \(userId)")
                                
                                let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                                appDel.logUser(forAppDelegate: true)
                                
                            }
                        }
                        
                    case .failure(let encodingError):
                        print("Alamofire proccess failed", encodingError)
                    }
                })
                
            } else {
                
                GIDSignIn.sharedInstance().uiDelegate = self
                GIDSignIn.sharedInstance().delegate = self
                GIDSignIn.sharedInstance().signOut()
                                
                self.showCustomAlertMessage(image: "✋".image(), message: "¡No eres mambero!\n\nDebes entrar con tu correo de Mambo 😉")
            }
            
        } else {
            self.showCustomAlertMessage(image: "😕".image(), message: "¡Revisa tu conexión de internet e intenta de nuevo!")
        }
        
        
        
    }
    
}

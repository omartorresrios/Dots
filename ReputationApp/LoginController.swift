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
    
    let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "dots_logo")
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let supportView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        return view
    }()
    
    let loginLabel: UILabel = {
        let label = UILabel()
        label.text = "Inicia sesión con Google"
        label.font = UIFont(name: "SFUIDisplay-Semibold", size: 20)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = UIColor.mainGreen()
        return label
    }()
    
    let termsServiceButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.numberOfLines = 0
        
        let attributedTitle = [NSAttributedString.Key.font:  UIFont(name: "SFUIDisplay-Regular", size: 12)!, NSAttributedString.Key.foregroundColor: UIColor.white]

        let attString = NSMutableAttributedString()
        attString.append(NSAttributedString(string: "jaja", attributes: attributedTitle))
        
//            NSMutableAttributedString(string: "Continuando, aceptas nuestros Términos de Servicio.", attributes: [NSFontAttributeName: UIFont(name: "SFUIDisplay-Regular", size: 12)!, NSForegroundColorAttributeName: UIColor.white])
        button.titleLabel?.textAlignment = .center
        button.setAttributedTitle(attString, for: .normal)
        button.addTarget(self, action: #selector(handleShowTermsOfService), for: .touchUpInside)
        return button
    }()
    
    let supportLoaderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.6)
        return view
    }()
    
    let circleLoader: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 30, green: 30, blue: 30)
        view.layer.cornerRadius = 8
        return view
    }()
    
    let loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.white)
        indicator.alpha = 1.0
        return indicator
    }()
    
    @objc func handleShowTermsOfService() {
        let termsOfServiceController = TermsOfServiceController()
        present(termsOfServiceController, animated: true, completion: nil)
    }
    
    @objc func handleLogin() {
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
        
        setupCustomLoginButton()
        
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func setupCustomLoginButton() {
        
        view.addSubview(termsServiceButton)
        termsServiceButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 8, paddingRight: 20, width: 0, height: 0)
        
        view.addSubview(supportView)
        supportView.anchor(top: nil, left: view.leftAnchor, bottom: termsServiceButton.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 40, paddingRight: 20, width: 0, height: 50)
        supportView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLogin)))
        
        supportView.addSubview(loginLabel)
        loginLabel.anchor(top: nil, left: supportView.leftAnchor, bottom: nil, right: supportView.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        loginLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLogin)))
        loginLabel.centerYAnchor.constraint(equalTo: supportView.centerYAnchor).isActive = true
        loginLabel.centerXAnchor.constraint(equalTo: supportView.centerXAnchor).isActive = true
        
        view.addSubview(logoImageView)
        logoImageView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 120, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = true
    }
    
    func saveApiTokenInKeychain(tokenString: String, idInt: Int, nameString: String, emailString: String, avatarString: String) {
        // save API AuthToken in Keychain
        try! Locksmith.saveData(data: ["authenticationToken": tokenString], forUserAccount: "AuthToken")
        try! Locksmith.saveData(data: ["id": idInt], forUserAccount: "currentUserId")
        try! Locksmith.saveData(data: ["name": nameString], forUserAccount: "currentUserName")
        try! Locksmith.saveData(data: ["email": emailString], forUserAccount: "currentUserEmail")
        try! Locksmith.saveData(data: ["avatar": avatarString], forUserAccount: "currentUserAvatar")
        
        print("AuthToken recién guardado: \(Locksmith.loadDataForUserAccount(userAccount: "AuthToken")!)")
        print("currentUserId recién guardado: \(Locksmith.loadDataForUserAccount(userAccount: "currentUserId")!)")
        print("currentUserName recién guardado: \(Locksmith.loadDataForUserAccount(userAccount: "currentUserName")!)")
        print("currentUserEmail recién guardado: \(Locksmith.loadDataForUserAccount(userAccount: "currentUserEmail")!)")
        print("currentUserAvatar recién guardado: \(Locksmith.loadDataForUserAccount(userAccount: "currentUserAvatar")!)")
        
    }
    
    @objc func dismissviewMessage() {
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
            
            self.view.addSubview(self.supportLoaderView)
            self.supportLoaderView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
            
            self.supportLoaderView.addSubview(self.circleLoader)
            self.circleLoader.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 60, height: 60)
            self.circleLoader.centerXAnchor.constraint(equalTo: self.supportLoaderView.centerXAnchor).isActive = true
            self.circleLoader.centerYAnchor.constraint(equalTo: self.supportLoaderView.centerYAnchor).isActive = true
            
            self.circleLoader.addSubview(self.loader)
            self.loader.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 20, height: 20)
            self.loader.centerXAnchor.constraint(equalTo: self.circleLoader.centerXAnchor).isActive = true
            self.loader.centerYAnchor.constraint(equalTo: self.circleLoader.centerYAnchor).isActive = true
            self.loader.startAnimating()
            
            print("user id: ", GIDSignIn.sharedInstance().currentUser.userID)
            print("user name: ", user.profile.name)
            print("user email: ", user.profile.email)
            print("user profile image: ", user.profile.imageURL(withDimension: 400))
            
            guard let google_id = GIDSignIn.sharedInstance().currentUser.userID else { return }
            guard let fullname = user.profile.name else { return }
            guard let email = user.profile.email else { return }
            guard let avatar = user.profile.imageURL(withDimension: 400) else { return }
            
            let gmailRegEx = "[A-Z0-9a-z._%+-]+@(gmail)+\\.com"
            let mamboRegEx = "[A-Z0-9a-z._%+-]+@(mambo)+\\.pe"
            let gmailTest = NSPredicate(format: "SELF MATCHES %@", gmailRegEx)
            let mamboTest = NSPredicate(format: "SELF MATCHES %@", mamboRegEx)
            
            if gmailTest.evaluate(with: email) == true || mamboTest.evaluate(with: email) == true { // Valid email
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
                                let userEmail = userJSON["email"] as! String
                                let avatarUrl = userJSON["avatarUrl"] as! String
                                print("userJSON: \(userJSON)")
                                print("JSON: \(JSON)")
                                self.saveApiTokenInKeychain(tokenString: authToken, idInt: userId, nameString: userName, emailString: userEmail, avatarString: avatarUrl)
                                print("authToken: \(authToken)")
                                print("userId: \(userId)")
                                
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                
                                let left = storyboard.instantiateViewController(withIdentifier: "left")
                                let middle = storyboard.instantiateViewController(withIdentifier: "middle")
                                let right = storyboard.instantiateViewController(withIdentifier: "right")
                                
                                let snapContainer = SnapContainerViewController.containerViewWith(left, middleVC: middle, rightVC: right)
                                
                                UIApplication.shared.keyWindow?.rootViewController = snapContainer
                                
                                self.dismiss(animated: true, completion: {
                                    DispatchQueue.main.async {
                                        self.supportLoaderView.removeFromSuperview()
                                        self.circleLoader.removeFromSuperview()
                                        self.loader.stopAnimating()
                                    }
                                })
                                
                            }
                        }
                        
                    case .failure(let encodingError):
                        self.supportLoaderView.removeFromSuperview()
                        self.circleLoader.removeFromSuperview()
                        self.loader.stopAnimating()
                        print("Alamofire proccess failed", encodingError)
                    }
                })
                
            } else {
                
                DispatchQueue.main.async {
                    self.supportLoaderView.removeFromSuperview()
                    self.circleLoader.removeFromSuperview()
                    self.loader.stopAnimating()
                }
                
                GIDSignIn.sharedInstance().uiDelegate = self
                GIDSignIn.sharedInstance().delegate = self
                GIDSignIn.sharedInstance().signOut()
                                
                self.showCustomAlertMessage(image: "✋".image(), message: "¡Debes entrar con tu correo de Mambo 😉!")
            }
            
        } else {
            DispatchQueue.main.async {
                self.supportLoaderView.removeFromSuperview()
                self.circleLoader.removeFromSuperview()
                self.loader.stopAnimating()
            }
            self.showCustomAlertMessage(image: "😕".image(), message: "¡Revisa tu conexión de internet e intenta de nuevo!")
        }
    }
    
}

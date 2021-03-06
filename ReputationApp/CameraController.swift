//
//  CameraController.swift
//  ReputationApp
//
//  Created by Omar Torres on 9/10/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import SwiftyCam
import Photos
import AVFoundation
import JDStatusBarNotification
import MediaPlayer
import Alamofire
import Locksmith
import GoogleSignIn

class CameraController: SwiftyCamViewController, SwiftyCamViewControllerDelegate, AVCapturePhotoCaptureDelegate {
    
    let userContentOptionsView = UserProfileView()
    var userSelected: User! = nil
    var userDictionary = [String: Any]()
    var timer: Timer?
    var counter = 20
    var startTime: Double = 0
    var time: Double = 0
    var finalDuration: String?
    var videoUrl: URL?
    var player: AVPlayer?
    var playerLayer = AVPlayerLayer()
    let customAlertMessage = CustomAlertMessage()
    var tap = UITapGestureRecognizer()
    
    let fakeView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let fakeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.cornerRadius = 75 / 2
        button.isUserInteractionEnabled = false
        return button
    }()
    
    let userSearchControllerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "userSearch-icon").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(goToUserSearchFromCamera), for: .touchUpInside)
        return button
    }()
    
    let myProfileControllerImage: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 35 / 2
        return iv
    }()
    
    let userFeedControllerImage: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "dots_logo_feed").withRenderingMode(.alwaysTemplate)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let videoCaption: UITextView = {
        let tv = UITextView()
        tv.layer.cornerRadius = 4
        return tv
    }()
    
    let loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.white)
        indicator.alpha = 1.0
        indicator.startAnimating()
        return indicator
    }()
    
    let blurView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
    
    let swiftyCamButton: SwiftyCamButton = {
        let button = SwiftyCamButton()
        button.backgroundColor = .clear
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 75 / 2
        button.isUserInteractionEnabled = false
        return button
    }()
    
    let sendSuccesView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.mainGreen()
        view.layer.cornerRadius = 25
        return view
    }()
    
    let sendView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 45 / 2
        view.backgroundColor = UIColor.mainGreen()
        return view
    }()
    
    let sendSuccesIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "clapping_hand")
        return iv
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 6
        button.setImage(#imageLiteral(resourceName: "close").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.white
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 6
        button.setImage(#imageLiteral(resourceName: "download").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.white
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "send-1").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.white
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    let counterLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = UIFont(name: "SFUIDisplay-Semibold", size: 25)
        label.textColor = .white
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrievingCurrentUser()
        topNavigationButtons()
        setupCameraOptions()
        fakeViews()

        // Reachability for checking internet connection
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityStatusChanged), name: NSNotification.Name(rawValue: "ReachStatusChanged"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        NotificationCenter.default.addObserver(self, selector: #selector(SetupSwiftyCamButton), name: NSNotification.Name(rawValue: "AllUsersLoaded"), object: nil)
        SetupSwiftyCamButton()
    }
    
    func setupCameraOptions() {
        cameraDelegate = self
        defaultCamera = .rear
        maximumVideoDuration = 20.0
        shouldUseDeviceOrientation = false
        allowAutoRotate = false
        audioEnabled = true
    }
    
    func retrievingCurrentUser() {
        guard let userEmail = Locksmith.loadDataForUserAccount(userAccount: "currentUserEmail") else { return }
        guard let userId = Locksmith.loadDataForUserAccount(userAccount: "currentUserId") else { return }
        guard let userName = Locksmith.loadDataForUserAccount(userAccount: "currentUserName") else { return }
        guard let userAvatar = Locksmith.loadDataForUserAccount(userAccount: "currentUserAvatar") else { return }
        
        userDictionary.updateValue((userId as [String : AnyObject])["id"] as! Int? ?? 0, forKey: "id")
        userDictionary.updateValue((userName as [String : AnyObject])["name"] as! String? ?? "", forKey: "fullname")
        userDictionary.updateValue((userEmail as [String : AnyObject])["email"] as! String? ?? "", forKey: "email")
        userDictionary.updateValue((userAvatar as [String : AnyObject])["avatar"] as! String? ?? "", forKey: "avatar")
        
        let user = User(uid: (userId as [String : AnyObject])["id"] as! Int? ?? 0, dictionary: userDictionary)
        
        userSelected = user
    }
    
    func topNavigationButtons() {
        view.addSubview(userSearchControllerButton)
        userSearchControllerButton.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 28, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 30, height: 30)
        
        view.addSubview(myProfileControllerImage)
        myProfileControllerImage.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 28, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 35, height: 35)
        myProfileControllerImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        guard let userAvatar = Locksmith.loadDataForUserAccount(userAccount: "currentUserAvatar") else { return }
        myProfileControllerImage.loadImage(urlString: ((userAvatar as [String : AnyObject])["avatar"] as! String?)!)
        myProfileControllerImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToMyProfile)))
        myProfileControllerImage.isUserInteractionEnabled = true
        
        view.addSubview(userFeedControllerImage)
        userFeedControllerImage.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 28, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 35, height: 35)
        userFeedControllerImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToFeedController)))
        userFeedControllerImage.isUserInteractionEnabled = true
    }
    
    func fakeViews() {
        view.addSubview(fakeView)
        fakeView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(fakeButton)
        fakeButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 75, height: 75)
        fakeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    @objc func goToMyProfile() {
        setupUserInfoViewsContainers()
    }
    
    @objc func goToFeedController() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GoToFeedFromCameraView"), object: nil)
    }
    
    @objc func goToUserSearchFromCamera() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GoToSearchFromCameraView"), object: nil)
    }

    @objc func reachabilityStatusChanged() {
        print("Checking connectivity...")
        self.customAlertMessage.removeFromSuperview()
        self.view.removeGestureRecognizer(self.tap)
        self.blurView.removeFromSuperview()
    }
    
    func setupUserInfoViewsContainers() {
        DispatchQueue.main.async {
            self.swiftyCamButton.isHidden = true
            self.swiftyCamButton.isUserInteractionEnabled = false
        }
        
        userContentOptionsView.viewSupport.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            
            self.view.addSubview(self.userContentOptionsView)
            self.userContentOptionsView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
            
            let reviewsTap = UITapGestureRecognizer(target: self, action: #selector(self.showUserReviewsView))
            self.userContentOptionsView.reviewsViewContainer.addGestureRecognizer(reviewsTap)
            
            self.userContentOptionsView.storiesViewContainer.layoutIfNeeded()
            self.userContentOptionsView.storiesViewContainer.layer.addBorder(edge: .top, color: .gray, thickness: 1)
            
            let storiesTap = UITapGestureRecognizer(target: self, action: #selector(self.showStoriesView))
            self.userContentOptionsView.storiesViewContainer.addGestureRecognizer(storiesTap)
            
            self.tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissContainerView))
            self.userContentOptionsView.viewGeneral.addGestureRecognizer(self.tap)
            self.tap.delegate = self
            
            self.userContentOptionsView.viewSupport.transform = .identity
            
        }, completion: nil)
    }
    
    @objc func showUserReviewsView() {
        let myReviewsController = MyReviewsController(collectionViewLayout: UICollectionViewFlowLayout())
        
        myReviewsController.userId = userSelected.id
        myReviewsController.userFullname = userSelected.fullname
        myReviewsController.userImageUrl = userSelected.profileImageUrl
        
        present(myReviewsController, animated: true, completion: nil)
    }
    
    @objc func showStoriesView() {
        let myStoriesController = MyStoriesController(collectionViewLayout: UICollectionViewFlowLayout())

        myStoriesController.userId = userSelected.id
        myStoriesController.userFullname = userSelected.fullname
        myStoriesController.userImageUrl = userSelected.profileImageUrl

        present(myStoriesController, animated: true, completion: nil)
    }

    func showSuccesMessage() {
        DispatchQueue.main.async {
            self.loader.removeFromSuperview()
            self.sendSuccesView.layer.transform = CATransform3DMakeScale(0, 0, 0)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.blurView.addSubview(self.sendSuccesView)
                self.sendSuccesView.layer.transform = CATransform3DMakeScale(1, 1, 1)

                self.sendSuccesView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
                self.sendSuccesView.centerXAnchor.constraint(equalTo: self.blurView.centerXAnchor).isActive = true
                self.sendSuccesView.centerYAnchor.constraint(equalTo: self.blurView.centerYAnchor).isActive = true

                self.sendSuccesView.addSubview(self.sendSuccesIconImageView)
                self.sendSuccesIconImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 25, height: 25)
                self.sendSuccesIconImageView.centerXAnchor.constraint(equalTo: self.sendSuccesView.centerXAnchor).isActive = true
                self.sendSuccesIconImageView.centerYAnchor.constraint(equalTo: self.sendSuccesView.centerYAnchor).isActive = true

            }, completion: { (completed) in

                UIView.animate(withDuration: 1.0, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {

                    self.sendSuccesView.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                    self.sendSuccesView.removeFromSuperview()

                }, completion: { (_) in

                    self.swiftyCamButton.delegate = self
                    self.swiftyButton()

                    DispatchQueue.main.async {
                        self.blurView.removeFromSuperview()
                        self.userSearchControllerButton.isHidden = false
                        self.userSearchControllerButton.isUserInteractionEnabled = true
                        self.swiftyCamButton.layer.borderColor = UIColor.white.cgColor
                        
                        self.counterLabel.removeFromSuperview()
                        self.counterLabel.text = ""
                        self.counterLabel.textColor = .white
                        
                        self.player!.pause()
                        self.player = nil
                        self.playerLayer.removeFromSuperlayer()
                        
                        self.swiftyCamButton.transform = .identity
                    }
                })
            })
        }
    }

    @objc func handleSend() {

        if (reachability?.isReachable)! {

            DispatchQueue.main.async {
                self.cancelButton.removeFromSuperview()
                self.saveButton.removeFromSuperview()
                self.sendView.removeFromSuperview()

                self.view.addSubview(self.blurView)
                self.blurView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

                self.blurView.addSubview(self.loader)
                self.loader.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
                self.loader.centerYAnchor.constraint(equalTo: self.blurView.centerYAnchor).isActive = true
                self.loader.centerXAnchor.constraint(equalTo: self.blurView.centerXAnchor).isActive = true
            }

            print("this is the final url: ", videoUrl!)
            // Retreieve Auth_Token from Keychain
            if let userToken = Locksmith.loadDataForUserAccount(userAccount: "AuthToken") {

                let authToken = userToken["authenticationToken"] as! String
                print("the current user token: \(userToken)")

                DataService.instance.shareVideo(authToken: authToken, videoCaption: self.videoCaption, videoUrl: videoUrl!, duration: finalDuration!, completion: { (success) in
                    if success {
                        self.clearTemporaryDirectory()
                        self.showSuccesMessage()
                    } else {
                        DispatchQueue.main.async {
                            self.customAlertMessage.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
                            
                            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                                self.view.addSubview(self.customAlertMessage)
                                self.customAlertMessage.anchor(top: nil, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
                                self.customAlertMessage.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

                                self.customAlertMessage.iconMessage.image = "😕".image()
                                self.customAlertMessage.labelMessage.text = "No se pudo enviar tu momento. Intenta de nuevo.\n¡Lo sentimos!"

                                self.customAlertMessage.transform = .identity

                            }, completion: nil)
                        }
                        self.tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissviewMessage))
                        self.view.addGestureRecognizer(self.tap)
                        self.tap.delegate = self
                    }
                })

                guard let data = NSData(contentsOf: videoUrl!) else {
                    return
                }

                print("Final file size: \(Double(data.length / 1048576)) mb")

            } else {
                print("Impossible retrieve token")
            }
        } else {

            DispatchQueue.main.async {

                self.view.addSubview(self.blurView)
                self.blurView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

                self.customAlertMessage.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)

                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                    self.blurView.addSubview(self.customAlertMessage)
                    self.customAlertMessage.anchor(top: nil, left: self.blurView.leftAnchor, bottom: nil, right: self.blurView.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
                    self.customAlertMessage.centerYAnchor.constraint(equalTo: self.blurView.centerYAnchor).isActive = true

                    self.customAlertMessage.iconMessage.image = "😕".image()
                    self.customAlertMessage.labelMessage.text = "¡Revisa tu conexión de internet e intenta de nuevo!"

                    self.customAlertMessage.transform = .identity

                }, completion: nil)
            }
            self.tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissConnectionViewMessage))
            self.blurView.addGestureRecognizer(self.tap)
            self.tap.delegate = self
        }
    }

    @objc func dismissConnectionViewMessage() {
        DispatchQueue.main.async {
            self.blurView.removeFromSuperview()
            self.blurView.removeGestureRecognizer(self.tap)
        }
    }

    @objc func dismissviewMessage() {
        self.swiftyCamButton.delegate = self
        self.swiftyButton()

        DispatchQueue.main.async {
            self.customAlertMessage.removeFromSuperview()
            self.view.removeGestureRecognizer(self.tap)
            self.blurView.removeFromSuperview()
            self.loader.removeFromSuperview()
            
            self.player!.pause()
            self.player = nil
            self.playerLayer.removeFromSuperlayer()
            
            self.swiftyCamButton.transform = .identity
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: customAlertMessage))!{
            return false
        }
        return true
    }
    
    func swiftyButton() {
        view.addSubview(swiftyCamButton)
        swiftyCamButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 75, height: 75)
        swiftyCamButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    func SetupSwiftyCamButton() {
        swiftyCamButton.delegate = self
        fakeView.removeFromSuperview()

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.fakeButton.removeFromSuperview()
        }, completion: nil)

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.swiftyButton()
        }, completion: nil)

        swiftyCamButton.isUserInteractionEnabled = true
    }

    func setupViews() {
        DispatchQueue.main.async {
            self.userSearchControllerButton.isHidden = true
            self.userSearchControllerButton.isUserInteractionEnabled = false
            
            self.view.addSubview(self.cancelButton)
            self.cancelButton.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 15, height: 15)
            
            self.view.addSubview(self.saveButton)
            self.saveButton.anchor(top: nil, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 20, paddingRight: 0, width: 25, height: 25)
            
            self.view.addSubview(self.sendView)
            self.sendView.anchor(top: nil, left: nil, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 12, paddingRight: 12, width: 45, height: 45)
            self.sendView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleSend)))
            
            self.sendView.addSubview(self.sendButton)
            self.sendButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 23, height: 23)
            self.sendButton.centerYAnchor.constraint(equalTo: self.sendView.centerYAnchor).isActive = true
            self.sendButton.centerXAnchor.constraint(equalTo: self.sendView.centerXAnchor).isActive = true
        }
    }
    
    @objc func clearTemporaryDirectory() {
        FileManager.default.clearTmpDirectory()
    }
    
    func addCounterLabel() {
        DispatchQueue.main.async {
            self.view.addSubview(self.counterLabel)
            self.counterLabel.anchor(top: nil, left: nil, bottom: self.swiftyCamButton.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 30, paddingRight: 0, width: 0, height: 0)
            self.counterLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        }
    }

    @objc func handleSave() {
        DataService.instance.saveVideo(url: self.videoUrl!, view: self.view)
    }

    @objc func handleCancel() {
        clearTemporaryDirectory()
        self.swiftyCamButton.delegate = self
        self.swiftyButton()

        DispatchQueue.main.async {
            self.userSearchControllerButton.isHidden = false
            self.userSearchControllerButton.isUserInteractionEnabled = true
            self.swiftyCamButton.layer.borderColor = UIColor.white.cgColor
            
            self.player!.pause()
            self.player = nil
            self.playerLayer.removeFromSuperlayer()
            
            self.cancelButton.removeFromSuperview()
            self.saveButton.removeFromSuperview()
            self.sendView.removeFromSuperview()
            self.counterLabel.removeFromSuperview()
            self.counterLabel.text = ""
            self.counterLabel.textColor = .white
        }
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        DispatchQueue.main.async {
            self.counter -= 1
            self.counterLabel.text = "\(self.counter)"
            
            if self.counter <= 5 {
                self.counterLabel.textColor = .red
            }
            
            self.time = Date().timeIntervalSinceReferenceDate - self.startTime
            let timeString = String(format: "%.11f", self.time)
            self.finalDuration = timeString
        }
    }
    
    func resetTimer() {
        timer?.invalidate()
        counter = 20
    }
    
    @objc func dismissContainerView() {
        DispatchQueue.main.async {
            self.userContentOptionsView.removeFromSuperview()
            self.userContentOptionsView.viewGeneral.removeGestureRecognizer(self.tap)
            
            self.swiftyCamButton.isHidden = false
            self.swiftyCamButton.isUserInteractionEnabled = true
        }
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        print("recording video")
        addCounterLabel()
        runTimer()
        
        DispatchQueue.main.async {
            self.swiftyCamButton.layer.borderColor = UIColor.red.cgColor
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(clearTemporaryDirectory), name: NSNotification.Name(rawValue: "ErrorWhileRecording"), object: nil)

        startTime = Date().timeIntervalSinceReferenceDate
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        resetTimer()
        print("finishing recording video")
        print("video quality was: ", self.videoQuality)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL, secondaryUrl: URL) {
        videoUrl = url

        print("this is the url: ", url)

        DispatchQueue.main.async {
            self.swiftyCamButton.removeFromSuperview()
        }
        
        player = AVPlayer(url: secondaryUrl)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        view.layer.addSublayer(playerLayer)
        player!.play()
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player!.currentItem, queue: nil, using: { (_) in
            DispatchQueue.main.async {
                self.player!.seek(to: CMTime.zero)
                self.player!.play()
            }
        })

        setupViews()
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {

    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
        print(zoom)
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {
        print(camera)
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFailToRecordVideo error: Error) {
        print(error)
    }
    
}

extension FileManager {
    func clearTmpDirectory() {
        do {
            let tmpDirectory = try contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach {[unowned self] file in
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                try self.removeItem(atPath: path)
            }
        } catch {
            print(error)
        }
    }
}


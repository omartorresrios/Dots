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
    
    let sendLabel = UILabel()
    
    var circleView = CircleView()
    let videoFileOutput = AVCaptureMovieFileOutput()
    let captureSession = AVCaptureSession()
    
    var timerTest: Timer?
    var counter = 20
    var startTime: Double = 0
    var time: Double = 0
    var finalDuration: String?
    var videoUrl: URL?
    var player = AVPlayer()
    var playerLayer = AVPlayerLayer()
    let customAlertMessage = CustomAlertMessage()
    var tap = UITapGestureRecognizer()
    
    let videoCaption: UITextView = {
        let tv = UITextView()
        tv.layer.cornerRadius = 4
        return tv
    }()
    
    let loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        indicator.alpha = 1.0
        indicator.startAnimating()
        return indicator
    }()
    
    let blurView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
    
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
    
    let flashButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor.white
        button.setImage(#imageLiteral(resourceName: "flash_off").withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(handleFlash), for: .touchUpInside)
        return button
    }()
    
    var flashing = false
    
    func handleFlash() {
        if flashing {
            flashButton.setImage(#imageLiteral(resourceName: "flash_on").withRenderingMode(.alwaysTemplate), for: .normal)
            flashEnabled = true
        } else {
            flashButton.setImage(#imageLiteral(resourceName: "flash_off").withRenderingMode(.alwaysTemplate), for: .normal)
            flashEnabled = false
        }
        flashing = !flashing
    }
    
    func setupCameraOptions() {
        cameraDelegate = self
        defaultCamera = .rear
        maximumVideoDuration = 20.0
        shouldUseDeviceOrientation = false
        allowAutoRotate = false
        audioEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func reachabilityStatusChanged() {
        print("Checking connectivity...")
        self.customAlertMessage.removeFromSuperview()
        self.view.removeGestureRecognizer(self.tap)
        self.blurView.removeFromSuperview()
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
                        self.playerLayer.removeFromSuperlayer()
                        self.player.pause()
                        self.swiftyCamButton.transform = .identity
                    }
                })  
            })
        }
    }
    
    func handleSend() {
        
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
                        FileManager.default.clearTmpDirectory()
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
    
    func dismissConnectionViewMessage() {
        DispatchQueue.main.async {
            self.blurView.removeFromSuperview()
            self.blurView.removeGestureRecognizer(self.tap)
        }
    }
        
    func dismissviewMessage() {
        self.swiftyCamButton.delegate = self
        self.swiftyButton()
        
        DispatchQueue.main.async {
            self.customAlertMessage.removeFromSuperview()
            self.view.removeGestureRecognizer(self.tap)
            self.blurView.removeFromSuperview()
            self.loader.removeFromSuperview()
            self.playerLayer.removeFromSuperlayer()
            self.player.pause()
            self.swiftyCamButton.transform = .identity
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: customAlertMessage))!{
            return false
        }
        return true
    }
    
    func addCircleView() {
        
        let diceRoll = view.frame.size.width / 2 - (75 / 2)
        let y = view.frame.size.height - 95
        let circleWidth = CGFloat(75)
        let circleHeight = circleWidth
        circleView = CircleView(frame: CGRect(x: diceRoll, y: y, width: circleWidth, height: circleHeight))
        
        view.addSubview(circleView)
        
        circleView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        UIView.animate(withDuration: 0.4) {
            self.circleView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }
        
        circleView.animateCircle(duration: 20.0)
        
    }
    
    func swiftyButton() {
        
        view.addSubview(swiftyCamButton)
        swiftyCamButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 75, height: 75)
        swiftyCamButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(flashButton)
        flashButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 18, width: 25, height: 25)
        
    }
    
    func fakeViews() {
        view.addSubview(fakeView)
        fakeView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(fakeButton)
        fakeButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 75, height: 75)
        fakeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
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
    
    func update() {
        DispatchQueue.main.async {
            if self.counter > 0 {
                print("\(self.counter) seconds to the end of the world")
                self.counter -= 1
            }
            self.time = Date().timeIntervalSinceReferenceDate - self.startTime
            
            let timeString = String(format: "%.11f", self.time)
            
            self.finalDuration = timeString
        }
    }
    
    func setupViews() {
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 15, height: 15)
        
        view.addSubview(saveButton)
        saveButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 20, paddingRight: 0, width: 25, height: 25)
        
        view.addSubview(sendView)
        sendView.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 12, paddingRight: 12, width: 45, height: 45)
        sendView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSend)))
        
        sendView.addSubview(sendButton)
        sendButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 23, height: 23)
        sendButton.centerYAnchor.constraint(equalTo: sendView.centerYAnchor).isActive = true
        sendButton.centerXAnchor.constraint(equalTo: sendView.centerXAnchor).isActive = true
        
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        print("recording video")
        
        NotificationCenter.default.addObserver(self, selector: #selector(invalidateTimerAndCircleView), name: NSNotification.Name(rawValue: "ErrorWhileRecording"), object: nil)
        
        startTime = Date().timeIntervalSinceReferenceDate
        timerTest = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        
        DispatchQueue.main.async {
            self.swiftyCamButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            UIView.animate(withDuration: 0.4) {
                self.swiftyCamButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                self.addCircleView()
            }
        }
    }
    
    func invalidateTimerAndCircleView() {
        FileManager.default.clearTmpDirectory()
        DispatchQueue.main.async {
            self.timerTest?.invalidate()
            self.timerTest = nil
            self.circleView.pauseAnimation()
        }
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        print("finishing recording video")
        
        DispatchQueue.main.async {
            self.timerTest?.invalidate()
            self.timerTest = nil
            self.circleView.pauseAnimation()
            print("video quality was: ", self.videoQuality)
        }
    }
    
    func handleSave() {
        DataService.instance.saveVideo(url: self.videoUrl!, view: self.view)
    }
    
    func handleCancel() {
        FileManager.default.clearTmpDirectory()
        self.swiftyCamButton.delegate = self
        self.swiftyButton()
        
        DispatchQueue.main.async {
            self.playerLayer.removeFromSuperlayer()
            self.player.pause()
            self.cancelButton.removeFromSuperview()
            self.saveButton.removeFromSuperview()
            self.sendView.removeFromSuperview()
            self.swiftyCamButton.transform = .identity
        }
        
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL, secondaryUrl: URL) {
        videoUrl = url
        
        print("this is the url: ", url)
        
        DispatchQueue.main.async {
            self.circleView.removeFromSuperview()
            self.swiftyCamButton.removeFromSuperview()
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.mixWithOthers)
            
            player = AVPlayer(url: secondaryUrl)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = view.bounds
            view.layer.addSublayer(playerLayer)
            player.play()
        } catch {
            print("Some error to reproduce video")
        }
        
        
        
        
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil, using: { (_) in
            DispatchQueue.main.async {
                self.player.seek(to: kCMTimeZero)
                self.player.play()
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

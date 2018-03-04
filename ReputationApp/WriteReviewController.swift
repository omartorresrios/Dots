//
//  WriteReviewController.swift
//  ReputationApp
//
//  Created by Omar Torres on 10/12/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import JDStatusBarNotification
import AVFoundation
import AudioBot
import Locksmith
import Alamofire
import CoreGraphics
import Mixpanel

class WriteReviewController: UIViewController, UITextViewDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIGestureRecognizerDelegate {
    
    var userReceiverId: String?
    var userReceiverFullname: String?
    var userReceiverImageUrl: String?
    
    var userId: Int?
    var userFullname: String?
    var userImageUrl: String?
    var currentUserDic = [String: Any]()
    
    var actualReview: Review!
    var finalUrl: URL?
    var finalDuration: TimeInterval?
    var tap = UITapGestureRecognizer()
    let customAlertMessage = CustomAlertMessage()
    
    var meterTimer:Timer!
    var isAudioRecordingGranted: Bool!
    var isRecording = false
    var isPlaying = false
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var duration: TimeInterval!
    
    var playing: Bool = false {
        willSet {
            if newValue != playing {
                if newValue {
                    playAudioButton.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysTemplate), for: .normal)
                } else {
                    playAudioButton.setImage(#imageLiteral(resourceName: "play").withRenderingMode(.alwaysTemplate), for: .normal)
                }
            }
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Deja una reseña"
        label.font = UIFont(name: "SFUIDisplay-Medium", size: 16)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    var startRecordButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.addTarget(self, action: #selector(startRecord), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "record").withRenderingMode(.alwaysTemplate), for: .normal)
        return button
    }()
    
    let loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        indicator.alpha = 1.0
        indicator.startAnimating()
        return indicator
    }()
    
    let blurView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.8)
        return view
    }()
    
    let blurConnectionView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.8)
        return view
    }()
    
    let sendSuccesView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.mainGreen()
        view.layer.cornerRadius = 25
        return view
    }()
    
    let sendSuccesIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "clapping_hand")
        return iv
    }()
    
    var progressView: UIProgressView = {
        let progress = UIProgressView()
        progress.progressTintColor = UIColor.mainGreen()
        progress.tintColor = .white
        progress.trackTintColor = .white
        return progress
    }()
    
    let closeView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.backgroundColor = UIColor.mainGreen()
        return view
    }()
    
    let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "down_arrow").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    var playAudioButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.addTarget(self, action: #selector(playAudio), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "play").withRenderingMode(.alwaysTemplate), for: .normal)
        return button
    }()
    
    let sendView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.backgroundColor = UIColor.mainGreen()
        return view
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "send-1").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.white
        button.addTarget(self, action: #selector(sendAudio), for: .touchUpInside)
        return button
    }()
    
    let audioLength: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0:00"
        label.textColor = .white
        label.font = UIFont(name: "SFUIDisplay-Medium", size: 14)
        label.textAlignment = .right
        return label
    }()
    
    let supportView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.grayLow()
        view.layer.cornerRadius = 8
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.grayHigh()
        
        view.addSubview(closeView)
        closeView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 30, height: 30)
        closeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeViewController)))
        
        closeView.addSubview(closeButton)
        closeButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 15, height: 15)
        closeButton.centerXAnchor.constraint(equalTo: closeView.centerXAnchor).isActive = true
        closeButton.centerYAnchor.constraint(equalTo: closeView.centerYAnchor).isActive = true
        closeButton.addTarget(self, action: #selector(closeViewController), for: .touchUpInside)
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: closeView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        
//        let tapGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandler(_:)))
//        view.addGestureRecognizer(tapGesture)
        
        // Reachability for checking internet connection
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityStatusChanged), name: NSNotification.Name(rawValue: "ReachStatusChanged"), object: nil)
        
        addRecordButton()
        
        check_record_permission()
        
    }
    
    func closeViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func check_record_permission() {
        switch AVAudioSession.sharedInstance().recordPermission() {
        case AVAudioSessionRecordPermission.granted:
            isAudioRecordingGranted = true
            break
        case AVAudioSessionRecordPermission.denied:
            isAudioRecordingGranted = false
            break
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.isAudioRecordingGranted = true
                    } else {
                        self.isAudioRecordingGranted = false
                    }
                }
            }
            break
        default:
            break
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getFileUrl() -> URL {
        let filename = "myRecording.m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        return filePath
    }
    
    func setup_recorder() {
        if isAudioRecordingGranted {
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
                audioRecorder = try AVAudioRecorder(url: getFileUrl(), settings: settings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
            }
            catch let error {
                self.showCustomAlertMessage(image: "😕".image(), message: "No se pudo configurar el micrófono. Intenta de nuevo")
            }
        } else {
            self.showCustomAlertMessage(image: "😕".image(), message: "No se puede acceder a tu micrófono")
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func reachabilityStatusChanged() {
        print("Checking connectivity...")
    }
    
    func addRecordButton() {
        view.addSubview(startRecordButton)
        startRecordButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 50, height: 50)
        startRecordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        startRecordButton.adjustsImageWhenHighlighted = false
    }
    
    func prepare_play() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: getFileUrl())
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        }
        catch {
            print("Some error preparing the play")
        }
    }
    
    func playAudio() {
        func tryPlay() {
            do {
                AudioBot.reportPlayingDuration = { duration in

                    let ti = NSInteger(duration)

                    let seconds = String(format: "%02d", ti % 60)
                    let minutes = String(format: "%2d", (ti / 60) % 60)

                    self.audioLength.text = "\(minutes):\(seconds)"
                }

                let progressPeriodicReport: AudioBot.PeriodicReport = (reportingFrequency: 10, report: { progress in
                    print("progress: \(progress)")
                    self.actualReview.progress = CGFloat(progress)
                    self.progressView.progress = progress
                })
                let fromTime = TimeInterval(actualReview.progress) * (actualReview.duration)
                try AudioBot.startPlayAudioAtFileURL(actualReview.fileURL, fromTime: fromTime, withProgressPeriodicReport: progressPeriodicReport, finish: { success in
                    self.playing = false
                    self.actualReview.playing = false
                })
                playing = true
                actualReview.playing = true
            } catch {
                print("play error: \(error)")
            }
        }
        if AudioBot.playing {
            AudioBot.pausePlay()
            playing = false
            actualReview.playing = false
        } else {
            tryPlay()
        }
    }
    
    func addSendButton() {
        view.addSubview(sendView)
        sendView.anchor(top: supportView.bottomAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 40, height: 40)
        sendView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sendAudio)))
        
        sendView.addSubview(sendButton)
        sendButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 23, height: 23)
        sendButton.centerYAnchor.constraint(equalTo: sendView.centerYAnchor).isActive = true
        sendButton.centerXAnchor.constraint(equalTo: sendView.centerXAnchor).isActive = true
    }
    
    func addPlayerView(isShowing: Bool) {
        if isShowing == true {
            DispatchQueue.main.async {
                
                self.view.addSubview(self.supportView)
                self.supportView.anchor(top: nil, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
                self.supportView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
                
                self.supportView.addSubview(self.playAudioButton)
                self.playAudioButton.anchor(top: nil, left: self.supportView.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 20, height: 20)
                self.playAudioButton.centerYAnchor.constraint(equalTo: self.supportView.centerYAnchor).isActive = true
                self.playAudioButton.adjustsImageWhenHighlighted = false
                
                self.supportView.addSubview(self.progressView)
                self.progressView.anchor(top: nil, left: self.playAudioButton.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
                self.progressView.centerYAnchor.constraint(equalTo: self.playAudioButton.centerYAnchor).isActive = true
                
                self.supportView.addSubview(self.audioLength)
                self.audioLength.anchor(top: nil, left: self.progressView.rightAnchor, bottom: nil, right: self.supportView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
                self.audioLength.centerYAnchor.constraint(equalTo: self.playAudioButton.centerYAnchor).isActive = true
                
                let duration = NSInteger(self.actualReview.duration)
                let seconds = String(format: "%02d", duration % 60)
                let minutes = (duration / 60) % 60
                
                self.audioLength.text = "\(minutes):\(seconds)"
                
                self.addSendButton()
            }
            
        } else {
            DispatchQueue.main.async {
                self.supportView.removeFromSuperview()
            }
        }
    }
    
    func startRecord() {
        DispatchQueue.main.async {
            self.startRecordButton.tintColor = UIColor.mainGreen()
        }
        
        if isRecording {
            DispatchQueue.main.async {
                self.startRecordButton.tintColor = .white
            }
            
            finishAudioRecording(success: true)

            let voiceMemo = Review(fileURL: getFileUrl(), duration: duration)
            self.actualReview = voiceMemo
            self.finalUrl = getFileUrl()
            self.finalDuration = duration
            
            self.addPlayerView(isShowing: true)
            isRecording = false
            
            // Tracking each time user tap startRecordButton (stop)
            guard let userEmail = Locksmith.loadDataForUserAccount(userAccount: "currentUserEmail") else { return }
            Mixpanel.mainInstance().identify(distinctId: (userEmail as [String : AnyObject])["email"] as! String!)
            Mixpanel.mainInstance().track(event: "Pressed startRecordButton (stop)")
            
        } else {
            setup_recorder()
            
            audioRecorder.record()
            
            if self.view.subviews.contains(supportView) && self.view.subviews.contains(sendView) {
                print("HAY ELEMENTOS")
                DispatchQueue.main.async {
                    self.supportView.removeFromSuperview()
                    self.sendView.removeFromSuperview()
                }
            } else {
                print("NO HAY NINGUN ELEMENTO")
            }
            
            DispatchQueue.main.async {
                self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
                self.startRecordButton.tintColor = UIColor.mainGreen()
            }
            
            self.addPlayerView(isShowing: false)
            isRecording = true
            
            // Tracking each time user tap startRecordButton (start)
            guard let userEmail = Locksmith.loadDataForUserAccount(userAccount: "currentUserEmail") else { return }
            Mixpanel.mainInstance().identify(distinctId: (userEmail as [String : AnyObject])["email"] as! String!)
            Mixpanel.mainInstance().track(event: "Pressed startRecordButton (start)")
        }
        
    }
    
    func updateAudioMeter(timer: Timer) {
        if audioRecorder.isRecording {
            let hr = Int((audioRecorder.currentTime / 60) / 60)
            let min = Int(audioRecorder.currentTime / 60)
            let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            audioLength.text = totalTimeString
            audioRecorder.updateMeters()
        }
    }
    
    func finishAudioRecording(success: Bool) {
        if success {
            duration = audioRecorder.currentTime
            audioRecorder.stop()
            audioRecorder = nil
            meterTimer.invalidate()
            print("recorded successfully.")
        } else {
            self.showCustomAlertMessage(image: "😕".image(), message: "Hubo un error al grabar tu reseña. Intenta de nuevo")
        }
    }
    
    func showSuccesMessage() {
        DispatchQueue.main.async {
            
            self.loader.stopAnimating()
            
            self.sendSuccesView.layer.transform = CATransform3DMakeScale(0, 0, 0)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.blurView.addSubview(self.sendSuccesView)
                self.sendSuccesView.layer.transform = CATransform3DMakeScale(1, 1, 1)
                
                self.sendSuccesView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
                self.sendSuccesView.centerXAnchor.constraint(equalTo: self.blurView.centerXAnchor).isActive = true
                self.sendSuccesView.centerYAnchor.constraint(equalTo: self.blurView.centerYAnchor).isActive = true
                
                self.sendSuccesView.addSubview(self.sendSuccesIconImageView)
                self.sendSuccesIconImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 30, height: 30)
                self.sendSuccesIconImageView.centerXAnchor.constraint(equalTo: self.sendSuccesView.centerXAnchor).isActive = true
                self.sendSuccesIconImageView.centerYAnchor.constraint(equalTo: self.sendSuccesView.centerYAnchor).isActive = true
                
            }, completion: { (completed) in
                
                UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    
                    self.sendSuccesView.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                    self.sendSuccesView.alpha = 0
                    
                }, completion: { (_) in
                    
                    DispatchQueue.main.async {
                        self.blurView.removeFromSuperview()
                        self.addPlayerView(isShowing: false)
                        self.sendView.removeFromSuperview()
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            })
        }
    }
    
    func showCustomAlertMessage(image: UIImage, message: String) {
        DispatchQueue.main.async {
            
            self.view.addSubview(self.blurConnectionView)
            self.blurConnectionView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
            
            self.customAlertMessage.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
            
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.blurConnectionView.addSubview(self.customAlertMessage)
                self.customAlertMessage.anchor(top: nil, left: self.blurConnectionView.leftAnchor, bottom: nil, right: self.blurConnectionView.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
                self.customAlertMessage.centerYAnchor.constraint(equalTo: self.blurConnectionView.centerYAnchor).isActive = true
                
                self.customAlertMessage.iconMessage.image = image
                self.customAlertMessage.labelMessage.text = message
                
                self.customAlertMessage.transform = .identity
                
                self.tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissviewMessage))
                self.blurConnectionView.addGestureRecognizer(self.tap)
                self.tap.delegate = self
                
            }, completion: nil)
        }
    }
    
    func dismissviewMessage() {
        self.blurConnectionView.removeFromSuperview()
        self.blurConnectionView.removeGestureRecognizer(tap)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: customAlertMessage))!{
            return false
        }
        return true
    }
    
    func sendAudio() {
        
        // Check for internet connection
        if (reachability?.isReachable)! {
            
            DispatchQueue.main.async {
                
                self.view.addSubview(self.blurView)
                self.blurView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
                
                self.blurView.addSubview(self.loader)
                self.loader.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
                self.loader.centerYAnchor.constraint(equalTo: self.blurView.centerYAnchor).isActive = true
                self.loader.centerXAnchor.constraint(equalTo: self.blurView.centerXAnchor).isActive = true
                
            }
            
            if let userToken = Locksmith.loadDataForUserAccount(userAccount: "AuthToken") {
                
                let authToken = userToken["authenticationToken"] as! String
                print("the current user token: \(userToken)")
                
                DataService.instance.shareAudio(authToken: authToken, userId: userId!, audioUrl: self.finalUrl!, duration: self.finalDuration!, completion: { (success) in
                    if success {
                        self.showSuccesMessage()
                    }
                })
            }
            
        } else {
            self.showCustomAlertMessage(image: "😕".image(), message: "¡Revisa tu conexión de internet e intenta de nuevo!")
        }
        
        // Tracking each time user tap sendButton
        guard let userEmail = Locksmith.loadDataForUserAccount(userAccount: "currentUserEmail") else { return }
        Mixpanel.mainInstance().identify(distinctId: (userEmail as [String : AnyObject])["email"] as! String!)
        Mixpanel.mainInstance().track(event: "Pressed sendButton")
        
    }
}

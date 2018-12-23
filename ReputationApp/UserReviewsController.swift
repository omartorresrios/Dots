//
//  UserReviewsController.swift
//  ReputationApp
//
//  Created by Omar Torres on 10/12/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import Locksmith
import Alamofire
import AudioBot
import MediaPlayer
import Mixpanel

class UserReviewsController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.grayLow()
        return label
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
    
    let loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.gray)
        indicator.alpha = 1.0
        return indicator
    }()
    
    let searchingReviewsLabel: UILabel = {
        let ml = UILabel()
        ml.text = "buscando reseñas..."
        ml.font = UIFont(name: "SFUIDisplay-Regular", size: 14)
        ml.textColor = UIColor.grayLow()
        ml.numberOfLines = 1
        ml.textAlignment = .center
        return ml
    }()
    
    let blurConnectionView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.8)
        return view
    }()
    
    var userId: Int?
    var userFullname: String?
    var userImageUrl: String?
    
    var currentUserDic = [String: Any]()
    var reviews = [[String: Any]]()
    let viewGeneral = UIView()
    
    var reviewAudios = [Review]()
    
    var tap = UITapGestureRecognizer()
    var connectionTap = UITapGestureRecognizer()
    var goToListenTap = UITapGestureRecognizer()
    
    let customAlertMessage = CustomAlertMessage()
    let containerView = PreviewAudioContainerView()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionViewAndLayoutSetup()
        loaderContentElements()
        AudioBot.prepareForNormalRecord()
        
        tap = UITapGestureRecognizer(target: self, action: #selector(dismissContainerView))
        view.addGestureRecognizer(tap)
        tap.delegate = self
        
        loadUserReviewsWithCloseButton()
    }
    
    func loaderContentElements() {
        view.addSubview(loader)
        loader.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 60, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 20, height: 20)
        loader.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loader.startAnimating()
        
        view.addSubview(searchingReviewsLabel)
        searchingReviewsLabel.anchor(top: loader.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 4, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        searchingReviewsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func collectionViewAndLayoutSetup() {
        collectionView?.backgroundColor = .white
        
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
        }
        
        collectionView?.register(UserReviewsCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.isPagingEnabled = false
    }
    
    func loadUserReviewsWithCloseButton() {
        loadUserReviews { (success) in
            if success {
                self.loader.stopAnimating()
                self.searchingReviewsLabel.removeFromSuperview()
                self.view.addSubview(self.closeView)
                self.closeView.anchor(top: self.view.topAnchor, left: nil, bottom: nil, right: self.view.rightAnchor, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 30, height: 30)
                self.closeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.closeViewController)))
                
                self.closeView.addSubview(self.closeButton)
                self.closeButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 15, height: 15)
                self.closeButton.centerXAnchor.constraint(equalTo: self.closeView.centerXAnchor).isActive = true
                self.closeButton.centerYAnchor.constraint(equalTo: self.closeView.centerYAnchor).isActive = true
                self.closeButton.addTarget(self, action: #selector(self.closeViewController), for: .touchUpInside)
            }
        }
    }
    
    @objc func closeViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissContainerView() {
        containerView.dismiss(animated: true, completion: nil)
        view.removeGestureRecognizer(tap)
        containerView.playing = false
        AudioBot.pausePlay()
        containerView.audioLengthLabel.text = "0:00"
        containerView.progressView.progress = 0
    }
    
    func parseDuration(_ timeString:String) -> TimeInterval {
        guard !timeString.isEmpty else {
            return 0
        }
        
        var interval:Double = 0
        
        let parts = timeString.components(separatedBy: ":")
        for (index, part) in parts.reversed().enumerated() {
            interval += (Double(part) ?? 0) * pow(Double(60), Double(index))
        }
        
        return interval
    }
    
    func showMessageOfZeroContent() {
        
        self.view.addSubview(self.messageLabel)
        self.messageLabel.anchor(top: nil, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        self.messageLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        guard let boldNameFont = UIFont(name: "SFUIDisplay-Semibold", size: 15) else { return }
        guard let normalFont = UIFont(name: "SFUIDisplay-Regular", size: 15) else { return }
        
        let attributedMessage = NSMutableAttributedString(string: "\(self.userFullname!)", attributes: [kCTFontAttributeName as NSAttributedString.Key: boldNameFont])

        attributedMessage.append(NSMutableAttributedString(string: " aún no tiene reseñas 😲", attributes: [kCTFontAttributeName as NSAttributedString.Key: normalFont]))
        
        self.messageLabel.attributedText = attributedMessage
        
    }
    
    func showCustomAlertMessage(image: UIImage, message: String, isForLoadUsers: Bool) {
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
                
                if isForLoadUsers == true {
                    self.connectionTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissviewMessage))
                    self.blurConnectionView.addGestureRecognizer(self.connectionTap)
                    self.connectionTap.delegate = self
                } else { // It is for goToListen function in cellForRow
                    self.goToListenTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissGoToListenviewMessage))
                    self.blurConnectionView.addGestureRecognizer(self.goToListenTap)
                    self.goToListenTap.delegate = self
                }
                
                
            }, completion: nil)
        }
    }
    
    @objc func dismissGoToListenviewMessage() {
        self.blurConnectionView.removeFromSuperview()
        self.blurConnectionView.removeGestureRecognizer(self.goToListenTap)
        
    }
    
    @objc func dismissviewMessage() {
        self.dismiss(animated: true) {
            self.blurConnectionView.removeFromSuperview()
            self.blurConnectionView.removeGestureRecognizer(self.connectionTap)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: customAlertMessage))! {
            return false
        }
        return true
    }
    
    func loadUserReviews(completion: @escaping (Bool) -> ()) {
        DataService.instance.loadReviews(userId: userId!) { (array) in
            if array.count == 0 {
                self.showMessageOfZeroContent()
                completion(true)
            }
            
            array.forEach({ (value) in
                guard let reviewDictionary = value as? [String: Any] else { return }
                let duration = self.parseDuration(reviewDictionary["duration"] as! String)
                
                let reviewAudio = Review(fileURL: URL(string: reviewDictionary["audio"] as! String)!, duration: duration)
                self.reviewAudios.append(reviewAudio)
                self.reviews.append(reviewDictionary)
                self.collectionView?.reloadData()
                
                completion(true)
            })
        }
    }
    
    func setupReviewInfoViews() {
        present(containerView, animated: false, completion: nil)
    }
    
    var sheetController = UIAlertController()
    
    @objc func handleReportContentoptions () {
        sheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        sheetController.addAction(UIAlertAction(title: "Reportar", style: .destructive, handler: { (_) in
            let alert = UIAlertController(title: "", message: "Revisaremos tu reporte 🤔", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "¡Gracias!", style: UIAlertAction.Style.default, handler: nil))
            
            self.containerView.present(alert, animated: true, completion: nil)
        }))
        
        sheetController.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        
        containerView.present(sheetController, animated: true, completion: nil)
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviews.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserReviewsCell
        
        cell.backgroundColor = .white
        
        var review = reviews[indexPath.item]
        var audioReview = reviewAudios[indexPath.item]

        var receiverData = review["receiver"] as! [String: Any]

        var senderData = review["sender"] as! [String: Any]
        
        let fullName = senderData["fullname"] as! String
        cell.fullnameLabel.text = fullName

        let avatarUrl = senderData["avatarUrl"] as! String
        cell.profileImageView.loadImage(urlString: avatarUrl)
        
        let createdAt  = review["createdAt"] as! String
        
        // deleting the Z in the final
        let zEndIndex = createdAt.index(createdAt.endIndex, offsetBy: -1)
        let finalWihtOutZ = createdAt.substring(to: zEndIndex)
        
        // deleting the last 3 characters
        let last4endIndex = finalWihtOutZ.index(finalWihtOutZ.endIndex, offsetBy: -4)
        let finalWihtOut4 = finalWihtOutZ.substring(to: last4endIndex)
        
        // adding the Z to the end
        let finalCreatedAt = finalWihtOut4 + "Z"
        
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: finalCreatedAt)!
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        dateFormatter.locale = tempLocale // reset the locale
        let dateString = dateFormatter.string(from: date)
        
        cell.timeLabel.text = date.timeAgoDisplay()
            
        cell.goToListen = {
//            if (reachability?.isReachable)! {
            
                UIApplication.shared.isStatusBarHidden = true
            
                self.setupReviewInfoViews()
                
                self.containerView.profileImageView.loadImage(urlString: avatarUrl)
                self.containerView.fullnameLabel.text = fullName
                self.containerView.optionButton.addTarget(self, action: #selector(self.handleReportContentoptions), for: .touchUpInside)
                
                let duration = NSInteger(audioReview.duration)
                let seconds = String(format: "%02d", duration % 60)
                let minutes = (duration / 60) % 60
                
                self.containerView.audioLengthLabel.text = "\(minutes):\(seconds)"
                
                self.containerView.playOrPauseAudioAction = { [weak self] cell, progressView in
                    func tryPlay() {
                        do {
                            AudioBot.reportPlayingDuration = { duration in
                                
                                let ti = NSInteger(duration)
                                
                                let seconds = String(format: "%02d", ti % 60)
                                let minutes = String(format: "%2d", (ti / 60) % 60)
                                
                                self?.containerView.audioLengthLabel.text = "\(minutes):\(seconds)"
                            }
                            let progressPeriodicReport: AudioBot.PeriodicReport = (reportingFrequency: 10, report: { progress in
                                print("progress: \(progress)")
                                audioReview.progress = CGFloat(progress)
                                progressView.progress = progress
                            })
                            
                            let fromTime = TimeInterval(audioReview.progress) * audioReview.duration
                            try AudioBot.startPlayAudioAtFileURL(audioReview.fileURL, fromTime: fromTime, withProgressPeriodicReport: progressPeriodicReport, finish: { success in
                                audioReview.playing = false
                                cell.playing = false
                            })
                            print("LET SEE: ", audioReview.fileURL)
                            audioReview.playing = true
                            cell.playing = true
                        } catch {
                            print("play error: \(error)")
                        }
                    }
                    if AudioBot.isPlaying {
                        AudioBot.pausePlay()
                        audioReview.playing = false
                        cell.playing = false
                        
                        //                tryPlay()
                        //                review.playing = false
                        //                cell.playing = false
                        //                if let strongSelf = self {
                        //                    for index in 0..<(strongSelf.reviews).count {
                        //                        var voiceMemo = strongSelf.reviews[index]
                        //                        if AudioBot.playingFileURL == voiceMemo.fileURL {
                        //                            let indexPath = IndexPath(row: index, section: 0)
                        //                            if let cell = collectionView.cellForItem(at: indexPath) as? UserReviewsCell {
                        //                                voiceMemo.playing = false
                        //                                cell.playing = false
                        //                            }
                        //                            break
                        //                        }
                        //                    }
                        //                }
                        //                    if AudioBot.playingFileURL != review.fileURL {
                        //                        tryPlay()
                        //                    }
                    } else {
                        tryPlay()
                    }
                    
                    // Tracking each time user tap playOrPauseAudioAction
                    guard let userEmail = Locksmith.loadDataForUserAccount(userAccount: "currentUserEmail") else { return }
                    Mixpanel.mainInstance().identify(distinctId: (userEmail as [String : AnyObject])["email"] as! String!)
                    Mixpanel.mainInstance().track(event: "Pressed playOrPauseAudioAction")
                }
            
                // Tracking each time user tap goToListen
                guard let userEmail = Locksmith.loadDataForUserAccount(userAccount: "currentUserEmail") else { return }
                Mixpanel.mainInstance().identify(distinctId: (userEmail as [String : AnyObject])["email"] as! String!)
                Mixpanel.mainInstance().track(event: "Pressed goToListen")
                
//            } else {
//                self.showCustomAlertMessage(image: "😕".image(), message: "¡Revisa tu conexión de internet e intenta de nuevo!", isForLoadUsers: false)
//            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        var height: CGFloat = 50 + 8 + 8 //username userprofileimageview
        height += 30
        height += 10
        return CGSize(width: (width - 2) / 3, height: height)
    }
    
}

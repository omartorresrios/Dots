//
//  MyStoriesController.swift
//  ReputationApp
//
//  Created by Omar Torres on 21/01/18.
//  Copyright © 2018 OmarTorres. All rights reserved.
//

import UIKit
import Locksmith
import Alamofire
import Haneke
import MediaPlayer

class MyStoriesController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    var userId: Int?
    var userFullname: String?
    var userEmail: String?
    var userImageUrl: String?
    var currentUserDic = [String: Any]()
    var images: [NSURL] = []
    var urls = [String]()
    var durations = [String]()
    let userFeedCell = "userFeedCell"
    var eventVideos = [Event]()
    var stories = [[String: Any]]()
    var finalDuration: TimeInterval?
    var tap = UITapGestureRecognizer()
    var connectionTap = UITapGestureRecognizer()
    var goToListenTap = UITapGestureRecognizer()
    let customAlertMessage = CustomAlertMessage()
    
    let closeView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.backgroundColor = UIColor.mainGreen()
        return view
    }()
    
    let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "close").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    let loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        indicator.alpha = 1.0
        return indicator
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "SFUIDisplay-Regular", size: 15)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.grayLow()
        return label
    }()
    
    let blurConnectionView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.8)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom:8, right: 8)
        }
        
        // Register cell classes
        collectionView?.register(UserFeedCell.self, forCellWithReuseIdentifier: userFeedCell)
        collectionView?.isPagingEnabled = false
        
        view.addSubview(loader)
        loader.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 60, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 20, height: 20)
        loader.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loader.startAnimating()
        
        loadUserEventsWithCloseButton()
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
    
    func dismissGoToListenviewMessage() {
        self.blurConnectionView.removeFromSuperview()
        self.blurConnectionView.removeGestureRecognizer(self.goToListenTap)
        
    }
    
    func dismissviewMessage() {
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
    
    func loadUserEventsWithCloseButton() {
        loadUserEvents { (success) in
            if success {
                self.loader.stopAnimating()
                self.view.addSubview(self.closeView)
                self.closeView.anchor(top: self.view.topAnchor, left: nil, bottom: nil, right: self.view.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 30, height: 30)
                self.closeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.closeViewController)))
                
                self.closeView.addSubview(self.closeButton)
                self.closeButton.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 10, height: 10)
                self.closeButton.centerXAnchor.constraint(equalTo: self.closeView.centerXAnchor).isActive = true
                self.closeButton.centerYAnchor.constraint(equalTo: self.closeView.centerYAnchor).isActive = true
                self.closeButton.addTarget(self, action: #selector(self.closeViewController), for: .touchUpInside)
            }
        }
    }
    
    func closeViewController() {
        self.dismiss(animated: true, completion: nil)
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
        self.messageLabel.anchor(top: nil, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        self.messageLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.messageLabel.text = "Aún no tienes momentos 😒"
        
    }
    
    func loadUserEvents(completion: @escaping (Bool) -> ()) {
        
        // Check for internet connection
        if (reachability?.isReachable)! {
            
            // Retreieve Auth_Token from Keychain
            if let userToken = Locksmith.loadDataForUserAccount(userAccount: "AuthToken") {
                
                let authToken = userToken["authenticationToken"] as! String
                
                // Set Authorization header
                let header = ["Authorization": "Token token=\(authToken)"]
                
                Alamofire.request("https://protected-anchorage-18127.herokuapp.com/api/\(userId!)/events", method: .get, parameters: nil, encoding: URLEncoding.default, headers: header).responseJSON { response in
                    
                    print("request: \(response.request!)") // original URL request
                    print("response: \(response.response!)") // URL response
                    print("response data: \(response.data!)") // server data
                    print("result: \(response.result)") // result of response serialization
                    
                    switch response.result {
                    case .success(let JSON):
                        
                        let jsonArray = JSON as! [[String: Any]]
                        
                        if jsonArray.count == 0 {
                            self.showMessageOfZeroContent()
                            completion(true)
                        }
                        
                        for item in (JSON as? [[String: Any]])! {
                            guard let storieDictionary = item as? [String: Any] else { return }
                            
                            let event_url = storieDictionary["event_url"] as! String
                            let duration = storieDictionary["duration"] as! String
                            let createdAt = storieDictionary["created_at"] as! String
                            let userFullname = storieDictionary["user_fullname"] as! String
                            
                            self.finalDuration = self.parseDuration(duration)
                            
                            let endIndex = event_url.index(event_url.endIndex, offsetBy: -11)
                            let finalEventUrl = event_url.substring(to: endIndex)
                            
                            let cache = Shared.dataCache
                            let URL = NSURL(string: finalEventUrl)!
                            
                            cache.fetch(URL: URL as URL).onSuccess { (data) in
                                let path = NSURL(string: DiskCache.basePath())!.appendingPathComponent("shared-data/original")
                                let cached = DiskCache(path: (path?.absoluteString)!).path(forKey: String(describing: URL))
                                let file = NSURL(fileURLWithPath: cached)
                                
                                let eventVideo = Event(duration: self.finalDuration!, event_url: finalEventUrl, imageUrl: file, createdAt: createdAt, userFullname: userFullname)
                                self.eventVideos.append(eventVideo)
                                
                                self.eventVideos.sort(by: { (e1, e2) -> Bool in
                                    return e1.createdAt.compare(e2.createdAt) == .orderedDescending
                                })
                                
                                self.collectionView?.reloadData()
                                
                                completion(true)
                                
                            }
                        }
                        
                    case .failure(let error):
                        print(error)
                        completion(false)
                    }
                    
                }
            }
            
        } else {
            self.loader.stopAnimating()
            self.showCustomAlertMessage(image: "😕".image(), message: "¡Revisa tu conexión de internet e intenta de nuevo!", isForLoadUsers: true)
        }
        
    }
    
    // define a variable to store initial touch position
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    
    func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.previewVideoContainerView.view?.window)
        
        if sender.state == UIGestureRecognizerState.began {
            initialTouchPoint = touchPoint
        } else if sender.state == UIGestureRecognizerState.changed {
            if touchPoint.y - initialTouchPoint.y > 0 {
                self.previewVideoContainerView.view.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.previewVideoContainerView.view.frame.size.width, height: self.previewVideoContainerView.view.frame.size.height)
            }
        } else if sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled {
            if touchPoint.y - initialTouchPoint.y > 100 {
                self.previewVideoContainerView.dismiss(animated: true, completion: nil)
                self.player.pause()
                self.playerLayer.removeFromSuperlayer()
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.previewVideoContainerView.view.frame = CGRect(x: 0, y: 0, width: self.previewVideoContainerView.view.frame.size.width, height: self.previewVideoContainerView.view.frame.size.height)
                })
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventVideos.count//images.count
    }
    
    let previewVideoContainerView = PreviewVideoContainerView()
    var player = AVPlayer()
    var playerLayer = AVPlayerLayer()
    var sheetController = UIAlertController()
    
    func handleReportContentoptions () {
        sheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        sheetController.addAction(UIAlertAction(title: "Reportar", style: .destructive, handler: { (_) in
            let alert = UIAlertController(title: "", message: "Revisaremos tu reporte 🤔", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "¡Gracias!", style: UIAlertActionStyle.default, handler: nil))
            
            self.previewVideoContainerView.present(alert, animated: true, completion: nil)
        }))
        
        sheetController.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        previewVideoContainerView.present(sheetController, animated: true, completion: nil)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userFeedCell, for: indexPath) as! UserFeedCell
        
        //        let image = self.images[indexPath.item].absoluteString!
        //        let url = self.urls[indexPath.item]
        let event = eventVideos[indexPath.item]
        //        let storie = stories[indexPath.item]
        
        let createdAt = event.createdAt//storie["created_at"] as! String
        let fullname = event.userFullname//storie["user_fullname"] as! String
        
        var imageCache = [String: UIImage]()
        var lastURLUsedToLoadImage: String?
        var defaultImg: UIImage!
        
        cell.photoImageView.image = nil // PUT A PLACEHOLDER
        
        if let url = URL(string: event.imageUrl.absoluteString!) {
            lastURLUsedToLoadImage = url.absoluteString
            
            if let cachedImage = imageCache[url.absoluteString] {
                cell.photoImageView.image =  cachedImage
                print("nothing")
            }
            
            let asset:AVAsset = AVAsset(url: url)
            
            let durationSeconds = CMTimeGetSeconds(asset.duration)
            let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            
            assetImgGenerate.appliesPreferredTrackTransform = true
            
            let time        : CMTime = CMTimeMakeWithSeconds(durationSeconds/3.0, 600)
            var img         : CGImage
            
            do {
                img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                let frameImg: UIImage = UIImage(cgImage: img)
                
                if url.absoluteString != lastURLUsedToLoadImage {
                    print("nothing")
                }
                
                imageCache[url.absoluteString] = frameImg
                
                DispatchQueue.main.async {
                    cell.photoImageView.image =  frameImg
                    defaultImg = frameImg
                }
                
            } catch let error as NSError {
                print("ERROR: \(error)")
                cell.photoImageView.image = nil
            }
            
        } else {
            print("THE URL DOES NOT EXIST")
        }
        
        //        let duration = NSInteger(event.duration)
        //        let seconds = String(format: "%02d", duration % 60)
        //        let minutes = (duration / 60) % 60
        //        cell.videoLengthLabel.setTitle("\(minutes):\(seconds)", for: .normal)
        
        cell.goToWatch = {
            
            // Check for internet connection
            if (reachability?.isReachable)! {
                
                self.present(self.previewVideoContainerView, animated: false, completion: nil)
                self.previewVideoContainerView.defaultImage.image = defaultImg
                
                let videoURL = URL(string: event.event_url)
                self.player = AVPlayer(url: videoURL!)
                self.playerLayer = AVPlayerLayer(player: self.player)
                
                self.playerLayer.frame = self.previewVideoContainerView.view.bounds
                
                self.previewVideoContainerView.view.layer.addSublayer(self.playerLayer)
                
                self.previewVideoContainerView.defaultImage.layer.zPosition = -5
                
                self.player.play()
                
                self.playerLayer.zPosition = -5
                
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
                
                let timeLabel = UILabel()
                timeLabel.tintColor = .black
                timeLabel.backgroundColor = .yellow
                timeLabel.text = date.timeAgoDisplay()
                
                self.previewVideoContainerView.videoLengthLabel.text = timeLabel.text
                self.previewVideoContainerView.userNameLabel.text = fullname
                self.previewVideoContainerView.optionButton.addTarget(self, action: #selector(self.handleReportContentoptions), for: .touchUpInside)
                
                let tapGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureRecognizerHandler(_:)))
                self.previewVideoContainerView.view.addGestureRecognizer(tapGesture)
                
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: nil, using: { (_) in
                    DispatchQueue.main.async {
                        self.playerLayer.removeFromSuperlayer()
                        self.sheetController.dismiss(animated: true, completion: nil)
                        self.previewVideoContainerView.dismiss(animated: false, completion: nil)
                    }
                })
                
            } else {
                self.showCustomAlertMessage(image: "😕".image(), message: "¡Revisa tu conexión de internet e intenta de nuevo!", isForLoadUsers: false)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 32) / 3
        return CGSize(width: width, height: width + 60)
    }
}

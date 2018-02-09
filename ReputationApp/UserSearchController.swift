//
//  UserSearchController.swift
//  ReputationApp
//
//  Created by Omar Torres on 26/05/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import Alamofire
import Locksmith
import AVFoundation
import googleapis

let SAMPLE_RATE = 16000

class UserSearchController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, AudioControllerDelegate {
    
    let httpHelper = HTTPHelper()
    let cellId = "cellId"
    var filteredUsers = [User]()
    var users = [User]()
    var currentUserDic = [String: Any]()
    var collectionView: UICollectionView!
    var userSelected: User!
    var audioData: NSMutableData!
    let customAlertMessage = CustomAlertMessage()
    var tap = UITapGestureRecognizer()
    var alertTap = UITapGestureRecognizer()
    var connectionTap = UITapGestureRecognizer()
    let userContentOptionsView = UserContentOptionsView()
    var userFullnameSelected: String!
    
    let loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        indicator.alpha = 1.0
        indicator.startAnimating()
        return indicator
    }()
    
    let messageLabel: UILabel = {
        let ml = UILabel()
        ml.font = UIFont(name: "SFUIDisplay-Regular", size: 15)
        ml.textColor = UIColor.grayLow()
        ml.numberOfLines = 0
        ml.textAlignment = .center
        return ml
    }()
    
    let userInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    let searchButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "record").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.mainGreen()
        button.addTarget(self, action: #selector(recordAudio(_:)), for: .touchUpInside)
        return button
    }()
    
    let supportAlertView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)
        return view
    }()
    
    let blurConnectionView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.8)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 90, height: 120)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UserSearchCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.backgroundColor = .white
        self.view.addSubview(collectionView)
        
        AudioController.sharedInstance.delegate = self
        
        // Reachability for checking internet connection
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityStatusChanged), name: NSNotification.Name(rawValue: "ReachStatusChanged"), object: nil)
        
        navigationController?.navigationBar.isHidden = true
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        collectionView.isHidden = true
        layout.sectionHeadersPinToVisibleBounds = true
        
        // Initialize the loader and position it
        view.addSubview(loader)
        loader.center = view.center
        
        // Position the messageLabel
        view.addSubview(messageLabel)
        messageLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // Initialize functions
        loadAllUsers { (success) in
            if success {
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AllUsersLoaded"), object: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // General properties of the view
        navigationController?.tabBarController?.tabBar.isHidden = false
        UIApplication.shared.isStatusBarHidden = true
    }
    
    func animateRecordButton() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1.0, delay: 0.0, options:[.repeat, .autoreverse], animations: {
                self.searchButton.tintColor = UIColor.rgb(red: 125, green: 125, blue: 225)
            }, completion:  nil)
        }
    }
    
    func loadAllUsers(completion: @escaping (Bool) -> ()) {
        // Check for internet connection
        if (reachability?.isReachable)! {
            
            // Retreieve Auth_Token from Keychain
            if let userToken = Locksmith.loadDataForUserAccount(userAccount: "AuthToken") {
                
                let authToken = userToken["authenticationToken"] as! String
                
                print("Token: \(userToken)")
                
                // Set Authorization header
                let header = ["Authorization": "Token token=\(authToken)"]
                
                print("THE HEADER: \(header)")
                
                Alamofire.request("https://protected-anchorage-18127.herokuapp.com/api/all_users", method: .get, parameters: nil, encoding: URLEncoding.default, headers: header).responseJSON { (response) in
                    switch response.result {
                    case .success(let JSON):
                        print("THE JSON: \(JSON)")
                        
                        let jsonArray = JSON as! NSDictionary
                        
                        let dataArray = jsonArray["users"] as! NSArray
                        
                        dataArray.forEach({ (value) in
                            guard let userDictionary = value as? [String: Any] else { return }
                            print("this is userDictionary: \(userDictionary)")
                            
                            guard let userIdFromKeyChain = Locksmith.loadDataForUserAccount(userAccount: "currentUserId") else { return }
                            
                            let userId = userIdFromKeyChain["id"] as! Int
                            
                            if userDictionary["id"] as! Int == userId {
                                print("Found myself, omit from list")
                                self.currentUserDic = userDictionary
                                return
                            }
                            let user = User(uid: userDictionary["id"] as! Int, dictionary: userDictionary)
                            self.users.append(user)
                            
                        })
                        
                        self.users.sort(by: { (u1, u2) -> Bool in
                            
                            return u1.fullname.compare(u2.fullname) == .orderedAscending
                            
                        })
                        
                        self.filteredUsers = self.users
                        self.collectionView.reloadData()
                        
                        completion(true)
                        
                        self.view.addSubview(self.searchButton)
                        self.searchButton.anchor(top: nil, left: nil, bottom: self.view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 50, height: 50)
                        self.searchButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                        
                        self.searchButton.adjustsImageWhenHighlighted = false
                        
                        self.loader.stopAnimating()
                        
                    case .failure(let error):
                        print(error)
                        completion(false)
                    }
                }
            }
        } else {
            self.loader.stopAnimating()
            self.showCustomAlertMessage(image: "😕".image(), message: "¡Revisa tu conexión de internet e intenta de nuevo!", isForTimeOut: false)
        }
    }
    
    func wordForSearch(word: String) {
        filteredUsers = self.users.filter { (user) -> Bool in
            return user.fullname.lowercased().contains(word.lowercased())
        }
        
        // Check is there are results
        if filteredUsers.isEmpty {
            messageLabel.isHidden = false
            messageLabel.text = "🙁 No encontramos a esa persona."
            searchButton.tintColor = UIColor.mainGreen()
            loader.stopAnimating()
        } else {
            messageLabel.isHidden = true
            loader.stopAnimating()
            collectionView.isHidden = false
        }
        collectionView?.reloadData()
    }
    
    func showCustomAlertMessage(image: UIImage, message: String, isForTimeOut: Bool) {
        
        DispatchQueue.main.async {
            
            self.loader.stopAnimating()
            self.searchButton.isHidden = true
            
            self.customAlertMessage.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
            
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                
                self.view.addSubview(self.supportAlertView)
                self.supportAlertView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
                
                self.supportAlertView.addSubview(self.customAlertMessage)
                self.customAlertMessage.anchor(top: nil, left: self.supportAlertView.leftAnchor, bottom: nil, right: self.supportAlertView.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
                self.customAlertMessage.centerYAnchor.constraint(equalTo: self.supportAlertView.centerYAnchor).isActive = true
                
                self.customAlertMessage.iconMessage.image = image
                self.customAlertMessage.labelMessage.text = message
                
                self.customAlertMessage.transform = .identity
                
                if isForTimeOut == true {
                    self.alertTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertMessage))
                    self.supportAlertView.addGestureRecognizer(self.alertTap)
                    self.alertTap.delegate = self
                } else { // It is for internet connection when tap the record button
                    self.connectionTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissConnectionviewMessage))
                    self.supportAlertView.addGestureRecognizer(self.connectionTap)
                    self.connectionTap.delegate = self
                }
                
                
            }, completion: nil)
        }
    }
    
    func dismissConnectionviewMessage() {
        supportAlertView.removeFromSuperview()
        self.searchButton.isHidden = false
        supportAlertView.removeGestureRecognizer(self.connectionTap)
    }
    
    func dismissContainerView() {
        userContentOptionsView.removeFromSuperview()
        userContentOptionsView.viewGeneral.removeGestureRecognizer(tap)
    }
    
    func dismissAlertMessage() {
        supportAlertView.removeFromSuperview()
        resetAudio()
        searchButton.tintColor = UIColor.mainGreen()
        collectionView.backgroundColor = .white
        supportAlertView.removeGestureRecognizer(alertTap)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: userContentOptionsView.viewSupport))! || (touch.view?.isDescendant(of: customAlertMessage))! {
            return false
        }
        return true
    }
    
    func processSampleData(_ data: Data) -> Void {
        
        audioData.append(data)

        // We recommend sending samples in 100ms chunks
        let chunkSize : Int /* bytes/chunk */ = Int(0.1 /* seconds/chunk */
            * Double(SAMPLE_RATE) /* samples/second */
            * 2 /* bytes/sample */);
        
        if (audioData.length > chunkSize) {
            SpeechRecognitionService.sharedInstance.streamAudioData(audioData, completion: { [weak self] (response, error) in
                
                guard let strongSelf = self else {
                    return
                }

                if let error = error {
                    
                    print("OCURRIÓ UN ERROR: ", error)
                    self?.loader.stopAnimating()
                    
                    self?.showCustomAlertMessage(image: "💩".image(), message: "¡Hubo un problema!\n\n1. Se excedió el tiempo de espera (1 min. máx.) ó\n2. Tu tono de voz fue muy bajo.", isForTimeOut: true)
                    
                    self?.searchButton.isHidden = true
                    
                } else if let response = response {
                    
                    self?.loader.startAnimating()
                    self?.loader.isHidden = false
                    self?.searchButton.tintColor = UIColor.mainGreen()
                    
                    var finished = false
                    print(response)
                    for result in response.resultsArray! {
                        if let result = result as? StreamingRecognitionResult {
                            if result.isFinal {
                                finished = true
                            }

                            for alternative in result.alternativesArray! {
                                if let transcript = alternative as? SpeechRecognitionAlternative {
                                    for word in transcript.wordsArray! {
                                        if let word = word as? WordInfo {
                                            self?.wordForSearch(word: word.word)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    if finished {
                        strongSelf.stopAudio(strongSelf)
                    }
                }
            })
            self.audioData = NSMutableData()
        }
    }
    
    func recordAudio(_ sender: NSObject) {
        // Check for internet connection
        if (reachability?.isReachable)! {
            
            messageLabel.isHidden = true
            self.animateRecordButton()
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(AVAudioSessionCategoryRecord)
            } catch {
                
            }
            audioData = NSMutableData()
            _ = AudioController.sharedInstance.prepare(specifiedSampleRate: SAMPLE_RATE)
            SpeechRecognitionService.sharedInstance.sampleRate = SAMPLE_RATE
            _ = AudioController.sharedInstance.start()
            
        } else {
            self.showCustomAlertMessage(image: "😕".image(), message: "¡Revisa tu conexión de internet e intenta de nuevo!", isForTimeOut: false)
        }
    }
    
    func stopAudio(_ sender: NSObject) {
        _ = AudioController.sharedInstance.stop()
        SpeechRecognitionService.sharedInstance.stopStreaming()
    }
    
    func resetAudio() {
        _ = AudioController.sharedInstance.stop()
        SpeechRecognitionService.sharedInstance.stopStreaming()
        searchButton.isHidden = false
    }
    
    func showUserStoriesView() {
        let userStoriesController = UserStoriesController(collectionViewLayout: UICollectionViewFlowLayout())
        
        userStoriesController.userId = userSelected.id
        userStoriesController.userFullname = userSelected.fullname
        userStoriesController.userImageUrl = userSelected.profileImageUrl
        userStoriesController.currentUserDic = currentUserDic
        
        present(userStoriesController, animated: true) {
            self.userContentOptionsView.removeFromSuperview()
        }
    }
    
    func showUserReviewsView() {
        let userReviewsController = UserReviewsController(collectionViewLayout: UICollectionViewFlowLayout())

        userReviewsController.userId = userSelected.id
        userReviewsController.userFullname = userSelected.fullname
        userReviewsController.userImageUrl = userSelected.profileImageUrl
        userReviewsController.currentUserDic = currentUserDic

        present(userReviewsController, animated: true) {
            self.userContentOptionsView.removeFromSuperview()
        }
    }
    
    func showWriteReviewView() {
        let writeReviewController = WriteReviewController()

        writeReviewController.userId = userSelected.id
        writeReviewController.userFullname = userSelected.fullname
        writeReviewController.userImageUrl = userSelected.profileImageUrl
        writeReviewController.currentUserDic = currentUserDic

        present(writeReviewController, animated: true) {
            self.userContentOptionsView.removeFromSuperview()
        }
    }
    
    func blockUserView() {
        let alert = UIAlertController(title: "", message: "Bloqueaste a \(self.userFullnameSelected!)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func setupUserInfoViewsContainers() {
        
        userContentOptionsView.viewSupport.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            
            self.view.addSubview(self.userContentOptionsView)
            self.userContentOptionsView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
            
            let storiesTap = UITapGestureRecognizer(target: self, action: #selector(self.showUserStoriesView))
            self.userContentOptionsView.storiesViewContainer.addGestureRecognizer(storiesTap)
            
            let reviewsTap = UITapGestureRecognizer(target: self, action: #selector(self.showUserReviewsView))
            self.userContentOptionsView.reviewsViewContainer.addGestureRecognizer(reviewsTap)
            
            self.userContentOptionsView.reviewsViewContainer.layoutIfNeeded()
            self.userContentOptionsView.reviewsViewContainer.layer.addBorder(edge: .top, color: .gray, thickness: 1)
            
            self.userContentOptionsView.writeReviewViewContainer.layoutIfNeeded()
            self.userContentOptionsView.writeReviewViewContainer.layer.addBorder(edge: .top, color: .gray, thickness: 1)

            let writeTap = UITapGestureRecognizer(target: self, action: #selector(self.showWriteReviewView))
            self.userContentOptionsView.writeReviewViewContainer.addGestureRecognizer(writeTap)
            
            let blockTap = UITapGestureRecognizer(target: self, action: #selector(self.blockUserView))
            self.userContentOptionsView.blockUserViewContainer.addGestureRecognizer(blockTap)
            
            self.tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissContainerView))
            self.userContentOptionsView.viewGeneral.addGestureRecognizer(self.tap)
            self.tap.delegate = self
            
            self.userContentOptionsView.viewSupport.transform = .identity
            
        }, completion: nil)
        
    }
    
    func reachabilityStatusChanged() {
        print("Checking connectivity...")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let user = filteredUsers[indexPath.item]
        userSelected = user
        userFullnameSelected = user.fullname
        setupUserInfoViewsContainers()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserSearchCell
        
        cell.user = filteredUsers[indexPath.item]
        
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
        return CGSize(width: width, height: width + 20)
    }
    
}



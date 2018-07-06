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
import Mixpanel

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
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
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
    
    let resultLabel: UILabel = {
        let ml = UILabel()
        ml.text = "Busca a alguien"
        ml.font = UIFont(name: "SFUIDisplay-Medium", size: 16)
        ml.textColor = UIColor.grayLow()
        ml.numberOfLines = 1
        ml.textAlignment = .center
        return ml
    }()
    
    let searchingPeopleLabel: UILabel = {
        let ml = UILabel()
        ml.text = "buscando mamberos..."
        ml.font = UIFont(name: "SFUIDisplay-Regular", size: 14)
        ml.textColor = UIColor.grayLow()
        ml.numberOfLines = 1
        ml.textAlignment = .center
        return ml
    }()
    
    let cameraViewImage: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "camera").withRenderingMode(.alwaysTemplate)
        iv.tintColor = UIColor.mainGreen()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let divideView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topElements()
        collectionViewAndLayoutSetup()
        navigationController?.navigationBar.isHidden = true
        AudioController.sharedInstance.delegate = self
        
        // Reachability for checking internet connection
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityStatusChanged), name: NSNotification.Name(rawValue: "ReachStatusChanged"), object: nil)
        
        loaderContentElements()
        
        // Initialize functions
        loadAllUsers { (success) in
            if success {
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AllUsersLoaded"), object: nil)
            }
        }
        check_record_permission()
        
    }
    
    func topElements() {
        view.addSubview(cameraViewImage)
        cameraViewImage.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 28, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 25, height: 25)
        cameraViewImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToCamera)))
        cameraViewImage.isUserInteractionEnabled = true
        
        view.addSubview(divideView)
        divideView.anchor(top: cameraViewImage.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    func collectionViewAndLayoutSetup() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        let width = (view.frame.width - 32) / 3
        layout.itemSize = CGSize(width: width, height: width + 40)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UserSearchCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.backgroundColor = .white
        self.view.addSubview(collectionView)
        collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 62, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        collectionView.isHidden = true
        layout.sectionHeadersPinToVisibleBounds = true
    }
    
    func loaderContentElements() {
        // Initialize the loader and position it
        view.addSubview(loader)
        loader.center = view.center
        
        view.addSubview(searchingPeopleLabel)
        searchingPeopleLabel.anchor(top: loader.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 4, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        searchingPeopleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // Position the messageLabel
        view.addSubview(messageLabel)
        messageLabel.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    @objc func goToCamera() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GoToCameraViewFromUserSearchController"), object: nil)
    }
    
    func check_record_permission() {
        switch AVAudioSession.sharedInstance().recordPermission() {
        case AVAudioSessionRecordPermission.granted:
            print("vao")
            break
        case AVAudioSessionRecordPermission.denied:
            print("no vao")
            break
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("vao")
                    } else {
                        print("no vao")
                    }
                }
            }
            break
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // General properties of the view
        navigationController?.tabBarController?.tabBar.isHidden = false
    }
    
    func animateRecordButton() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1.0, delay: 0.0, options:[.repeat, .autoreverse], animations: {
                self.searchButton.tintColor = UIColor.rgb(red: 125, green: 125, blue: 225)
            }, completion:  nil)
        }
    }
    
    func loadAllUsers(completion: @escaping (Bool) -> ()) {
//        // Check for internet connection
//        if (reachability?.isReachable)! {
        
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
                        
                        self.stopButton.isHidden = true
                        self.stopButton.isUserInteractionEnabled = false

                        self.searchButton.isHidden = false
                        self.searchButton.isUserInteractionEnabled = true
                        
                        self.view.addSubview(self.resultLabel)
                        self.resultLabel.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
                        self.resultLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                        self.resultLabel.centerYAnchor.constraint(equalTo: self.cameraViewImage.centerYAnchor).isActive = true
                        
                        self.loader.stopAnimating()
                        self.searchingPeopleLabel.removeFromSuperview()
                        
                    case .failure(let error):
                        print(error)
                        completion(false)
                    }
                }
            }
//        } else {
//            self.loader.stopAnimating()
//            self.showCustomAlertMessage(image: "😕".image(), message: "¡Revisa tu conexión de internet e intenta de nuevo!", isForTimeOut: false)
//        }
    }
    
    func wordForSearch(word: String) {
        stopButton.isHidden = true
        stopButton.isUserInteractionEnabled = false
        
        filteredUsers = self.users.filter { (user) -> Bool in
            return user.fullname.lowercased().contains(word.lowercased())
        }
        
        // Check is there are results
        if filteredUsers.isEmpty {
            DispatchQueue.main.async {
                self.messageLabel.isHidden = false
                self.messageLabel.text = "No encontramos a esa persona 🙁"
                self.searchButton.tintColor = UIColor.mainGreen()
                self.loader.stopAnimating()
            }
            
        } else {
            DispatchQueue.main.async {
                self.messageLabel.isHidden = true
                self.loader.stopAnimating()
                self.collectionView.isHidden = false
                self.collectionView.addSubview(self.searchButton)
                self.collectionView.addSubview(self.stopButton)
            }
        }
        collectionView?.reloadData()
    }
    
    func showCustomAlertMessage(image: UIImage, message: String, isForTimeOut: Bool) {
        
        DispatchQueue.main.async {
            
            self.loader.stopAnimating()
            self.searchButton.isHidden = true
            self.stopButton.isHidden = true
            
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
    
    @objc func dismissConnectionviewMessage() {
        supportAlertView.removeFromSuperview()
        self.searchButton.isHidden = false
        supportAlertView.removeGestureRecognizer(self.connectionTap)
    }
    
    @objc func dismissContainerView() {
        userContentOptionsView.removeFromSuperview()
        userContentOptionsView.viewGeneral.removeGestureRecognizer(tap)
    }
    
    @objc func dismissAlertMessage() {
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
                    self?.stopButton.isHidden = true
                    
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
    
    @IBAction func recordAudio(_ sender: NSObject) {
        
        // Tracking each time user tap searchButton
        guard let userEmail = Locksmith.loadDataForUserAccount(userAccount: "currentUserEmail") else { return }
        Mixpanel.mainInstance().identify(distinctId: (userEmail as [String : AnyObject])["email"] as! String!)
        Mixpanel.mainInstance().track(event: "Pressed searchButton")
        
        // Check for internet connection
        if (reachability?.isReachable)! {
            DispatchQueue.main.async {
                self.searchButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                    self.searchButton.transform = .identity
                }, completion: nil)
                
                self.stopButton.isHidden = false
                self.stopButton.isUserInteractionEnabled = true
                self.messageLabel.isHidden = true
            }
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
    
    @IBAction func stopAudioFromStopButton() {
        DispatchQueue.main.async {
            self.stopButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.stopButton.transform = .identity
            }, completion: nil)
        }
        _ = AudioController.sharedInstance.stop()
        SpeechRecognitionService.sharedInstance.stopStreaming()
    }
    
    func resetAudio() {
        _ = AudioController.sharedInstance.stop()
        SpeechRecognitionService.sharedInstance.stopStreaming()
        searchButton.isHidden = false
    }
    
    @objc func showUserStoriesView() {
        let userStoriesController = UserStoriesController(collectionViewLayout: UICollectionViewFlowLayout())

        userStoriesController.userId = userSelected.id
        userStoriesController.userFullname = userSelected.fullname
        userStoriesController.userImageUrl = userSelected.profileImageUrl
        userStoriesController.currentUserDic = currentUserDic

        present(userStoriesController, animated: true) {
            self.userContentOptionsView.removeFromSuperview()
        }
    }
    
    @objc func showUserReviewsView() {
        let userReviewsController = UserReviewsController(collectionViewLayout: UICollectionViewFlowLayout())

        userReviewsController.userId = userSelected.id
        userReviewsController.userFullname = userSelected.fullname
        userReviewsController.userImageUrl = userSelected.profileImageUrl
        userReviewsController.currentUserDic = currentUserDic
        
        present(userReviewsController, animated: true, completion: nil)
        
        // Tracking each time user tap reviewsViewContainer
        guard let userEmail = Locksmith.loadDataForUserAccount(userAccount: "currentUserEmail") else { return }
        Mixpanel.mainInstance().identify(distinctId: (userEmail as [String : AnyObject])["email"] as! String!)
        Mixpanel.mainInstance().track(event: "Pressed reviewsViewContainer")
    }
    
    @objc func showWriteReviewView() {
        let writeReviewController = WriteReviewController()

        writeReviewController.userId = userSelected.id
        writeReviewController.userFullname = userSelected.fullname
        writeReviewController.userImageUrl = userSelected.profileImageUrl
        writeReviewController.currentUserDic = currentUserDic
        
        present(writeReviewController, animated: true, completion: nil)
        
        // Tracking each time user tap writeReviewViewContainer
        guard let userEmail = Locksmith.loadDataForUserAccount(userAccount: "currentUserEmail") else { return }
        Mixpanel.mainInstance().identify(distinctId: (userEmail as [String : AnyObject])["email"] as! String!)
        Mixpanel.mainInstance().track(event: "Pressed writeReviewViewContainer")
    }
    
    @objc func blockUserView() {
        let alert = UIAlertController(title: "", message: "Bloqueaste a \(self.userFullnameSelected!)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func setupUserInfoViewsContainers() {
        
        userContentOptionsView.viewSupport.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            
            self.view.addSubview(self.userContentOptionsView)
            self.userContentOptionsView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
            
            self.userContentOptionsView.storiesViewContainer.layoutIfNeeded()
            self.userContentOptionsView.storiesViewContainer.layer.addBorder(edge: .top, color: .gray, thickness: 1)
            
            let storiesTap = UITapGestureRecognizer(target: self, action: #selector(self.showUserStoriesView))
            self.userContentOptionsView.storiesViewContainer.addGestureRecognizer(storiesTap)
            
            let reviewsTap = UITapGestureRecognizer(target: self, action: #selector(self.showUserReviewsView))
            self.userContentOptionsView.reviewsViewContainer.addGestureRecognizer(reviewsTap)
            
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
    
    @objc func reachabilityStatusChanged() {
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
    
}



//
//  UserProfileController.swift
//  ReputationApp
//
//  Created by Omar Torres on 28/05/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import Alamofire
import Locksmith

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //    let homeReviewCellId = "homeReviewCellId"
    //    var reviews = [Review]()
    
    
    var userId: Int?
    var userFullname: String?
    var userImageUrl: String?
    var currentUserDic = [String: Any]()
    
    //    var user: User? {
    //        didSet {
    //            user?.fullname = userFullname!
    //            user?.profileImageUrl = userImageUrl!
    //            user?.id = userId!
    //            print("user initial: \(user?.fullname)")
    //        }
    //    }
    //
    //    let loader: UIActivityIndicatorView = {
    //        let indicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    //        indicator.alpha = 1.0
    //        indicator.center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: 270) // 250 is the header height + 20
    //        indicator.startAnimating()
    //        return indicator
    //    }()
    //
    //    let messageLabel: UILabel = {
    //        let ml = UILabel()
    //        ml.font = UIFont.systemFont(ofSize: 12)
    //        ml.numberOfLines = 0
    //        ml.textAlignment = .center
    //        ml.isHidden = true
    //        return ml
    //    }()
    //
    //    var collectionView: UICollectionView!
    
    // define a variable to store initial touch position
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    
    func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view?.window)
        
        if sender.state == UIGestureRecognizerState.began {
            initialTouchPoint = touchPoint
        } else if sender.state == UIGestureRecognizerState.changed {
            if touchPoint.y - initialTouchPoint.y > 0 {
                self.view.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
            }
        } else if sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled {
            if touchPoint.y - initialTouchPoint.y > 100 {
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        navigationController?.navigationBar.isHidden = false
        
        let tapGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandler(_:)))
        view.addGestureRecognizer(tapGesture)
        
        print("userId: ", userId)
        print("userFullname: ", userFullname)
        print("userImageUrl: ", userImageUrl)
        print("currentUserDic: ", currentUserDic)
        //        print("user initial: \(userFullname)")
        // General properties of the view
        let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        
        collectionView?.contentInset.bottom = 20
        
        navigationController?.isNavigationBarHidden = false
        //
        ////        let lightView = UIView()
        ////        lightView.backgroundColor = .white
        ////        collectionView?.backgroundView = lightView
        //
        //        // Other configurations
        ////        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
        ////        collectionView?.register(HomeReviewCell.self, forCellWithReuseIdentifier: homeReviewCellId)
        //
        //        NotificationCenter.default.addObserver(self, selector: #selector(showPreviousCV), name: NSNotification.Name(rawValue: "GoToSearchFromProfile"), object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(showWriteCV), name: NSNotification.Name(rawValue: "GoToWriteCV"), object: nil)
        //
        //
        //
        //        // Initialize functions
        //        subviewsAnchors()
        ////        checkIfReviewsExists()
        ////        fetchUser()
        ////        fetchOrderedReviews()
        //
        //        // Reachability for checking internet connection
        //        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityStatusChanged), name: NSNotification.Name(rawValue: "ReachStatusChanged"), object: nil)
        //
        //        //        setupLogOutButton()
        //
        //
        ////        guard let userIdFromKeyChain = Locksmith.loadDataForUserAccount(userAccount: "currentUserId") else { return }
        ////
        ////        let userId = userIdFromKeyChain["id"] as! Int
        ////
        ////        if userDictionary["id"] as! Int == userId {
        ////            print("Found myself, omit from list")
        ////            self.userDic = userDictionary
        ////            return
        ////        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.isStatusBarHidden = false
        //        navigationController?.tabBarController?.tabBar.isHidden = false
    }
    //
    //    func reachabilityStatusChanged() {
    //        print("Checking connectivity...")
    //    }
    //
    //    func subviewsAnchors() {
    //        view.addSubview(loader)
    //        view.addSubview(messageLabel)
    //
    //        messageLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 263 , paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0) //263 -> 243 is the header height, plus 20
    //    }
    //
    //    func showWriteCV() {
    //
    //    }
    //
    //    func showPreviousCV() {
    //        _ = navigationController?.popViewController(animated: true)
    //        navigationController?.isNavigationBarHidden = false
    //    }
    //
    //    func setupMessageLabel() {
    //        guard let nameFont = UIFont(name: "SFUIDisplay-Semibold", size: 14) else { return }
    //        guard let messageFont = UIFont(name: "SFUIDisplay-Regular", size: 14) else { return }
    //
    //        guard let userName = self.userFullname else { return }
    //        let attributedText = NSMutableAttributedString(string: userName, attributes: [NSFontAttributeName: nameFont])
    //
    //        attributedText.append(NSAttributedString(string: " todavía no tiene reseñas 😮.\n ¡Déjale una! ", attributes: [NSFontAttributeName: messageFont]))
    //
    //        self.messageLabel.attributedText = attributedText
    //    }
    //
    ////    fileprivate func checkIfReviewsExists() {
    ////        Database.database().reference().child("users").child(userId!).child("reviewsCount").observe(.value, with: { (snapshot) in
    ////            let value = snapshot.value as! Int
    ////            if value == 0 {
    ////                print("No hay reviews")
    ////                self.messageLabel.isHidden = false
    ////                self.loader.stopAnimating()
    ////                self.setupMessageLabel()
    ////
    ////            } else {
    ////                print("Sí hay reviews")
    ////            }
    ////        }) { (err) in
    ////            print("Failed to check if reviews exists for the user:", err)
    ////        }
    ////
    ////    }
    //
    //    fileprivate func fetchOrderedReviews() {
    //
    //
    //        // Check for internet connection
    //        if (reachability?.isReachable)! {
    //
    //            // Retreieve Auth_Token from Keychain
    //            if let userToken = Locksmith.loadDataForUserAccount(userAccount: "AuthToken") {
    //
    //                let authToken = userToken["authenticationToken"] as! String
    //
    //                print("Token 2: \(userToken)")
    //
    //                // Set Authorization header
    //                let header = ["Authorization": "Token token=\(authToken)"]
    //
    //                print("THE HEADER 2: \(header)")
    //
    //                let urlConcatenaited = "https://protected-anchorage-18127.herokuapp.com/api/"+userFullname!+"/reviews"
    //
    //                Alamofire.request(urlConcatenaited, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header).responseJSON { (response) in
    //                    switch response.result {
    //                    case .success(let JSON):
    //                        print("THE REVIEW JSON: \(JSON)")
    //
    //                        let jsonArray = JSON as! NSDictionary
    //
    //                        let reviews = jsonArray["reviews"] as! NSArray
    //
    //                        if reviews.count == 0 {
    //                            print("No hay reviews")
    //                            self.messageLabel.isHidden = false
    //                            self.loader.stopAnimating()
    //                            self.setupMessageLabel()
    //                        }
    //
    //                        reviews.forEach({ (value) in
    //                            guard let reviewDictionary = value as? [String: Any] else { return }
    //                            print("this is reviewDictionary: \(reviewDictionary)")
    //
    ////                            guard let user = self.user else { return }
    //
    //                            let review = Review(dictionary: reviewDictionary)
    //                            self.reviews.insert(review, at: 0)
    //
    //                            self.collectionView?.reloadData()
    //
    //                            self.loader.stopAnimating()
    //
    //                        })
    ////
    ////                        self.users.sort(by: { (u1, u2) -> Bool in
    ////
    ////                            return u1.fullname.compare(u2.fullname) == .orderedAscending
    ////
    ////                        })
    ////
    ////                        self.filteredUsers = self.users
    ////                        self.collectionView?.reloadData()
    ////                        self.loader.stopAnimating()
    //
    //                    case .failure(let error):
    //                        print(error)
    //                    }
    //                }
    //            }
    //        } else {
    //            self.loader.stopAnimating()
    //
    //            let alert = UIAlertController(title: "Error", message: "Tu conexión a internet está fallando. 🤔 Intenta de nuevo.", preferredStyle: UIAlertControllerStyle.alert)
    //            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
    //            self.present(alert, animated: true, completion: nil)
    //        }
    //    }
    //
    //    func showArrow() {
    //        let sheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    //
    //        sheetController.addAction(UIAlertAction(title: "Reportar", style: .destructive, handler: { (_) in
    //            let alert = UIAlertController(title: "", message: "Revisaremos tu reporte. 🤔", preferredStyle: UIAlertControllerStyle.alert)
    //            alert.addAction(UIAlertAction(title: "¡Gracias!", style: UIAlertActionStyle.default, handler: nil))
    //            self.present(alert, animated: true, completion: nil)
    //        }))
    //
    //        sheetController.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
    //
    //        present(sheetController, animated: true, completion: nil)
    //    }
    //
    //    func blockUser() {
    //        let sheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    //
    //        sheetController.addAction(UIAlertAction(title: "Bloquear usuario", style: .destructive, handler: { (_) in
    //            let alert = UIAlertController(title: "", message: "Bloqueaste a \(self.userFullname!)", preferredStyle: UIAlertControllerStyle.alert)
    //            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    //            self.present(alert, animated: true, completion: nil)
    //        }))
    //
    //        sheetController.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
    //
    //        present(sheetController, animated: true, completion: nil)
    //    }
    //
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    //        return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    //    }
    //
    //    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    //        if reviews.count > 0 {
    //            self.messageLabel.isHidden = true
    //        }
    //        return reviews.count
    //    }
    //
    //    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    //
    //        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeReviewCellId, for: indexPath) as! HomeReviewCell
    //        cell.review = reviews[indexPath.item]
    //        cell.backgroundColor = .white
    //
    //        let tap = UITapGestureRecognizer(target: self, action: #selector(showArrow))
    //        cell.arrowView.isUserInteractionEnabled = true
    //        cell.arrowView.addGestureRecognizer(tap)
    //
    //        return cell
    //    }
    //
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    //        return 1
    //    }
    //
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    //        return 20
    //    }
    //
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //
    //        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
    //        let dummyCell = HomeReviewCell(frame: frame)
    //        dummyCell.review = reviews[indexPath.item]
    //        dummyCell.layoutIfNeeded()
    //
    //        let targetSize = CGSize(width: view.frame.width, height: 1000)
    //        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
    //
    //        let height = max(40 + 8 + 8, estimatedSize.height)
    //        return CGSize(width: view.frame.width, height: height)
    //
    //    }
    //
    ////    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    ////        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
    ////        header.backgroundColor = UIColor.white
    ////        print("user header: \(self.user)")
    ////        header.fullnameLabel.text = userFullname
    ////
    ////        if let profileImageUrl = userImageUrl {
    ////            header.profileImageView.loadImage(urlString: profileImageUrl)
    ////        }
    ////
    ////        let tap = UITapGestureRecognizer(target: self, action: #selector(blockUser))
    ////        header.arrowView.isUserInteractionEnabled = true
    ////        header.arrowView.addGestureRecognizer(tap)
    ////
    ////        return header
    ////    }
    //
    ////    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    ////
    ////        return CGSize(width: view.frame.width, height: 246/*248*/) //231 real height  ||  +12 for bottom space
    ////    }
    //
    //    func handleLogout() {
    //        clearLoggedinFlagInUserDefaults()
    //        clearAPITokensFromKeyChain()
    //
    //        DispatchQueue.main.async {
    //            let loginController = LoginController()
    //            let navController = UINavigationController(rootViewController: loginController)
    //            self.present(navController, animated: true, completion: nil)
    //        }
    //    }
    //
    //    // 1. Clears the NSUserDefaults flag
    //    func clearLoggedinFlagInUserDefaults() {
    //        let defaults = UserDefaults.standard
    //        defaults.removeObject(forKey: "userLoggedIn")
    //        defaults.synchronize()
    //    }
    //
    //
    //    // 3. Clears API Auth token from Keychain
    //    func clearAPITokensFromKeyChain() {
    //        // clear API Auth Token
    //        try! Locksmith.deleteDataForUserAccount(userAccount: "AuthToken")
    //        try! Locksmith.deleteDataForUserAccount(userAccount: "currentUserId")
    //        try! Locksmith.deleteDataForUserAccount(userAccount: "currentUserName")
    //    }
}

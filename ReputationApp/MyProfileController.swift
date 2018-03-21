//
//  MyProfileController.swift
//  ReputationApp
//
//  Created by Omar Torres on 25/10/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import Locksmith
import GoogleSignIn
import Mixpanel

class MyProfileController: UIViewController {
    
    var userSelected: User! = nil
    var userDictionary = [String: Any]()
    
    let storiesOptionButton: UIButton = {
        let button = UIButton(type: .system)
//        button.backgroundColor = UIColor.white
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.tintColor = .white
        button.setTitle("Momentos", for: .normal)
        button.titleLabel?.font = UIFont(name: "SFUIDisplay-Semibold", size: 17)
//        button.addTarget(self, action: #selector(showUserStoriesView), for: .touchUpInside)
        button.layer.cornerRadius = 8
        return button
    }()
    
    @IBOutlet weak var reviewsOptionButton: UIButton!
//    @IBOutlet weak var fullnameLabel: UILabel!
    
    let gearIcon: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "gear").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleSheetAction), for: .touchUpInside)
        return button
    }()
    
    let userSearchControllerButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "userSearch-icon").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(goToUserFeedFromMyProfile), for: .touchUpInside)
        return button
    }()
    
    let dotsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Dots v1.1.8 ✌️"
        label.font = UIFont(name: "SFUIDisplay-Regular", size: 11)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    let userFeedControllerImage: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "dots_logo_profile")
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
        return imageView
    }()
    
    let fullnameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "SFUIDisplay-Medium", size: 14)
        label.textColor = .white
        label.text = "Tu nombre aquí"
        label.numberOfLines = 1
        return label
    }()
    
    let reviewsOptionView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 2
        return view
    }()
    
    let reviewsOptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Mis reseñas"
        label.textAlignment = .center
        label.font = UIFont(name: "SFUIDisplay-Semibold", size: 17)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    func showUserReviewsView() {
        let myReviewsController = MyReviewsController(collectionViewLayout: UICollectionViewFlowLayout())

        myReviewsController.userId = userSelected.id
        myReviewsController.userFullname = userSelected.fullname
        myReviewsController.userImageUrl = userSelected.profileImageUrl

        present(myReviewsController, animated: true, completion: nil)

        // Tracking each time user tap reviewsOptionButton
        guard let userEmail = Locksmith.loadDataForUserAccount(userAccount: "currentUserEmail") else { return }
        Mixpanel.mainInstance().identify(distinctId: (userEmail as [String : AnyObject])["email"] as! String!)
        Mixpanel.mainInstance().track(event: "Pressed reviewsOptionButton (mine)")
    }
    
//    func showUserStoriesView() {
//        let myStoriesController = MyStoriesController(collectionViewLayout: UICollectionViewFlowLayout())
//
//        myStoriesController.userId = userSelected.id
//        myStoriesController.userFullname = userSelected.fullname
//        myStoriesController.userImageUrl = userSelected.profileImageUrl
//
//        present(myStoriesController, animated: true, completion: nil)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.grayLow()
        navigationController?.navigationBar.isHidden = true
        
        setupTopViews()
        setupDotsLabel()
        
    }
    
    func goToUserFeedFromMyProfile() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GoToUserSearchControllerFromMyProfileController"), object: nil)
    }
    
    func setupTopViews() {
        view.addSubview(gearIcon)
        gearIcon.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 28, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 25, height: 25)
        
        view.addSubview(userSearchControllerButton)
        userSearchControllerButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 28, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 25, height: 25)
        
        view.addSubview(profileImageView)
        profileImageView.anchor(top: gearIcon.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 160, height: 160)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        guard let userAvatar = Locksmith.loadDataForUserAccount(userAccount: "currentUserAvatar") else { return }
        profileImageView.loadImage(urlString: ((userAvatar as [String : AnyObject])["avatar"] as! String?)!)
        
        view.addSubview(fullnameLabel)
        fullnameLabel.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        guard let userName = Locksmith.loadDataForUserAccount(userAccount: "currentUserName") else { return }
        fullnameLabel.text = (userName as [String : AnyObject])["name"] as! String?
        
        view.addSubview(reviewsOptionView)
        reviewsOptionView.anchor(top: fullnameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 60)
        
        reviewsOptionView.addSubview(reviewsOptionLabel)
        reviewsOptionLabel.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        reviewsOptionLabel.centerXAnchor.constraint(equalTo: reviewsOptionView.centerXAnchor).isActive = true
        reviewsOptionLabel.centerYAnchor.constraint(equalTo: reviewsOptionView.centerYAnchor).isActive = true
        reviewsOptionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showUserReviewsView)))
        reviewsOptionView.isUserInteractionEnabled = true
        
        guard let userEmail = Locksmith.loadDataForUserAccount(userAccount: "currentUserEmail") else { return }
        guard let userId = Locksmith.loadDataForUserAccount(userAccount: "currentUserId") else { return }
        
        userDictionary.updateValue((userId as [String : AnyObject])["id"] as! Int!, forKey: "id")
        userDictionary.updateValue((userName as [String : AnyObject])["name"] as! String!, forKey: "fullname")
        userDictionary.updateValue((userEmail as [String : AnyObject])["email"] as! String!, forKey: "email")
        userDictionary.updateValue((userAvatar as [String : AnyObject])["avatar"] as! String!, forKey: "avatar")
        
        let user = User(uid: (userId as [String : AnyObject])["id"] as! Int!, dictionary: userDictionary)
        
        userSelected = user
        
    }
    
    func setupDotsLabel() {
        view.addSubview(dotsLabel)
        dotsLabel.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 5, paddingRight: 0, width: 0, height: 0)
        dotsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func handleSheetAction() {
        let actionSheetController = UIAlertController()
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        actionSheetController.addAction(cancelActionButton)
        
        let saveActionButton = UIAlertAction(title: "Cerrar sesión", style: .default) { (action) in
            self.handleLogout()
        }
        actionSheetController.addAction(saveActionButton)
        
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func handleLogout() {
        clearLoggedinFlagInUserDefaults()
        clearAPITokensFromKeyChain()
        GIDSignIn.sharedInstance().signOut()
        
        DispatchQueue.main.async {
            let loginController = LoginController()
            let navController = UINavigationController(rootViewController: loginController)
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    func clearLoggedinFlagInUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "userLoggedIn")
        defaults.synchronize()
    }
    
    func clearAPITokensFromKeyChain() {
        // clear API Auth Token
        try! Locksmith.deleteDataForUserAccount(userAccount: "AuthToken")
        try! Locksmith.deleteDataForUserAccount(userAccount: "currentUserId")
        try! Locksmith.deleteDataForUserAccount(userAccount: "currentUserName")
        try! Locksmith.deleteDataForUserAccount(userAccount: "currentUserEmail")
        try! Locksmith.deleteDataForUserAccount(userAccount: "currentUserAvatar")
    }
}

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
        button.addTarget(self, action: #selector(showUserStoriesView), for: .touchUpInside)
        button.layer.cornerRadius = 8
        return button
    }()
    
    @IBOutlet weak var reviewsOptionButton: UIButton!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var profileImageView: CustomImageView!
    @IBOutlet weak var gearIcon: UIButton!
    
    let dotsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Dots v1.1.5 ✌️"
        label.font = UIFont(name: "SFUIDisplay-Regular", size: 11)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    @IBAction func showUserReviewsView() {
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
    
    func showUserStoriesView() {
        let myStoriesController = MyStoriesController(collectionViewLayout: UICollectionViewFlowLayout())
        
        myStoriesController.userId = userSelected.id
        myStoriesController.userFullname = userSelected.fullname
        myStoriesController.userImageUrl = userSelected.profileImageUrl
        
        present(myStoriesController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.grayLow()
        navigationController?.navigationBar.isHidden = true
        
        setupUserInfo()
        setupTopViews()
        setupOptionsButtons()
        setupLogoImageView()
        
    }
    
    func setupUserInfo() {
        guard let userName = Locksmith.loadDataForUserAccount(userAccount: "currentUserName") else { return }
        guard let userEmail = Locksmith.loadDataForUserAccount(userAccount: "currentUserEmail") else { return }
        guard let userId = Locksmith.loadDataForUserAccount(userAccount: "currentUserId") else { return }
        guard let userUsername = Locksmith.loadDataForUserAccount(userAccount: "currentUsernameName") else { return }
        guard let userAvatar = Locksmith.loadDataForUserAccount(userAccount: "currentUserAvatar") else { return }
        
        fullnameLabel.text = (userName as [String : AnyObject])["name"] as! String?
        profileImageView.loadImage(urlString: ((userAvatar as [String : AnyObject])["avatar"] as! String?)!)
        
        userDictionary.updateValue((userId as [String : AnyObject])["id"] as! Int!, forKey: "id")
        userDictionary.updateValue((userName as [String : AnyObject])["name"] as! String!, forKey: "fullname")
        userDictionary.updateValue((userEmail as [String : AnyObject])["email"] as! String!, forKey: "email")
        userDictionary.updateValue((userUsername as [String : AnyObject])["username"] as! String!, forKey: "username")
        userDictionary.updateValue((userAvatar as [String : AnyObject])["avatar"] as! String!, forKey: "avatar")
        
        let user = User(uid: (userId as [String : AnyObject])["id"] as! Int!, dictionary: userDictionary)
        
        userSelected = user
    }
    
    func setupTopViews() {
        profileImageView.layer.cornerRadius = 30
    }
    
    fileprivate func setupOptionsButtons() {
        reviewsOptionButton.layer.borderWidth = 2
        reviewsOptionButton.layer.borderColor = UIColor.white.cgColor
        reviewsOptionButton.layer.cornerRadius = 8
    }
    
    func setupLogoImageView() {
        view.addSubview(dotsLabel)
        dotsLabel.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 5, paddingRight: 0, width: 0, height: 0)
        dotsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    @IBAction func handleSheetAction() {
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

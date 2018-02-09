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
    
    let reviewsOptionButton: UIButton = {
        let button = UIButton(type: .system)
//        button.backgroundColor = UIColor.white
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.tintColor = .white
        button.setTitle("Reseñas", for: .normal)
        button.titleLabel?.font = UIFont(name: "SFUIDisplay-Semibold", size: 17)
        button.addTarget(self, action: #selector(showUserReviewsView), for: .touchUpInside)
        button.layer.cornerRadius = 8
        return button
    }()
    
    let fullnameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "SFUIDisplay-Medium", size: 14)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
        return imageView
    }()
    
    let gearIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .white
        return imageView
    }()
    
    func showUserReviewsView() {
        let myReviewsController = MyReviewsController(collectionViewLayout: UICollectionViewFlowLayout())
        
        myReviewsController.userId = userSelected.id
        myReviewsController.userFullname = userSelected.fullname
        myReviewsController.userImageUrl = userSelected.profileImageUrl
        
        present(myReviewsController, animated: true, completion: nil)
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
        view.addSubview(gearIcon)
        gearIcon.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 25, height: 25)
        gearIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSheetAction)))
        gearIcon.isUserInteractionEnabled = true
        
        view.addSubview(profileImageView)
        profileImageView.anchor(top: gearIcon.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 160, height: 160)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(fullnameLabel)
        fullnameLabel.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
    }
    
    fileprivate func setupOptionsButtons() {
        let stackView = UIStackView(arrangedSubviews: [storiesOptionButton, reviewsOptionButton])
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: fullnameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 130)
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
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
        try! Locksmith.deleteDataForUserAccount(userAccount: "currentUserAvatar")
    }
}
